//
//  LJZCAEAGLLayer.h
//  H264
//
//  Created by 梁家章 on 2017/7/24.
//  Copyright © 2017年 梁家章. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#include <CoreVideo/CoreVideo.h>



@interface LJZCAEAGLLayer : CAEAGLLayer


@property CVPixelBufferRef pixelBuffer;

- (id)initWithFrame:(CGRect)frame;

- (void)resetRenderBuffer;



@end
