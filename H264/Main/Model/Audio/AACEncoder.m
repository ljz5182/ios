//
//  ACCEncoder.m
//  H264
//
//  Created by 梁家章 on 2017/7/24.
//  Copyright © 2017年 梁家章. All rights reserved.
//

#import "AACEncoder.h"




@interface AACEncoder () {
    
}

@property (nonatomic) AudioConverterRef  audioConverter;

@property (nonatomic) uint8_t * aacBuffer;

@property (nonatomic) NSUInteger aacBufferSize;

@property (nonatomic) char * pcmBuffer;

@property (nonatomic) size_t pcmBufferSize;



@end

@implementation AACEncoder


- (void)dealloc {
    
    AudioConverterDispose(_audioConverter);
    free(_aacBuffer);
}



- (id)init {
    
    if (self = [super init]) {
        
        _encoderQueue = dispatch_queue_create("AAC Encoder Queue", DISPATCH_QUEUE_SERIAL);
        _callBackQueue = dispatch_queue_create("AAC Encoder CallBack Queue", DISPATCH_QUEUE_SERIAL);
        _audioConverter = NULL;
        _pcmBufferSize = 0;
        _pcmBuffer = NULL;
        _aacBufferSize = 1024;
        _aacBuffer = malloc(_aacBufferSize * sizeof(uint8_t));
        memset(_aacBuffer, 0, _aacBufferSize);
    }
    
    return self;
}


/*
  AAC 编码的场景， 采集到的PCM数据，存储的格式就是AAC
 1. 设置编码参数
 */
- (void)setupEncoderFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    AudioStreamBasicDescription inAudioStreamBasicDescription = *CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer));
    
    AudioStreamBasicDescription outAudioStreamBasicDescription = {0};
    
    outAudioStreamBasicDescription.mSampleRate = inAudioStreamBasicDescription.mSampleRate;
    
    outAudioStreamBasicDescription.mFormatID = kAudioFormatMPEG4AAC;
    
    outAudioStreamBasicDescription.mFormatFlags = kMPEG4Object_AAC_LC;
    
    outAudioStreamBasicDescription.mBytesPerPacket = 0;
    
    outAudioStreamBasicDescription.mFramesPerPacket = 1024;
    
    outAudioStreamBasicDescription.mBytesPerFrame = 0;
    
    outAudioStreamBasicDescription.mChannelsPerFrame = 1;
    
    outAudioStreamBasicDescription.mBitsPerChannel = 0;
    
    outAudioStreamBasicDescription.mReserved = 0;
    
    AudioClassDescription * description = [self getAudioClassDescriptionWithType:kAudioFormatMPEG4AAC
                                                                fromManufacturer:kAppleSoftwareAudioCodecManufacturer];
    
    OSStatus status = AudioConverterNewSpecific(&inAudioStreamBasicDescription,
                                                &outAudioStreamBasicDescription,
                                                1,
                                                description,
                                                &_audioConverter);
    
    if (status != noErr) {
        NSLog(@"setup converter: %d",(int)status);
        
    }
}




- (AudioClassDescription *)getAudioClassDescriptionWithType:(UInt32)type
                                           fromManufacturer:(UInt32)manufacturer {
    
    static AudioClassDescription audioClassDescription;
    
    UInt32 encoderSpecifier = type;
    OSStatus status;
    
    UInt32 size;
    status = AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders,
                                        sizeof(encoderSpecifier),
                                        &encoderSpecifier,
                                        &size);
    
    if (status != noErr) {
        
        NSLog(@"error getting audio format property info: %d",(int)status);
        
        return nil;
    }
    
    unsigned int count = size / sizeof(AudioClassDescription);
    
    AudioClassDescription audioClassDescriptions[count];
    
    status = AudioFormatGetProperty(kAudioFormatProperty_Encoders,
                                    sizeof(encoderSpecifier),
                                    &encoderSpecifier,
                                    &size,
                                    audioClassDescriptions);
    
    if (status != noErr) {
        NSLog(@"error getting audio format property: %d",(int)status);
        return nil;
    }
    
    for (unsigned int i = 0; i < count; i++) {
        
        if (type == audioClassDescriptions[i].mSubType &&
            manufacturer == audioClassDescriptions[i].mManufacturer) {
            memcpy(&audioClassDescription, &(audioClassDescriptions[i]), sizeof(audioClassDescription));
            
            return &audioClassDescription;
        }
    }
    
    return nil;
}


