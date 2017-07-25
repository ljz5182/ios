//
//  VideoEncode.h
//  H264
//
//  Created by 梁家章 on 2017/7/24.
//  Copyright © 2017年 梁家章. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import "ResultEnum.h"




@protocol VideoEncoderDelegate ;



@interface VideoEncoder : NSObject


/**
 *  视频编码代理
 */
@property (nonatomic, assign) id<VideoEncoderDelegate> delegate;

/**
 创建资源
 
 @param width 宽
 @param height 高
 @param frameInterval 关键帧间隔
 @return 状态码
 */
- (LJZResult)createWithWidth:(int)width
                      height:(int)height
               frameInterval:(int)frameInterval;

/**
 编码数据
 
 @param pixelBuffer buffer
 @return 状态码
 */
- (LJZResult)encode:(CVPixelBufferRef)pixelBuffer;

/**
 结束编码
 
 @return 状态码
 */
- (LJZResult)endEncode;



@end



@protocol VideoEncoderDelegate <NSObject>


/**
 *  视频编码回调：注意不能卡住该回调，否则可能出现异常!!!
 *
 *  @param dataUnit 采集数据结构体：系统回调类型，
 *  @param videoEncoder 采集类对象
 */
- (void)videoEncoderOutputNALUnit: (NALUnit)dataUnit
                 fromVideoEncoder: (const VideoEncoder *)videoEncoder;


@end
