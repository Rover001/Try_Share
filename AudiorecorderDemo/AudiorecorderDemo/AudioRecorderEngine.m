//
//  AudioRecorderEngine.m
//  GaoDeDemo
//
//  Created by 心冷如灰 on 2016/12/29.
//  Copyright © 2016年 心冷如灰. All rights reserved.
//

#import "AudioRecorderEngine.h"

#import "lame.h"

#define kRecordAudioFile @"Audio.caf"
#define kRecordAudioMP3File @"Audio.mp3"
@interface AudioRecorderEngine ()<AVAudioRecorderDelegate>

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;/**< 录音对象 */
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;/**< 播放器对象  用于播放音频 */
@property (nonatomic,strong) AVPlayer *avPlayer;/**< 播放器对象  用于播放音频 */
@property (nonatomic,strong) AVPlayerItem * playerItem;
@property (nonatomic,strong) NSTimer *timer;/**< 定时器，用于监听录音声波的大小 */
@property (nonatomic,strong) NSTimer *playTimer;/**< 定时器，用于监听播放时间的 */

@property (nonatomic,strong) NSString *filePath;/**< 传进来的文件的名字 */

@end

@implementation AudioRecorderEngine

+ (AudioRecorderEngine *)sharedAudioRecorderEngine {
    static AudioRecorderEngine *sharedAudioRecorderEngineInstance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedAudioRecorderEngineInstance = [[AudioRecorderEngine alloc]init];
        sharedAudioRecorderEngineInstance.isChangeMP3 = YES;
        sharedAudioRecorderEngineInstance.audioPlayProgress = 0.0f;
        NSLog(@"sharedAudioRecorderEngineInstance");
    });
    return sharedAudioRecorderEngineInstance;
}

- (void)setAudioSaveFilePath:(NSString *)filePath  {
    _filePath = filePath;
}

- (void)removeAudio {
    NSString *path = [self.audioSavePath substringToIndex:(self.audioSavePath.length - kRecordAudioFile.length -1)];
    NSLog(@"%@",path);
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return;
    }
    [PathEngine removeFile:kRecordAudioFile path:path];
}

//删除文件
-(BOOL)removeFile:(NSString *)fileName path:(NSString *)path {
    BOOL ret = NO;
    NSString *fullFile = [NSString stringWithFormat:@"%@/%@", path, fileName];
    if ( [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        ret = [[NSFileManager defaultManager] removeItemAtPath:fullFile error:nil];
    } else {
        NSLog(@"%@ isn't exist, so can't remove!", fullFile);
    }
    return ret;
}

- (void)removeAudioMP3 {
    if (_audioMP3Path.length == 0) {
        return;
    }
    NSString *path = [self.audioMP3Path substringToIndex:(self.audioMP3Path.length - kRecordAudioMP3File.length -1)];
    NSLog(@"%@",path);
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return;
    }
    [PathEngine removeFile:kRecordAudioMP3File path:path];
    
}


- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        //1.设置录音存放地址的URL
        NSURL *url = [NSURL fileURLWithPath:[self setSavePath]];
        //2.设置录音的配置
        NSDictionary *soundSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:8000.0f],AVSampleRateKey,
                                      [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                                      [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                      [NSNumber numberWithInt:16],AVEncoderBitRateKey,
                                      nil];
        /*
         1.AVNumberOfChannelsKey 通道数 通常为双声道 值2
         2.AVSampleRateKey 采样率 单位HZ 通常设置成44100 也就是44.1k
         3.AVLinearPCMBitDepthKey 比特率 8 16 24 32
         4.AVEncoderAudioQualityKey 声音质量
         ① AVAudioQualityMin  = 0, 最小的质量
         ② AVAudioQualityLow  = 0x20, 比较低的质量
         ③ AVAudioQualityMedium = 0x40, 中间的质量
         ④ AVAudioQualityHigh  = 0x60,高的质量
         ⑤ AVAudioQualityMax  = 0x7F 最好的质量
         5.AVEncoderBitRateKey 音频编码的比特率 单位Kbps 传输的速率 一般设置128000 也就是128kbps
         
         */
        //3.错误信息
        NSError *error = nil;
        
        _audioRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:soundSetting error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;//如果要监控声波则必须设置为YES
        
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}



