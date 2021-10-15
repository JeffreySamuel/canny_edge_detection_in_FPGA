# canny_edge_detection_in_FPGA
__Abstract:__

The edges of image are considered to be the most important image attributes that provide valuable information for human image perception. Edge detection is a type of image segmentation technique which is used to simplify the image data to minimize the amount of data to be processed which is required in the analysis of identification of an image. Edges are points in an image where there is a sharp transition in the pixel intensity level. In this project, Canny edge detection, one of the efficient edge detection algorithms is implemented on a Zedboard FPGA using verilog. The input image is stored on a PC and fed to the FPGA. The processed output image is displayed on a VGA monitor.


__The System Topology:__

![Canny_BlockDiagram](https://user-images.githubusercontent.com/85092975/137434389-1c5c9145-fc0f-4d4b-a3ab-fae946a1a086.jpg)


__Canny Edge Detection:__

The process of canny edge detection algorithm can be broken down to five different steps: 
1. Apply Gaussian filter to smooth the image in order to remove the noise 
2. Find the intensity gradients of the image using sobel operation. 
3. Apply gradient magnitude thresholding or lower bound cut-off suppression to get rid of spurious response to edge detection 
4. Apply double threshold to determine potential edges 
5. Track edge by hysteresis: Finalize the detection of edges by suppressing all the other edges that are weak and not connected to strong edges. 


__1.Gaussian Blur__

The image after a 3x3 Gaussian mask has been passed across each pixel. Since all edge detection results are easily affected by the noise in the image, it is essential to filter out the noise to prevent false detection caused by it. To smooth the image, a Gaussian filter kernel is convolved with the image. This step will slightly smooth the image to reduce the effects of obvious noise on the edge detector. It is important to understand that the selection of the size of the Gaussian kernel will affect the performance of the detector. The larger the size is, the lower the detector's sensitivity to noise. Additionally, the localization error to detect the edge will slightly increase with the increase of the Gaussian filter kernel size.

![Gaussian_kernel](https://user-images.githubusercontent.com/85092975/137435129-4c4692c2-3e5d-4195-a599-36c3ebfe0c88.jpg)

__2.Sobel Operation__

An edge in an image may point in a variety of directions, so the canny algorithm uses four filters to detect horizontal, vertical and diagonal edges in the blurred image. The edge detection operator (here sobel) returns a value for the first derivative in the horizontal direction (Gx) and the vertical direction (Gy). From this the edge gradient and direction can be determined: The edge direction angle is rounded to one of four angles representing vertical, horizontal and the two diagonals (0°, 45°, 90° and 135°). An edge direction falling in each color region will be set to a specific angle values, for instance θ in [0°, 22.5°] or [157.5°, 180°] maps to 0°. 

![Sobel_kernel](https://user-images.githubusercontent.com/85092975/137435751-84962145-44d2-4bb4-a002-127d34a15a1f.jpg)

__3.Non Maximum Suppression__

This is an edge thinning technique. Lower bound cut-off suppression is applied to find the locations with the sharpest change of intensity value. The algorithm for each pixel in the gradient image is: 

    1. Compare the edge strength of the current pixel with the edge strength of the pixel in the positive and negative gradient directions. 
    2. If the edge strength of the current pixel is the largest compared to the other pixels in the mask with the same direction (e.g., a pixel that is pointing in the y-direction will be compared to the pixel above and below it in the vertical axis), the value will be preserved. Otherwise, the value will be suppressed. 
    
The algorithm categorizes the continuous gradient directions into a small set of discrete directions, and then moves a 3x3 filter over the output of the previous step (that is, the edge strength and gradient directions). At every pixel, it suppresses the edge strength of the center pixel (by setting its value to 0) if its magnitude is not greater than the magnitude of the two neighbors in the gradient direction. Note that the sign of the direction is irrelevant, i.e. north–south is the same as south–north and so on. 
