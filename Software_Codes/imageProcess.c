#include "imageProcess.h"

static void imageProcISR(void *CallBackRef);
static void dmaReceiveISR(void *CallBackRef);

/*****************************************************************************/
/**
 * This function copies the buffer data from image buffer to video buffer
 *
 * @param	displayHSize is Horizontal size of video in pixels
 * @param   displayVSize is Vertical size of video in pixels
 * @param	imageHSize is Horizontal size of image in pixels
 * @param   imageVSize is Vertical size of image in pixels
 * @param   hOffset is horizontal position in the video frame where image should be displayed
 * @param   vOffset is vertical position in the video frame where image should be displayed
 * @param   imagePointer pointer to the image buffer
 * @return
 * 		-  0 if successfully copied
 * 		- -1 if copying failed
 *****************************************************************************/
int drawImage(u32 displayHSize,u32 displayVSize,u32 imageHSize,u32 imageVSize,u32 hOffset, u32 vOffset,int numColors,char *imagePointer,char *videoFramePointer){
	Xil_DCacheInvalidateRange((u32)imagePointer,(imageHSize*imageVSize));
	for(int i=0;i<displayVSize;i++){
		for(int j=0;j<displayHSize;j++){
			if(i<vOffset || i >= vOffset+imageVSize){
				videoFramePointer[(i*displayHSize*3)+(j*3)]   = 0x00;
				videoFramePointer[(i*displayHSize*3)+(j*3)+1] = 0x00;
				videoFramePointer[(i*displayHSize*3)+(j*3)+2] = 0x00;
			}
			else if(j<hOffset || j >= hOffset+imageHSize){
				videoFramePointer[(i*displayHSize*3)+(j*3)]   = 0x00;
				videoFramePointer[(i*displayHSize*3)+(j*3)+1] = 0x00;
				videoFramePointer[(i*displayHSize*3)+(j*3)+2] = 0x00;
			}
			else {
				if(numColors==1){
					videoFramePointer[(i*displayHSize*3)+j*3]     = *imagePointer/16;
					videoFramePointer[(i*displayHSize*3)+(j*3)+1] = *imagePointer/16;
					videoFramePointer[(i*displayHSize*3)+(j*3)+2] = *imagePointer/16;
					imagePointer++;
				}
				else if(numColors==3){
					videoFramePointer[(i*displayHSize*3)+j*3]     = *imagePointer/16;
					videoFramePointer[(i*displayHSize*3)+(j*3)+1] = *(imagePointer++)/16;
					videoFramePointer[(i*displayHSize*3)+(j*3)+2] = *(imagePointer++)/16;
					imagePointer++;
				}
			}
		}
	}
	Xil_DCacheFlush();
	return 0;
}

/*****************************************************************************/
/**
 * This function initializes the DMA Controller and interrupts for Image Processing
 *
 * @param	imgProcess is a pointer to ImageProcess instance
 * @param   axiDmaBaseAddress base address for DMA Controller
 * @param	Intc Pointer to interrupt controller
 * 		-  0 if successfully initialized
 * 		- -1 DMA initialization failed
 * 		- -2 Interrupt setup failed
 *****************************************************************************/


