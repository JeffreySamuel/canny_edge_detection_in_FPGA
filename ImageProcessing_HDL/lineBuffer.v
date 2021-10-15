`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.09.2021 15:22:15
// Design Name: 
// Module Name: lineBuffer
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


module lineBuffer(
    input clk,
    input rst,
    input [7:0] data_in,
    input data_valid,
    input read_data,
    output [23:0] data_out
    );
    
    localparam ImageWidth = 512 ;
    reg [8:0] writePointer, readPointer ;
    reg [7:0] line [ImageWidth-1:0] ;
    
    always@ (posedge clk)
    begin
     if(!rst)  //AXI interface is active low ; check again if theres a mistake
       writePointer <= 9'd0 ;
     else if (data_valid)
       begin
         line[writePointer] = data_in ;
         writePointer = writePointer + 9'd1 ;
       end  
    end
    
    assign data_out = {line[readPointer],line[readPointer+1],line[readPointer+2]} ;
    //assign data_out = {line[readPointer+2],line[readPointer+1],line[readPointer]} ;
    always@ (posedge clk)
    begin
      if (!rst)
        readPointer <= 9'd0 ;
      else if(read_data)
         readPointer <= readPointer + 'd1 ;
    end
    
endmodule
