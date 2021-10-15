`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.09.2021 16:50:45
// Design Name: 
// Module Name: sobel
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


module sobel(
input clk,
input [71:0] pixel_data,
input pixel_data_valid,
output reg [7:0] magnitude,
output reg [7:0] direction,
output reg convolved_data_valid
    );
  
integer i; 
reg [7:0] kernel_x [8:0];
reg [7:0] kernel_y [8:0];
reg [10:0] multData1[8:0];
reg [10:0] multData2[8:0];
reg [10:0] G_x;
reg [10:0] G_y;
wire [10:0] G_x_1;
wire [10:0] G_y_1;
reg multDataValid;
reg sumDataValid;
reg [20:0] G_x_square;
reg [20:0] G_y_square;
reg G_valid;
wire div_op_valid ;
wire [23:0] op_from_div ;
wire [17:0] div_value ;

initial
begin
    kernel_x[0] =  1;
    kernel_x[1] =  0;
    kernel_x[2] = -1;
    kernel_x[3] =  2;
    kernel_x[4] =  0;
    kernel_x[5] = -2;
    kernel_x[6] =  1;
    kernel_x[7] =  0;
    kernel_x[8] = -1;
    
    kernel_y[0] =  1;
    kernel_y[1] =  2;
    kernel_y[2] =  1;
    kernel_y[3] =  0;
    kernel_y[4] =  0;
    kernel_y[5] =  0;
    kernel_y[6] = -1;
    kernel_y[7] = -2;
    kernel_y[8] = -1;
end    
    
always @(posedge clk)
begin
    for(i=0;i<9;i=i+1)
    begin
        multData1[i] <= $signed(kernel_x[i])*$signed({1'b0,pixel_data[i*8+:8]});
        multData2[i] <= $signed(kernel_y[i])*$signed({1'b0,pixel_data[i*8+:8]});
    end
    multDataValid <= pixel_data_valid;
end


always @(*)
begin
    G_x = 0;
    G_y = 0;
    for(i=0;i<9;i=i+1)
    begin
        G_x = $signed(G_x) + $signed(multData1[i]);
        G_y = $signed(G_y) + $signed(multData2[i]);
    end
end

always @(posedge clk)
begin
   // G_x_1 <= G_x;
   // G_y_1 <= G_y;
    sumDataValid <= multDataValid;
end

assign G_x_1 = (multDataValid)? G_x : 0 ;
assign G_y_1 = (multDataValid)? G_y : 0 ;

division_ip d1 (
  .s_axis_divisor_tvalid(sumDataValid),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(G_x_1),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(sumDataValid),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata(G_y_1),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(div_op_valid),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(op_from_div)            // output wire [23 : 0] m_axis_dout_tdata
);

assign div_value = div_op_valid? {op_from_div[18:9],((op_from_div[18] == 1)? ~op_from_div[8]:op_from_div[8]),op_from_div[6:0]} : 0 ; 


always @(posedge clk)
begin
    G_x_square <= $signed(G_x_1)*$signed(G_x_1);
    G_y_square <= $signed(G_y_1)*$signed(G_y_1);
    G_valid <= sumDataValid;
end

always@ (posedge clk)
begin
     magnitude <= sqrt(G_x_square + G_y_square);
     convolved_data_valid <= G_valid ;
    // Direction mapping
//     if (div_value > -0.3928 && div_value < 0.3928)
//          direction <= 'd1 ;
//     else if ($atan2(G_y_real,G_x_real) > 0.3928 && $atan2(G_y_real,G_x_real) < 1.1785)
//          direction <= 'd2 ;
//     else if ($atan2(G_y_real,G_x_real) > 1.1785 && $atan2(G_y_real,G_x_real) < 1.9642)
//          direction <= 'd3 ;
//     else if ($atan2(G_y_real,G_x_real) > 1.9642 && $atan2(G_y_real,G_x_real) < 2.75)
//          direction <= 'd4 ; 
//     else if ($atan2(G_y_real,G_x_real) > 2.75 && $atan2(G_y_real,G_x_real) < -2.75)
//          direction <= 'd1 ;  
//     else if ($atan2(G_y_real,G_x_real) < -0.3928 && $atan2(G_y_real,G_x_real) > -1.1785)
//          direction <= 'd4 ;
//     else if ($atan2(G_y_real,G_x_real) < -1.1785 && $atan2(G_y_real,G_x_real) > -1.9642)
//          direction <= 'd3 ;   
//     else if ($atan2(G_y_real,G_x_real) < -1.9642 && $atan2(G_y_real,G_x_real) > -2.75)
//          direction <= 'd2 ;     
   if (div_op_valid)
   begin
     if (div_value > 18'b111111111111001011 && div_value < 18'b000000000000110101)//-0.4143 & 0.4143
          direction <= 'd1 ;
     else if (div_value > 18'b000000000000110101 && div_value < 18'b000000000100110101) //0.4143 & 2.4169
          direction <= 'd2 ;
     else if (div_value > 18'b000000000100110101 && div_value < 18'b111111111011001100) //2.4169 & -2.409
          direction <= 'd3 ;
     else if (div_value > 18'b111111111011001100 && div_value < 18'b111111111111001100) //-2.409 & -0.4129
          direction <= 'd4 ; 
     else if (div_value > 18'b111111111111001100 && div_value < 18'b000000000000110100) //-0.4129 & 0.4129
          direction <= 'd1 ;  
     else if (div_value < 18'b111111111111001011 && div_value > 18'b111111111011001011) //-0.4143  & -2.4169
          direction <= 'd4 ;
     else if (div_value < 18'b111111111011001011 && div_value > 18'b000000000100110100)  //-2.4169 & 2.4094
          direction <= 'd3 ;   
     else if (div_value < 18'b000000000100110100 && div_value > 18'b000000000000110100)  //2.4094  & 0.4129
          direction <= 'd2 ; 
    end                                    
end




function [15:0] sqrt;
    input [31:0] num;  //declare input
    //intermediate signals.
    reg [31:0] a;
    reg [15:0] q;
    reg [17:0] left,right,r;    
    integer i;
begin
    //initialize all the variables.
    a = num;
    q = 0;
    i = 0;
    left = 0;   //input to adder/sub
    right = 0;  //input to adder/sub
    r = 0;  //remainder
    //run the calculations for 16 iterations.
    for(i=0;i<16;i=i+1) begin 
        right = {q,r[17],1'b1};
        left = {r[15:0],a[31:30]};
        a = {a[29:0],2'b00};    //left shift by 2 bits.
        if (r[17] == 1) //add if r is negative
            r = left + right;
        else    //subtract if r is positive
            r = left - right;
        q = {q[14:0],!r[17]};       
    end
    sqrt = q;   //final assignment of output.
end
endfunction //end of Function

endmodule
