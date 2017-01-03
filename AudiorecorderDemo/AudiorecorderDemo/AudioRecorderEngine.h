//
//  AudioRecorderEngine.h
//  GaoDeDemo
//
//  Created by 心冷如灰 on 2016/12/29.
//  Copyright © 2016年 心冷如灰. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

typedef void(^AudioRecorderEngineSoundWaveBlock) (float progress);
typedef void(^AudioRecorderEngineFinishBlock) ();

@interface AudioRecorderEngine : NSObject

#pragma mark -- 录制音频对象
@property (nonatomic,readonly)NSString *audioSavePath;/**< 存放录音的地址 */
@property (nonatomic,readonly)NSData *audioData;/**< 录音文件大小 */
@property (nonatomic,readonly)AVAudioRecorder *audioRecorder;/**< 录音播放对象 */
@property (assign, nonatomic,readonly) long long audioDurationTime;/**< 录制时长 */


#pragma mark -- 播放音频对象
@property (nonatomic,strong) NSString *networkAudioPath;/**< 网络文件地址 */
@property (nonatomic,strong) NSString *audioPath;/**< 本地文件地址 */
@property (nonatomic,assign) BOOL isPlayNetwork;/**< 默认播放录制本地  YES 播放网络音频  */



@property (nonatomic,copy)AudioRecorderEngineSoundWaveBlock soundWaveBlock;/**< 返回声波的大小 */
@property (nonatomic,copy)AudioRecorderEngineFinishBlock finishBlcok;/**< 录制完成时候 */

+ (AudioRecorderEngine *)sharedAudioRecorderEngine;

/**
 这个方法是为了给自定义存储位置准备的   
 如果需要自定义的话  就必须先实现这个方法
 如果等AudioRecorder对象创建完成时候，不允许修改的

 @param filePath document 后面的文件路径   最后是以Audio.caf结尾
 */
- (void)setAudioSaveFilePath:(NSString *)filePath;/**< 自定义路径 存储录音文件 */

/**
 删除录制 或者其他本地的录音
 */
- (void)removeAudio;



- (void)audioRecorderPlay;/**< 开始录音 */
- (void)audioRecorderStop;/**< 结束录音 */


- (void)audioPlay;/**< 播放录音 */
- (void)audioStop;/**< 结束播放 */

@end
