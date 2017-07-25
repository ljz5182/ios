//
//  ResultEnum.h
//  H264
//
//  Created by 梁家章 on 2017/7/24.
//  Copyright © 2017年 梁家章. All rights reserved.
//

#ifndef ResultEnum_h
#define ResultEnum_h



typedef enum {
    
    LJZResultNoError                                        = 0,
    
    LJZResultFail                                           = 1,
    
} LJZResult;




typedef enum {
    
    LJZCaptureCameraQuality353x288           = 0,
    
    LJZCaptureCameraQuality640x480           = 1,
    
    LJZCaptureCameraQuality960x540           = 2,
    
    LJZCaptureCameraQuality1280x720          = 3,
    
    LJZCaptureCameraQuality1920x1080         = 4,
    
    LJZCaptureCameraQuality3840x2160         = 5,
    
} LJZCaptureCameraQuality;


typedef struct _NALUnit {
    
    unsigned int type;
    
    unsigned int size;
    
    unsigned char *data;
    
} NALUnit;



typedef enum {
    
    NALUTypeBPFrame = 0x01,
    
    NALUTypeIFrame = 0x05,
    
    NALUTypeSPS = 0x07,
    
    NALUTypePPS = 0x08
    
} NALUType;

#endif /* ResultEnum_h */
