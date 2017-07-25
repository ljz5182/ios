//
//  VideoCapture.m
//  H264
//
//  Created by 梁家章 on 2017/7/24.
//  Copyright © 2017年 梁家章. All rights reserved.
//

#import "VideoCapture.h"


@interface VideoCapture () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    
    
    
    
    AVCaptureDeviceInput * deviceInput;
    
    AVCaptureVideoDataOutput * aVcaptureVideoOutput;
    
    AVCaptureVideoPreviewLayer * aVcaptureVideoPreviewLayer;
    
    
}

@end

@implementation VideoCapture

@synthesize aVCaptureSession;


- (LJZResult)create {
    
    //1、创建回话捕捉
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    aVCaptureSession = captureSession;
    
    //2、设置输入输出
    AVCaptureDevice *captureDevice = [AVCaptureDevice  defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error;
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    deviceInput = videoDeviceInput;
    if (error) {
        return LJZResultFail;
    }
    
    if ([aVCaptureSession canAddInput:deviceInput]) {
        [aVCaptureSession addInput:deviceInput];
    }
    
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    aVcaptureVideoOutput = videoOutput;
    //是否卡顿时丢帧
    aVcaptureVideoOutput.alwaysDiscardsLateVideoFrames = NO;
    // 设置像素格式
    [aVcaptureVideoOutput setVideoSettings:@{
                                                      (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
                                                      }];
    
    dispatch_queue_t videoQueue = dispatch_queue_create("ljz.videoCapture.queue", DISPATCH_QUEUE_SERIAL);
    [aVcaptureVideoOutput setSampleBufferDelegate:self queue:videoQueue];
    if ([aVCaptureSession canAddOutput:aVcaptureVideoOutput]) {
        [aVCaptureSession addOutput:aVcaptureVideoOutput];
    } else {
        return LJZResultFail;
    }
    //3、设置输出视频方向
    AVCaptureConnection * connection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
    //视频的方向
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    //设置稳定性，判断connection连接对象是否支持视频稳定
    if ([connection isVideoStabilizationSupported]) {
        //这个稳定模式最适合连接
        connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    //缩放裁剪系数
    connection.videoScaleAndCropFactor = connection.videoMaxScaleAndCropFactor;
    
    return LJZResultNoError;
}


- (LJZResult)setVideoFrameRate:(NSInteger)frameRate {
    
    return 1;
}

- (LJZResult)openCameraWithDevicePosition:(AVCaptureDevicePosition)position
                               resolution:(LJZCaptureCameraQuality)resolution {
    
    [self switchCamera:position];
    
    NSString *sessionPreset;
    switch (resolution) {
        case LJZCaptureCameraQuality353x288:
            sessionPreset = AVCaptureSessionPreset352x288;
            break;
        case LJZCaptureCameraQuality640x480:
            sessionPreset = AVCaptureSessionPreset640x480;
            break;
        case LJZCaptureCameraQuality960x540:
            sessionPreset = AVCaptureSessionPresetiFrame960x540;
            break;
        case LJZCaptureCameraQuality1280x720:
            sessionPreset = AVCaptureSessionPreset1280x720;
            break;
        case LJZCaptureCameraQuality1920x1080:
            sessionPreset = AVCaptureSessionPreset1920x1080;
            break;
        case LJZCaptureCameraQuality3840x2160:
            sessionPreset = AVCaptureSessionPreset3840x2160;
            break;
    }
    //    设置session显示分辨率
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [aVCaptureSession setSessionPreset:sessionPreset];
    else
        [aVCaptureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    
    
    [aVCaptureSession startRunning];
    
    
    
    
    return LJZResultNoError;
}

- (LJZResult)setPreview: (UIView *)preview
                  frame: (CGRect)frame {
    
    AVCaptureVideoPreviewLayer * aVCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:aVCaptureSession];
    aVcaptureVideoPreviewLayer = aVCaptureVideoPreviewLayer;
    aVcaptureVideoPreviewLayer.frame = frame;
    // 设置layer展示视频的方向
    aVcaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [preview.layer addSublayer:aVcaptureVideoPreviewLayer];
    
    return LJZResultNoError;
}

- (LJZResult) closeCamera {
    
    [aVCaptureSession stopRunning];
    return LJZResultNoError;
}

- (LJZResult) turnTorchAndFlashOn: (BOOL)on {
    return LJZResultNoError;
}

- (LJZResult)switchCamera:(AVCaptureDevicePosition)position {
    
    // 获取当前设备方向
    AVCaptureDevicePosition curPosition = deviceInput.device.position;
    
    if (curPosition == position) {
        return LJZResultNoError;
    }
    // 创建设备输入对象
    AVCaptureDevice *captureDevice = [AVCaptureDevice  defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:position];
    
    // 获取改变的摄像头输入设备
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    
    // 移除之前摄像头输入设备
    [aVCaptureSession removeInput:deviceInput];
    
    // 添加新的摄像头输入设备
    [aVCaptureSession addInput:videoDeviceInput];
    
    // 记录当前摄像头输入设备
    deviceInput = videoDeviceInput;
    
    //重置采集方向
    AVCaptureConnection * connection = [aVcaptureVideoOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([connection isVideoOrientationSupported]) {
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    return LJZResultNoError;
}

- (LJZResult)destroy {
    
    if (aVCaptureSession) {
        [aVCaptureSession stopRunning];
        aVCaptureSession = nil;
    }
    if (deviceInput) {
        deviceInput = nil;
    }
    if (aVcaptureVideoOutput) {
        aVcaptureVideoOutput = nil;
    }
    
    [aVcaptureVideoPreviewLayer removeFromSuperlayer];
    aVcaptureVideoPreviewLayer = nil;
    
    return LJZResultNoError;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    NSLog(@">>>width:%zu height: %zu",CVPixelBufferGetWidth(buffer),CVPixelBufferGetHeight(buffer));
    [self.delegate videoCaptureOutputSampleBuffer:sampleBuffer
                                 fromVideoCapture:self];
}


@end
