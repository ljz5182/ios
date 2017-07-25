//
//  AudioCapture.h
//  H264
//
//  Created by 梁家章 on 2017/7/24.
//  Copyright © 2017年 梁家章. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ResultEnum.h"


@protocol AudioCaptureDelegate ;


@interface AudioCapture : NSObject


@property (nonatomic, assign) id<AudioCaptureDelegate>delegate;
@property (nonatomic, strong) NSFileHandle *ljzAudioHandle;

- (LJZResult)create;

- (LJZResult)openMicrophoneWithDevice;

- (LJZResult)closeMicrophone;

- (LJZResult)destroy;


@end


@protocol AudioCaptureDelegate <NSObject>


/**
 *  音频采集回调：注意不能卡住该回调，否则可能出现异常!!!
 *
 *  @param sampleBuffer 采集数据结构体：系统回调类型，
 *  @param audioCapture 采集类对象
 */

- (void)ljzAudioCaptureOutputSampleBuffer: (const CMSampleBufferRef)sampleBuffer
                         fromAudioCapture: (const AudioCapture *)audioCapture;


@end
