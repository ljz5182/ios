//
//  AudioCapture.m
//  H264
//
//  Created by 梁家章 on 2017/7/24.
//  Copyright © 2017年 梁家章. All rights reserved.
//

#import "AudioCapture.h"


@interface AudioCapture () <AVCaptureAudioDataOutputSampleBufferDelegate> {
    
    AVCaptureSession *aVCaptureAudioSession;
}

@end

@implementation AudioCapture
@synthesize ljzAudioHandle;

- (LJZResult)create {
    
    AVCaptureSession * captureSession = [[AVCaptureSession alloc]init];
    aVCaptureAudioSession = captureSession;
    
    //2、获取麦克风
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    //3、创建对应音频设备输入对象
    AVCaptureInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    
    //4、添加音频
    if ([captureSession canAddInput:audioDeviceInput]) {
        [captureSession addInput:audioDeviceInput];
    }
    
    //5、获取音频输入输出设备
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    
    //6、设置代理 捕获音频数据
    //注意:队列必须是串行队列，才能获取到数据，而且不能为空
    dispatch_queue_t audioQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
    [audioOutput setSampleBufferDelegate:self queue:audioQueue];
    if ([captureSession canAddOutput:audioOutput]) {
        [captureSession addOutput:audioOutput];
    }
    
    
    // 音频保存路径
    NSString *audioPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"audio.aac"];
    [[NSFileManager defaultManager] removeItemAtPath:audioPath error:nil]; // 移除旧文件
    [[NSFileManager defaultManager] createFileAtPath:audioPath contents:nil attributes:nil]; // 创建新文件
    ljzAudioHandle = [NSFileHandle fileHandleForWritingAtPath:audioPath];  // 管理写进文件
    
    
    return LJZResultNoError;
}



- (LJZResult) openMicrophoneWithDevice {
    //7、启动会话
    [aVCaptureAudioSession startRunning];
    return LJZResultNoError;
}

- (LJZResult) closeMicrophone {
    [aVCaptureAudioSession stopRunning];
    
    return LJZResultNoError;
}

- (LJZResult) destroy {
    
    if (aVCaptureAudioSession) {
        [aVCaptureAudioSession stopRunning];
        aVCaptureAudioSession = nil;
    }
    
    return LJZResultNoError;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    [self.delegate ljzAudioCaptureOutputSampleBuffer:sampleBuffer
                                    fromAudioCapture:self];
    
}
@end
