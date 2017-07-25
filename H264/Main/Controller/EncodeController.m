//
//  EncodeController.m
//  H264
//
//  Created by 梁家章 on 2017/7/24.
//  Copyright © 2017年 梁家章. All rights reserved.
//

#import "EncodeController.h"
#import "VideoCapture.h"
#import "VideoEncoder.h"
#import "ResultEnum.h"
#import "AudioCapture.h"
#import "AACEncoder.h"





@interface EncodeController ()  <VideoCaptureDelegate,VideoEncoderDelegate,AudioCaptureDelegate> {
    
    
    VideoCapture * _videoCapture;
    VideoEncoder * _videoEncoder;
    AudioCapture * _audioCapture;
    AACEncoder   * _aacEncoder;
    
    
    UIButton * _startButton;
    
}

@end

@implementation EncodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _aacEncoder = [[AACEncoder alloc] init];
    
    // 视频
    _videoCapture = [[VideoCapture alloc] init];
    _videoCapture.delegate = self;
    [_videoCapture create];
    NSLog(@">>>>>> %f",self.view.frame.size.width);
    
    [_videoCapture setPreview:self.view
                        frame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    
    _videoEncoder = [[VideoEncoder alloc] init];
    _videoEncoder.delegate = self;
    [_videoEncoder createWithWidth:480 height:640 frameInterval:30];
    
    
    // 音频
    _audioCapture = [[AudioCapture alloc] init];
    [_audioCapture create];
    _audioCapture.delegate = self;
    
    
    
    
    
    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _startButton.frame =  CGRectMake((self.view.frame.size.width - 70)/2, self.view.frame.size.height - 180, 70, 70);
    
    _startButton.layer.masksToBounds = YES;
    
    _startButton.layer.cornerRadius = _startButton.frame.size.height/2;
    
    _startButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    
    [_startButton setTitle:@"startCode" forState:UIControlStateNormal];
    
    _startButton.titleLabel.font = [UIFont systemFontOfSize:16];
    
    _startButton.titleLabel.numberOfLines = 0;
    
    [_startButton setTitleColor:[UIColor colorWithRed:140.2f/255 green:40.2f/255 blue:147.2f/255 alpha:1.0] forState:UIControlStateNormal];
    
    [_startButton addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_startButton];
    
    [self.view bringSubviewToFront:_startButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)openCamera:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [_videoCapture openCameraWithDevicePosition:AVCaptureDevicePositionBack resolution:LJZCaptureCameraQuality640x480];
        [_audioCapture openMicrophoneWithDevice];
        [sender setTitle:@"停止编码" forState:UIControlStateNormal];
        
    }else {
        [_videoCapture closeCamera];
        [_audioCapture closeMicrophone];
        [sender setTitle:@"开始编码" forState:UIControlStateNormal];
    }
    
}


- (void)videoCaptureOutputSampleBuffer:(const CMSampleBufferRef)sampleBuffer
                      fromVideoCapture:(const VideoCapture *)videoCapture {
    
    [_videoEncoder encode:CMSampleBufferGetImageBuffer(sampleBuffer)];
}


- (void)ljzAudioCaptureOutputSampleBuffer: (const CMSampleBufferRef)sampleBuffer
                         fromAudioCapture: (const AudioCapture *)audioCapture {
    
    [_aacEncoder encoderSampleBuffer:sampleBuffer completionBlock:^(NSData *encodedData, NSError *error) {
        NSLog(@">>>> auido encode data = %@",encodedData);
        
        [_audioCapture.ljzAudioHandle writeData:encodedData];
    }];
}

- (void)videoEncoderOutputNALUnit: (NALUnit)dataUnit
                 fromVideoEncoder: (const VideoEncoder *)videoEncoder  {
    
    
}
@end
