//
//  ACCEncoder.h
//  H264
//
//  Created by 梁家章 on 2017/7/24.
//  Copyright © 2017年 梁家章. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>



@interface AACEncoder : NSObject

// 编码队列
@property (nonatomic) dispatch_queue_t encoderQueue;

// 回调队列
@property (nonatomic) dispatch_queue_t callBackQueue;


// 编码完成后回调
- (void)encoderSampleBuffer:(CMSampleBufferRef)sampleBuffer
            completionBlock:(void(^)(NSData *encodeData,
                                     NSError *error))completionBlock;

@end