int initImgProcessSystem(imgProcess *imgProcessInstance, u32 axiDmaBaseAddress,XScuGic *Intc){
	int status;
	XAxiDma_Config *myDmaConfig;
	XAxiDma myDma;
	myDmaConfig = XAxiDma_LookupConfigBaseAddr(axiDmaBaseAddress);
	status = XAxiDma_CfgInitialize(&myDma, myDmaConfig);
	if(status != XST_SUCCESS){
		xil_printf("DMA initialization failed with status %d\n",status);
		return -1;
	}
	imgProcessInstance->DmaCtrlPointer = &myDma;
	XAxiDma_IntrEnable(&myDma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
	XScuGic_SetPriorityTriggerType(Intc,XPAR_FABRIC_IMAGEPROCESSING_IP_0_O_INTR_INTR,0xA0,3);
	status = XScuGic_Connect(Intc,XPAR_FABRIC_IMAGEPROCESSING_IP_0_O_INTR_INTR,(Xil_InterruptHandler)imageProcISR,(void *)imgProcessInstance);

	if(status != XST_SUCCESS){
		xil_printf("Interrupt connection failed");
		return -2;
	}
	XScuGic_Enable(Intc,XPAR_FABRIC_IMAGEPROCESSING_IP_0_O_INTR_INTR);

	XScuGic_SetPriorityTriggerType(Intc,XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR,0xA1,3);
	status = XScuGic_Connect(Intc,XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR,(Xil_InterruptHandler)dmaReceiveISR,(void *)imgProcessInstance);
	if(status != XST_SUCCESS){
		xil_printf("Interrupt connection failed");
		return -2;
	}
	XScuGic_Enable(Intc,XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR);

	imgProcessInstance->IntrCtrlPointer=Intc;

	imgProcessInstance->done = 0;
	return 0;
}

/*****************************************************************************/
/**
 * This function initializes the DMA operation for image processing
 *
 * @param	imgProcessInstance is a pointer to the initialized imgProcess instance
 * 		-  0 DMA initiated successfully
 * 		- -1 DMA initiation failed
 *****************************************************************************/

int startImageProcessing(imgProcess *imgProcessInstance){
	int status;
	//status = XAxiDma_SimpleTransfer(imgProcessInstance->DmaCtrlPointer,(u32)imgProcessInstance->filteredImageDataPointer,(imgProcessInstance->imageHSize)*(imgProcessInstance->imageVSize),XAXIDMA_DEVICE_TO_DMA);
	status = XAxiDma_SimpleTransfer(imgProcessInstance->DmaCtrlPointer,(u32)imgProcessInstance->filteredImageDataPointer,512*512,XAXIDMA_DEVICE_TO_DMA);
	if(status != XST_SUCCESS){
		xil_printf("DMA Receive Failed with Status %d\n",status);
		return -1;
	}
	status = XAxiDma_SimpleTransfer(imgProcessInstance->DmaCtrlPointer,(u32)imgProcessInstance->imageDataPointer, 4*512,XAXIDMA_DMA_TO_DEVICE);
	if(status != XST_SUCCESS){
		xil_printf("DMA Transfer failed with Status %d\n",status);
		return -1;
	}
	return 0;
}

/*****************************************************************************/
/**
 * This function is the interrupt service routine for DMA S2MM interrupt
 *
 * @param	CallBackRef is a pointer to the initialized imgProcess instance
 *
 *****************************************************************************/

static void dmaReceiveISR(void *CallBackRef){
	XAxiDma_IntrDisable((XAxiDma *)(((imgProcess*)CallBackRef)->DmaCtrlPointer), XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrAckIrq((XAxiDma *)(((imgProcess*)CallBackRef)->DmaCtrlPointer), XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
	((imgProcess*)CallBackRef)->done=1;
	XAxiDma_IntrEnable((XAxiDma *)(((imgProcess*)CallBackRef)->DmaCtrlPointer), XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
}

/*****************************************************************************/
/**
 * This function checks whether a DMA channel is IDLE
 *
 * @param	baseAddress is the baseAddress of DMA Controller
 * @param   offset is the offset of Status register
 *
 *****************************************************************************/
u32 checkIdle(u32 baseAddress,u32 offset){
	u32 status;
	status = (XAxiDma_ReadReg(baseAddress,offset))&XAXIDMA_IDLE_MASK;
	return status;
}

/*****************************************************************************/
/**
 * This function is the interrupt service routine for the image processing IP
 *
 * @param	CallBackRef is a pointer to the initialized imgProcess instance
 *
 *****************************************************************************/

static void imageProcISR(void *CallBackRef){
	static int i=4;
	int status;
	XScuGic_Disable(((imgProcess*)CallBackRef)->IntrCtrlPointer,XPAR_FABRIC_IMAGEPROCESSING_IP_0_O_INTR_INTR);
	status = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
	while(status == 0)
		status = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
	if(i<518){
		status = XAxiDma_SimpleTransfer(((imgProcess*)CallBackRef)->DmaCtrlPointer,(u32)(((imgProcess*)CallBackRef)->imageDataPointer)+i*((imgProcess*)CallBackRef)->imageHSize,((imgProcess*)CallBackRef)->imageHSize,XAXIDMA_DMA_TO_DEVICE);
		i++;
	}
	XScuGic_Enable(((imgProcess*)CallBackRef)->IntrCtrlPointer,XPAR_FABRIC_IMAGEPROCESSING_IP_0_O_INTR_INTR);
}