/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

/**
 *  录音声波状态设置
 */
-(void)audioPowerChange{
    [self.audioRecorder updateMeters];//更新测量值
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    CGFloat progress= (1.0/160.0)*(power+160.0);
    //    NSLog(@"power ===== %f progress==== %f",power,progress);
    if (self.soundWaveBlock) {
        self.soundWaveBlock (progress);
    }
}

- (NSString *)setSavePath {
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    if (self.filePath.length >0) {
        path =   [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", self.filePath]];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path]) //如果不存在
        
    {
        NSMutableString *tmpPath = [[NSMutableString alloc] initWithCapacity:1];
        NSArray *dirs = [path componentsSeparatedByString:@"/"];
        [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ( ![obj isEqualToString:@""] ) {
                [tmpPath appendFormat:@"/%@", obj];
                if ( ![fileManager fileExistsAtPath:tmpPath] ) {
                    [fileManager createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:nil];
                }
            }
        }];
        
    }else{
        NSLog(@"xxx.txt is  exist");
        
    }
    path=[path stringByAppendingPathComponent:kRecordAudioFile];
    
    NSLog(@"file path:%@",path);
    _audioSavePath = path;
    
    return path;
}



#pragma mark -- 录音机代理方法
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    //    NSLog(@"%f",recorder.currentTime);
    //    NSLog(@"%f",recorder.deviceCurrentTime);
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.audioSavePath] options:nil];
    CMTime audioDuration = audioAsset.duration;
    _audioDurationTime = CMTimeGetSeconds(audioDuration);
    //    NSLog(@"audioDurationSeconds========%lld",self.audioDurationTime);
    //    NSLog(@"audioDurationSeconds>>========%f",ceilf(self.audioDurationTime));
    NSLog(@"%lu",[NSData dataWithContentsOfFile:self.audioSavePath].length);
    _audioData = [NSData dataWithContentsOfFile:self.audioSavePath];
    _audioPath = self.audioSavePath;
    
    if (self.isChangeMP3) {
        [self audioToMP3:_audioPath];
    }
    NSLog(@"录音完成!");
    if (self.finishBlcok) {
        self.finishBlcok();
    }
    
}

