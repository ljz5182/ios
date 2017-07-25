//
//  VideoDecoder.h
//  H264
//
//  Created by 梁家章 on 2017/7/24.
//  Copyright © 2017年 梁家章. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import "ResultEnum.h"


typedef void(^VideoDecodeCompleteBlock)(CVPixelBufferRef pixelBuffer);


@interface VideoDecoder : NSObject



/**
 视频解码
 
 @param path 视频路径
 @param complete 完成回调
 @return 状态码
 */
- (LJZResult)decodeWithPath:(NSString *)path
                   complete:(VideoDecodeCompleteBlock)complete;

/**
 销毁
 
 @return 状态码
 */
- (LJZResult)destroy;



@end
