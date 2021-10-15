`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.09.2021 16:32:52
// Design Name: 
// Module Name: gaussian_blur
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


module gaussian_blur(
    input clk,
    input [71:0] pixel_data,
    input pixel_data_valid,
    output reg [7:0] convolved_data,
    output reg convolved_data_valid
    );
    
    integer i ;
    reg [7:0] kernel_gaussian [8:0] ;
    reg [15:0] multData [8:0] ;
    reg [15:0] sumData_1;
    reg [15:0] sumData_2;
    reg sumData_valid, multData_valid, convolvedData_valid ;
    
    initial
    begin
       kernel_gaussian[0] = 1 ;
       kernel_gaussian[1] = 2 ;
       kernel_gaussian[2] = 1 ;
       kernel_gaussian[3] = 2 ;
       kernel_gaussian[4] = 4 ;
       kernel_gaussian[5] = 2 ;
       kernel_gaussian[6] = 1 ;
       kernel_gaussian[7] = 2 ;
       kernel_gaussian[8] = 1 ;
    end
    
    always @(posedge clk)
    begin
    for(i=0;i<9;i=i+1)
    begin
        multData[i] <= kernel_gaussian[i]*pixel_data[i*8+:8];
    end
    multData_valid <= pixel_data_valid;
    end


   always @(*)  //A combinational block
   begin
    sumData_1 = 0;
    for(i=0;i<9;i=i+1)
    begin
        sumData_1 = sumData_1 + multData[i];
    end
   end

   always @(posedge clk)
   begin
    sumData_2 <= sumData_1;
    sumData_valid <= multData_valid;
   end
    
   always @(posedge clk)
   begin
    convolved_data <= sumData_2/16;
    convolved_data_valid <= sumData_valid;
   end

endmodule
