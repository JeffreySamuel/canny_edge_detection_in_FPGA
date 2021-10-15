module imageProcessTop(
input   axi_clk,
input   axi_reset_n,
//slave interface
input   i_data_valid,
input [7:0] i_data,
output  o_data_ready,
//master interface
output  o_data_valid,
output [7:0] o_data,
input   i_data_ready,
//interrupt
output  o_intr

    );

wire [71:0] data_to_gaussian, data_to_sobel, mag_to_nms, dir_to_nms, data_to_et;
wire data_to_gaussian_valid, data_from_nms_valid, data_from_dt_valid, data_to_et_valid, data_from_et_valid;
wire axis_prog_full;
wire [7:0] data_from_gaussian, mag_from_sobel, dir_from_sobel, data_from_nms, data_from_dt, data_from_et;
wire data_from_gaussian_valid, data_to_sobel_valid, data_from_sobel_valid, mag_to_nms_valid, dir_to_nms_valid;

assign o_data_ready = !axis_prog_full;
    
imageControl IC1(
    .i_clk(axi_clk),
    .i_rst(!axi_reset_n),
    .i_pixel_data(i_data),
    .i_pixel_data_valid(i_data_valid),
    .o_pixel_data(data_to_gaussian),
    .o_pixel_data_valid(data_to_gaussian_valid),
    .o_intr(o_intr)
  );    
  
// conv conv(
//     .i_clk(axi_clk),
//     .i_pixel_data(pixel_data),
//     .i_pixel_data_valid(pixel_data_valid),
//     .o_convolved_data(convolved_data),
//     .o_convolved_data_valid(convolved_data_valid)
// ); 

gaussian_blur gb(
    .clk(axi_clk),
    .pixel_data(data_to_gaussian),
    .pixel_data_valid(data_to_gaussian_valid),
    .convolved_data(data_from_gaussian),
    .convolved_data_valid(data_from_gaussian_valid)
    );
    
 imageControl IC2(
    .i_clk(axi_clk),
    .i_rst(!axi_reset_n),
    .i_pixel_data(data_from_gaussian),
    .i_pixel_data_valid(data_from_gaussian_valid),
    .o_pixel_data(data_to_sobel),
    .o_pixel_data_valid(data_to_sobel_valid),
    .o_intr()
  );  
  
  sobel s1(
      .clk(axi_clk),
      .pixel_data(data_to_sobel),
      .pixel_data_valid(data_to_sobel_valid),
      .magnitude(mag_from_sobel),
      .direction(dir_from_sobel),
      .convolved_data_valid(data_from_sobel_valid)
    );   
    
    //magnitude buffer
    imageControl IC3(
    .i_clk(axi_clk),
    .i_rst(!axi_reset_n),
    .i_pixel_data(mag_from_sobel),
    .i_pixel_data_valid(data_from_sobel_valid),
    .o_pixel_data(mag_to_nms),
    .o_pixel_data_valid(mag_to_nms_valid),
    .o_intr()
  );  
  
  //direction buffer
  imageControl IC4(
    .i_clk(axi_clk),
    .i_rst(!axi_reset_n),
    .i_pixel_data(dir_from_sobel),
    .i_pixel_data_valid(data_from_sobel_valid),
    .o_pixel_data(dir_to_nms),
    .o_pixel_data_valid(dir_to_nms_valid),
    .o_intr()
  );   
    
    non_max_suppr n1(
    .clk(axi_clk),
    .mag_data(mag_to_nms),
    .mag_data_valid(mag_to_nms_valid),
    .dir_data(dir_to_nms),
    .dir_data_valid(dir_to_nms_valid),
    .data_out(data_from_nms),  //data to double threshold
    .data_out_valid(data_from_nms_valid)); 
    
    double_threshold dt1(
       .clk(axi_clk),
       .data_in(data_from_nms),
       .data_in_valid(data_from_nms_valid),
       .data_out(data_from_dt),
       .data_out_valid(data_from_dt_valid)
      );
      
   imageControl IC5(
   .i_clk(axi_clk),
   .i_rst(!axi_reset_n),
   .i_pixel_data(data_from_dt),
   .i_pixel_data_valid(data_from_dt_valid),
   .o_pixel_data(data_to_et),
   .o_pixel_data_valid(data_to_et_valid),
   .o_intr()
 );   
      
    edge_track et1(
   .clk(axi_clk),
   .data_in(data_to_et),
   .data_in_valid(data_to_et_valid),
   .data_out(data_from_et),
   .data_out_valid(data_from_et_valid)
   );
 
 outputBuffer OB (
   .wr_rst_busy(),        // output wire wr_rst_busy
   .rd_rst_busy(),        // output wire rd_rst_busy
   .s_aclk(axi_clk),                  // input wire s_aclk
   .s_aresetn(axi_reset_n),            // input wire s_aresetn
   .s_axis_tvalid(data_from_et_valid),    // input wire s_axis_tvalid
   .s_axis_tready(),    // output wire s_axis_tready
   .s_axis_tdata(data_from_et),      // input wire [7 : 0] s_axis_tdata
   .m_axis_tvalid(o_data_valid),    // output wire m_axis_tvalid
   .m_axis_tready(i_data_ready),    // input wire m_axis_tready
   .m_axis_tdata(o_data),      // output wire [7 : 0] m_axis_tdata
   .axis_prog_full(axis_prog_full)  // output wire axis_prog_full
 );
