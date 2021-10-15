`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2021 11:58:25
// Design Name: 
// Module Name: edge_track
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
//old format
//  7:0      15:8    23:16
//  31:24    39:32   47:40
//  55:48    63:56   71:64

//modified format
//  23:16    15:8    7:0
//  47:40    39:32   31:24
//  71:64    63:56   55:48

module edge_track(
    input clk,
    input [71:0] data_in,
    input data_in_valid,
    output reg [7:0] data_out,
    output data_out_valid
    );
    
    assign data_out_valid = data_in_valid ;
    always@ (posedge clk)
    begin
      if (data_in[7:0] == 255)
            data_out <=  'd255 ;
      else if (data_in[15:8] == 255)
            data_out <=  'd255 ;
      else if (data_in[23:16] == 255)
            data_out <=  'd255 ; 
      else if (data_in[47:40] == 255)
            data_out <=  'd255 ;                     
      else if (data_in[31:24] == 255)
            data_out <=  'd255 ;
      else if (data_in[55:48] == 255)
            data_out <=  'd255 ;
      else if (data_in[63:56] == 255)
            data_out <=  'd255 ; 
      else if (data_in[71:64] == 255)
            data_out <=  'd255 ;                         
      else
            data_out <= 'd0 ;      
    end

//  always@ (posedge clk)
//    begin
//      if (data_in[7:0] > data_in[39:32])
//            data_out <=  'd255 ;
//      else if (data_in[15:8] > data_in[39:32])
//            data_out <=  'd255 ;
//      else if (data_in[23:16] > data_in[39:32])
//            data_out <=  'd255 ; 
//      else if (data_in[47:40] > data_in[39:32])
//            data_out <=  'd255 ;                     
//      else if (data_in[31:24] > data_in[39:32])
//            data_out <=  'd255 ;
//      else if (data_in[55:48] > data_in[39:32])
//            data_out <=  'd255 ;
//      else if (data_in[63:56] > data_in[39:32])
//            data_out <=  'd255 ; 
//      else if (data_in[71:64] > data_in[39:32])
//            data_out <=  'd255 ;                         
//      else
//            data_out <= 'd0 ;      
//    end
    
endmodule
