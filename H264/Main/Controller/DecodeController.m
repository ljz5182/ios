//
//  DecodeController.m
//  H264
//
//  Created by 梁家章 on 2017/7/24.
//  Copyright © 2017年 梁家章. All rights reserved.
//

#import "DecodeController.h"
#import "LJZCAEAGLLayer.h"
#import "VideoDecoder.h"
#import <AudioToolbox/AudioToolbox.h>


@interface DecodeController ()  {
    
    VideoDecoder    * _videoDecoder;
    LJZCAEAGLLayer  * _ljzCAEAGLLayer;
    
    UIButton        * _startButton;
}

@end

@implementation DecodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _videoDecoder = [[VideoDecoder alloc] init];
    
    
    _ljzCAEAGLLayer = [[LJZCAEAGLLayer alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    [self.view.layer addSublayer:_ljzCAEAGLLayer];
    
    
    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _startButton.frame =  CGRectMake((self.view.frame.size.width - 70)/2, self.view.frame.size.height - 180, 70, 70);
    
    _startButton.layer.masksToBounds = YES;
    
    _startButton.layer.cornerRadius = _startButton.frame.size.height/2;
    
    _startButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    
    [_startButton setTitle:@"startDecode" forState:UIControlStateNormal];
    
    _startButton.titleLabel.font = [UIFont systemFontOfSize:16];
    
    _startButton.titleLabel.numberOfLines = 0;
    
    [_startButton setTitleColor:[UIColor colorWithRed:140.2f/255 green:40.2f/255 blue:147.2f/255 alpha:1.0] forState:UIControlStateNormal];
    
    [_startButton addTarget:self action:@selector(decodeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_startButton];
    
    [self.view bringSubviewToFront:_startButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/**
 *  获取aac音频解码 两种方法
 */
- (void)audioStart {
    
    NSString *urlString = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"audio.aac"];
    NSURL *audioUrl = [NSURL URLWithString:urlString];
    
    NSLog(@"thtrhrthr:%@",urlString);
    // 第一种:
    SystemSoundID soundID;
    // Creates a system sound object.
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(audioUrl), &soundID);
    // Registers a callback function that is invoked when a specified system sound finishes playing.
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, &playCallBack, (__bridge void * _Nullable)(self));
    // AudioServicesPlayAlertSound(soundID);
    AudioServicesPlaySystemSound(soundID);
    
}

void playCallBack(SystemSoundID ID, void *clientData) {
    
    NSLog(@"callBack");
}

- (void)decodeButton:(UIButton *)sender {
    
    [self audioStart];

    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"video.h264"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_videoDecoder decodeWithPath:filePath complete:^(CVPixelBufferRef pixelBuffer) {
            NSLog(@">>> pixelBuffer = %@",pixelBuffer);
            _ljzCAEAGLLayer.pixelBuffer = pixelBuffer;
        }];
    });
}

@end
