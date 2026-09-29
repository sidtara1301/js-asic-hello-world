/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_sidtara1301 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Tie off unused outputs (OpenLane will throw errors if outputs float)
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;
    assign uo_out[7:1] = 7'b0;

    reg [9:0] tx_shift_reg;
    reg [15:0] baud_timer;
    
    // Map the lowest bit of the shift register to output pin 0
    assign uo_out[0] = tx_shift_reg[0];

    always @(posedge clk) begin
          if (!rst_n) begin
              // Load the 'A' frame: {Stop(1), Data(01000001), Start(0)}
              tx_shift_reg <= 10'b1_01000001_0; 
              baud_timer <= 0;
          end else begin
              // Rotate the bits: LSB shifts out, MSB wraps around
              tx_shift_reg <= {tx_shift_reg[0], tx_shift_reg[9:1]}; 
          end
    end
endmodule
