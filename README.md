# canny_edge_detection_in_FPGA
__Abstract:__

The edges of image are considered to be the most important image attributes that provide valuable information for human image perception. Edge detection is a type of image segmentation technique which is used to simplify the image data to minimize the amount of data to be processed which is required in the analysis of identification of an image. Edges are points in an image where there is a sharp transition in the pixel intensity level. In this project, Canny edge detection, one of the efficient edge detection algorithms is implemented on a Zedboard FPGA using verilog. The input image is stored on a PC and fed to the FPGA. The processed output image is displayed on a VGA monitor.


__The System Topology:__

![Canny_BlockDiagram](https://user-images.githubusercontent.com/85092975/137434389-1c5c9145-fc0f-4d4b-a3ab-fae946a1a086.jpg)


__Canny Edge Detection:__

The process of canny edge detection algorithm can be broken down to five different steps: 
1. Apply Gaussian filter to smooth the image in order to remove the noise 
2. Find the intensity gradients of the image 
3. Apply gradient magnitude thresholding or lower bound cut-off suppression to get rid of spurious response to edge detection 
4. Apply double threshold to determine potential edges 
5. Track edge by hysteresis: Finalize the detection of edges by suppressing all the other edges that are weak and not connected to strong edges. 


__1.Gaussian Blur__

The image after a 3x3 Gaussian mask has been passed across each pixel. Since all edge detection results are easily affected by the noise in the image, it is essential to filter out the noise to prevent false detection caused by it. To smooth the image, a Gaussian filter kernel is convolved with the image. This step will slightly smooth the image to reduce the effects of obvious noise on the edge detector. It is important to understand that the selection of the size of the Gaussian kernel will affect the performance of the detector. The larger the size is, the lower the detector's sensitivity to noise. Additionally, the localization error to detect the edge will slightly increase with the increase of the Gaussian filter kernel size.

