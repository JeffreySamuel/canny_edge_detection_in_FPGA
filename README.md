# canny_edge_detection_in_FPGA
**Abstract:**

The edges of image are considered to be the most important image attributes that provide valuable information for human image perception. Edge detection is a type of image segmentation technique which is used to simplify the image data to minimize the amount of data to be processed which is required in the analysis of identification of an image. Edges are points in an image where there is a sharp transition in the pixel intensity level. In this project, Canny edge detection, one of the efficient edge detection algorithms is implemented on a Zedboard FPGA using verilog. The input image is stored on a PC and fed to the FPGA. The processed output image is displayed on a VGA monitor.

**Canny Edge Detection:**

The process of canny edge detection algorithm can be broken down to five different steps: 
1. Apply Gaussian filter to smooth the image in order to remove the noise 
2. Find the intensity gradients of the image 
3. Apply gradient magnitude thresholding or lower bound cut-off suppression to get rid of spurious response to edge detection 
4. Apply double threshold to determine potential edges 
5. Track edge by hysteresis: Finalize the detection of edges by suppressing all the other edges that are weak and not connected to strong edges. 
