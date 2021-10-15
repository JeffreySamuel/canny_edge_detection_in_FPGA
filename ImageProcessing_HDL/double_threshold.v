`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2021 11:43:59
// Design Name: 
// Module Name: double_threshold
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module double_threshold(
    input clk,
    input [7:0] data_in,
    input data_in_valid,
    output reg [7:0] data_out,
    output data_out_valid);
    
    localparam UpperThreshold = 220 ;
    localparam LowerThreshold = 85 ;    //255/3 = 85
    
    assign data_out_valid = data_in_valid ;
    always@ (posedge clk)
    begin
      if (data_in_valid)
        begin
          if (data_in > UpperThreshold )
             data_out <= 'd255 ;    //strong pixels
          else if (data_in < LowerThreshold) 
             data_out <= 'd0 ;      //weak pixels
          else
             data_out <= data_in ;     
        end
    end
endmodule
