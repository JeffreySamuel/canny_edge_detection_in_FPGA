# canny_edge_detection_in_FPGA
# Abstract:

The edges of image are considered to be the most important image attributes that provide valuable information for human image perception. Edge detection is a type of image segmentation technique which is used to simplify the image data to minimize the amount of data to be processed which is required in the analysis of identification of an image. Edges are points in an image where there is a sharp transition in the pixel intensity level. In this project, Canny edge detection, one of the efficient edge detection algorithms is implemented on a Zedboard FPGA using verilog. The input image is stored on a PC and fed to the FPGA. The processed output image is displayed on a VGA monitor.


# The System Topology:

![Canny_BlockDiagram](https://user-images.githubusercontent.com/85092975/137434389-1c5c9145-fc0f-4d4b-a3ab-fae946a1a086.jpg)


# Canny Edge Detection:

The process of canny edge detection algorithm can be broken down to five different steps: 
1. Apply Gaussian filter to smooth the image in order to remove the noise 
2. Find the intensity gradients of the image using sobel operation. 
3. Apply gradient magnitude thresholding or lower bound cut-off suppression to get rid of spurious response to edge detection 
4. Apply double threshold to determine potential edges 
5. Track edge by hysteresis: Finalize the detection of edges by suppressing all the other edges that are weak and not connected to strong edges. 


## 1.Gaussian Blur

The image after a 3x3 Gaussian mask has been passed across each pixel. Since all edge detection results are easily affected by the noise in the image, it is essential to filter out the noise to prevent false detection caused by it. To smooth the image, a Gaussian filter kernel is convolved with the image. This step will slightly smooth the image to reduce the effects of obvious noise on the edge detector. It is important to understand that the selection of the size of the Gaussian kernel will affect the performance of the detector. The larger the size is, the lower the detector's sensitivity to noise. Additionally, the localization error to detect the edge will slightly increase with the increase of the Gaussian filter kernel size.

![Gaussian_kernel](https://user-images.githubusercontent.com/85092975/137435129-4c4692c2-3e5d-4195-a599-36c3ebfe0c88.jpg)


## 2.Sobel Operation

An edge in an image may point in a variety of directions, so the canny algorithm uses four filters to detect horizontal, vertical and diagonal edges in the blurred image. The edge detection operator (here sobel) returns a value for the first derivative in the horizontal direction (Gx) and the vertical direction (Gy). From this the edge gradient and direction can be determined: The edge direction angle is rounded to one of four angles representing vertical, horizontal and the two diagonals (0°, 45°, 90° and 135°). An edge direction falling in each color region will be set to a specific angle values, for instance θ in [0°, 22.5°] or [157.5°, 180°] maps to 0°. 

![Sobel_kernel](https://user-images.githubusercontent.com/85092975/137435751-84962145-44d2-4bb4-a002-127d34a15a1f.jpg)


## 3.Non Maximum Suppression

This is an edge thinning technique. Lower bound cut-off suppression is applied to find the locations with the sharpest change of intensity value. The algorithm for each pixel in the gradient image is: 

 a) Compare the edge strength of the current pixel with the edge strength of the pixel in the positive and negative gradient directions. 

 b) If the edge strength of the current pixel is the largest compared to the other pixels in the mask with the same direction (e.g., a pixel that is pointing in the y-direction will be compared to the pixel above and below it in the vertical axis), the value will be preserved. Otherwise, the value will be suppressed. 
    
The algorithm categorizes the continuous gradient directions into a small set of discrete directions, and then moves a 3x3 filter over the output of the previous step (that is, the edge strength and gradient directions). At every pixel, it suppresses the edge strength of the center pixel (by setting its value to 0) if its magnitude is not greater than the magnitude of the two neighbors in the gradient direction. Note that the sign of the direction is irrelevant, i.e. north–south is the same as south–north and so on. 


## 4.Double Thresholding

After application of non-maximum suppression, remaining edge pixels provide a more accurate representation of real edges in an image. However, some edge pixels remain that are caused by noise and color variation. In order to account for these spurious responses, it is essential to filter out edge pixels with a weak gradient value and preserve edge pixels with a high gradient value. 

This is accomplished by selecting high and low threshold values. If an edge pixel’s gradient value is higher than the high threshold value, it is marked as a strong edge pixel. If an edge pixel’s gradient value is smaller than the high threshold value and larger than the low threshold value, it is marked as a weak edge pixel. If an edge pixel's gradient value is smaller than the low threshold value, it will be suppressed. The two threshold values are empirically determined and their definition will depend on the content of a given input image. 


## 5.Edge Tracking by Hysteresis

So far, the strong edge pixels should certainly be involved in the final edge image, as they are extracted from the true edges in the image. However, there will be some debate on the weak edge pixels, as these pixels can either be extracted from the true edge, or the noise/color variations. To achieve an accurate result, the weak edges caused by the latter reasons should be removed.  

Usually a weak edge pixel caused from true edges will be connected to a strong edge pixel while noise responses are unconnected. To track the edge connection, blob analysis is applied by looking at a weak edge pixel and its 8-connected neighborhood pixels. As long as there is one strong edge pixel that is involved in the blob, that weak edge point can be identified as one that should be preserved. 


# The Complete Block Design:

![Block_design](https://user-images.githubusercontent.com/85092975/137436645-564adb44-7aaf-4282-b60c-f74eb41b6c30.jpg)

# Results Obtained:

![op_1](https://user-images.githubusercontent.com/85092975/137437229-3f31a1ee-6480-484f-b8fa-78a32c34fc68.jpg)

![op_2](https://user-images.githubusercontent.com/85092975/137437241-3b249e7a-1e55-49e0-8d0f-06e8b1bb28df.jpg)

![op_3](https://user-images.githubusercontent.com/85092975/137437259-6b51e4a5-5342-4ffc-9eda-ad310e7b1992.jpg)