- (void)audioToMP3:(NSString *)audioPath {
    
    if ([PathEngine isExistFile:audioPath]) {
        // 输出路径
        NSString *outPath = [[audioPath stringByDeletingPathExtension] stringByAppendingString:@".mp3"];
        
        
        @try {
            size_t read, write;
            
            FILE *pcm = fopen([audioPath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
            fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
            FILE *mp3 = fopen([outPath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_num_channels(lame, 2);//设置1为单通道，默认为2双通道
            lame_set_in_samplerate(lame, 8000.0);//11025.0
            //lame_set_VBR(lame, vbr_default);
            lame_set_brate(lame, 16);
            lame_set_mode(lame, 3);
            lame_set_quality(lame, 2); /* 2=high 5 = medium 7=low 音质*/
            lame_init_params(lame);
            
            do{
                read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0) {
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                }else{
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, (int)read, mp3_buffer, MP3_SIZE);
                }
                
                fwrite(mp3_buffer, write, 1, mp3);
                
                
            }while (read!=0);
            
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        }
        @finally {
            
            [self removeAudio];
            _audioMP3Path = outPath;
            
            NSLog(@"MP3生成成功%lu",[NSData dataWithContentsOfFile:outPath].length);
            if (self.changMP3FinishBlcok) {
                self.changMP3FinishBlcok();
            }
        }
    }
}

/**
 停止录音
 */
- (void)audioRecorderStop {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];  //此处需要恢复设置回放标志，否则会导致其它播放声音也会变小
    [session setActive:YES error:nil];
    if ([self.audioRecorder isRecording] == YES) {
        [self.audioRecorder stop];
    }
    [self.timer invalidate];
    self.timer = nil;
    self.filePath = @"";
    
}
/**
 开始录音
 */

- (void)audioRecorderPlay {
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    if (![self.audioRecorder isRecording]) {
        if ([self.audioRecorder prepareToRecord]) {
            [self.audioRecorder record];
            self.timer.fireDate=[NSDate distantPast];
        }
    }
}




/**
 *  取得录音文件设置  没有使用
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    //    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000.0f) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(2) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}



#pragma mark -- 播放录音

- (AVPlayer *)avPlayer {
    if (!_avPlayer) {
        _avPlayer = [[AVPlayer alloc]init];
        _avPlayer.volume = 1.0f;
    }
    _avPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
    NSLog(@"%lld",_avPlayer.currentItem.duration.value/_avPlayer.currentItem.duration.timescale);
    NSLog(@"%lld",_avPlayer.currentTime.value);
    return _avPlayer;
}


- (NSTimer *)playTimer {
    if (!_playTimer) {
        _playTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPlayTime) userInfo:nil repeats:YES];
    }
    return _playTimer;
}


#pragma mark -- 设置AVPlayerItem 对象
- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
    }
    
    _playerItem = playerItem;
    
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(playerItemDidReachEnd)
     
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
     
                                               object:self.playerItem];
    
}

- (void)audioPlayTime {
    //    NSLog(@"audioPlayTime === %f  %f  %f",CMTimeGetSeconds(self.playerItem.currentTime),CMTimeGetSeconds(self.playerItem.duration), CMTimeGetSeconds(self.playerItem.currentTime) / CMTimeGetSeconds(self.playerItem.duration));
    double progress = CMTimeGetSeconds(self.playerItem.currentTime) / CMTimeGetSeconds(self.playerItem.duration);
    if (progress) {
        self.audioPlayProgress = progress;
        if (self.audioPlayProgressBlock) {
            self.audioPlayProgressBlock(progress);
        }
    }
}

#pragma mark -- 播放结束监听
- (void)playerItemDidReachEnd {
    NSLog(@"playerItemDidReachEnd 音乐播放完成...");
    if (self.audioPlayFinishBlock) {
        self.audioPlayFinishBlock();
    }
    [self audioStop];
}

#pragma mark -- 监听播放状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        NSLog(@"%@",change);
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerStatusReadyToPlay){
            NSLog(@"开始播放,总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            self.playTimer.fireDate = [NSDate distantPast];
            //            self.timer.fireDate=[NSDate distantPast];
        }else if(status == AVPlayerStatusUnknown){
            NSLog(@"%@",@"AVPlayerStatusUnknown");
            [self playerItemDidReachEnd];
        }else if (status == AVPlayerStatusFailed){
            NSLog(@"%@",@"AVPlayerStatusFailed");
            [self playerItemDidReachEnd];
            
        }
    }
}



- (void)audioPlay {
    
    //在这里因为是播放的是本地文件  所以[NSURL fileURLWithPath:self.audioPath]
    //1.如果
    
    //如果你播放的是网络音频，请传入一个Url 使用[NSURL URLWithString:self.networkAudioPath]
    NSURL * url;
    if (self.isPlayNetwork) {
        //        url = [NSURL URLWithString:self.networkAudioPath];
        url = [NSURL URLWithString: [self.networkAudioPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else {
        url = [NSURL fileURLWithPath:self.audioPath];
    }
    AVPlayerItem * item = [AVPlayerItem playerItemWithURL:url];
    self.playerItem = item;
    [self.avPlayer play];
}



- (void)audioStop {
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _avPlayer = nil;
    _audioPlayer = nil;
    _playerItem = nil;
    _networkAudioPath = kMNullStr;
    _audioPath = kMNullStr;
    [self.playTimer invalidate];
    self.playTimer = nil;
}






@end
