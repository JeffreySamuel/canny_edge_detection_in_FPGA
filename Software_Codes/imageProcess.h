#ifndef IMGPROCESS_H_   /* prevent circular inclusions */
#define IMGPROCESS_H_

#include "xil_types.h"
#include "xil_cache.h"
#include "xaxidma.h"
#include "xscugic.h"

typedef struct{
	char *imageDataPointer;
	char *filteredImageDataPointer;
	XAxiDma *DmaCtrlPointer;
	XScuGic *IntrCtrlPointer;
	u32 imageHSize;
	u32 imageVSize;
	u32 done;
}imgProcess;

int initImgProcessSystem(imgProcess *imgProcessInstance,u32 axiDmaBaseAddress,XScuGic *Intc);

int startImageProcessing(imgProcess *imgProcessInstance);

u32 checkIdle(u32 baseAddress,u32 offset);

//Function for copying image from one buffer to another buffer
int drawImage(u32 displayHSize,u32 displayVSize,u32 imageHSize,u32 imageVSize,u32 hOffset, u32 vOffset,int numColors,char *imagePointer,char *videoFramePointer);

#endif /* end of protection macro */