static OSStatus inInputDataProc(AudioConverterRef inAudioConverter,
                                UInt32 *ioNumberDataPackets,
                                AudioBufferList *ioData,
                                AudioStreamPacketDescription **outDataPacketDescription,
                                void *inUserData) {
    
    AACEncoder * aacEncoder = (__bridge AACEncoder *) (inUserData) ;
    
    UInt32 requestedPackets = *ioNumberDataPackets;
    
    size_t copiedSamples = [aacEncoder copyPCMSamplesIntoBuffer:ioData];
    
    if (copiedSamples < requestedPackets) {
        
        *ioNumberDataPackets = 0;
        
        return -1;
    }
    
    *ioNumberDataPackets = 1;
    
    return noErr;
}


- (size_t)copyPCMSamplesIntoBuffer:(AudioBufferList *)ioData {
    
    size_t originalBufferSize = _pcmBufferSize;
    
    if (!originalBufferSize) {
        return 0;
    }
    
    ioData ->mBuffers[0].mData = _pcmBuffer;
    ioData ->mBuffers[0].mDataByteSize = (int)_pcmBufferSize;
    _pcmBuffer = NULL;
    _pcmBufferSize =0;
    
    return originalBufferSize;
}


- (void)encoderSampleBuffer:(CMSampleBufferRef)sampleBuffer
            completionBlock:(void(^)(NSData *encodeData,
                                     NSError *error))completionBlock {
    
    CFRetain(sampleBuffer);
    
    dispatch_async(_encoderQueue, ^{
        
        if (!_audioConverter) {
            [self setupEncoderFromSampleBuffer:sampleBuffer];
        }
        
        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
        CFRetain(blockBuffer);
        
        OSStatus status = CMBlockBufferGetDataPointer(blockBuffer,
                                                      0,
                                                      NULL,
                                                      &_pcmBufferSize,
                                                      &_pcmBuffer);
        
        NSError *error = nil;
        
        if (status != kCMBlockBufferNoErr) {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        
        memset(_aacBuffer, 0, _aacBufferSize);
        AudioBufferList outAudioBufferList = {0};
        outAudioBufferList.mNumberBuffers = 1;
        outAudioBufferList.mBuffers[0].mNumberChannels = 1;
        outAudioBufferList.mBuffers[0].mDataByteSize = (int)_aacBufferSize;
        outAudioBufferList.mBuffers[0].mData = _aacBuffer;
        AudioStreamPacketDescription *outPacketDescription = NULL;
        UInt32 ioOutputDataPacketSize = 1;
        status = AudioConverterFillComplexBuffer(_audioConverter, inInputDataProc, (__bridge void *)(self), &ioOutputDataPacketSize, &outAudioBufferList, outPacketDescription);
        //NSLog(@"ioOutputDataPacketSize: %d", (unsigned int)ioOutputDataPacketSize);
        NSData *data = nil;
        if (status == 0) {
            NSData *rawAAC = [NSData dataWithBytes:outAudioBufferList.mBuffers[0].mData length:outAudioBufferList.mBuffers[0].mDataByteSize];
            NSData *adtsHeader = [self adtsDataForPacketLength:rawAAC.length];
            NSMutableData *fullData = [NSMutableData dataWithData:adtsHeader];
            [fullData appendData:rawAAC];
            data = fullData;
        } else {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        if (completionBlock) {
            dispatch_async(_callBackQueue, ^{
            
                completionBlock(data, error);
            });
        }
        CFRelease(sampleBuffer);
        CFRelease(blockBuffer);
        
    });
}

- (NSData*)adtsDataForPacketLength:(NSUInteger)packetLength {
    int adtsLength = 7;
    char *packet = malloc(sizeof(char) * adtsLength);
    // Variables Recycled by addADTStoPacket
    int profile = 2;  //AAC LC
    //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
    int freqIdx = 4;  //44.1KHz
    int chanCfg = 1;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
    NSUInteger fullLength = adtsLength + packetLength;
    // fill in ADTS data
    packet[0] = (char)0xFF; // 11111111     = syncword
    packet[1] = (char)0xF9; // 1111 1 00 1  = syncword MPEG-2 Layer CRC
    packet[2] = (char)(((profile-1)<<6) + (freqIdx<<2) +(chanCfg>>2));
    packet[3] = (char)(((chanCfg&3)<<6) + (fullLength>>11));
    packet[4] = (char)((fullLength&0x7FF) >> 3);
    packet[5] = (char)(((fullLength&7)<<5) + 0x1F);
    packet[6] = (char)0xFC;
    NSData *data = [NSData dataWithBytesNoCopy:packet length:adtsLength freeWhenDone:YES];
    return data;
}

@end
