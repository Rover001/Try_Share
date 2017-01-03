//
//  ViewController.m
//  AudiorecorderDemo
//
//  Created by 心冷如灰 on 2016/12/29.
//  Copyright © 2016年 心冷如灰. All rights reserved.
//

#import "ViewController.h"
#import "AudioBackView.h"
#import "AudioRecorderEngine.h"

@interface ViewController ()

@property (nonatomic,strong) AudioBackView *audioBackView;
- (IBAction)audioRecorderPlay:(UIButton *)sender;
- (IBAction)audioRecorderStop:(UIButton *)sender;
- (IBAction)audioPlay:(UIButton *)sender;
- (IBAction)audioStop:(UIButton *)sender;




@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"音频录制以及播放";
    // Do any additional setup after loading the view, typically from a nib.
}
- (AudioBackView *)audioBackView {
    if (_audioBackView == nil) {
        _audioBackView = [[AudioBackView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50) images:[NSArray arrayWithObjects:@"contact_voice_one",@"contact_voice_two",@"contact_voice_three",@"contact_voice_four",@"contact_voice_five",@"contact_voice_six",@"contact_voice_seven", nil]];
        
    }
    return _audioBackView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)audioRecorderPlay:(UIButton *)sender {
    
    NSLog(@"点击录音开始");
    [[AudioRecorderEngine sharedAudioRecorderEngine] setAudioSaveFilePath:@"test/hhh/kkk/rrr"];
    NSLog(@"%d",[AudioRecorderEngine sharedAudioRecorderEngine].audioRecorder.isRecording);
    if (![AudioRecorderEngine sharedAudioRecorderEngine].audioRecorder.isRecording) {
        [self.view addSubview:self.audioBackView];
        //开始录制
        [[AudioRecorderEngine sharedAudioRecorderEngine] audioRecorderPlay];
        
        //录制中返回的声波
        [AudioRecorderEngine sharedAudioRecorderEngine].soundWaveBlock = ^(float progress){
            self.audioBackView.progress = progress;
        };
    }
    

}

- (IBAction)audioRecorderStop:(UIButton *)sender {
    [self.audioBackView removeFromSuperview];
    //停止录制
    [[AudioRecorderEngine sharedAudioRecorderEngine] audioRecorderStop];
    
    //录制完成回调
    [AudioRecorderEngine sharedAudioRecorderEngine].finishBlcok = ^(){
        NSLog(@"%@  %lu  %lld",[AudioRecorderEngine sharedAudioRecorderEngine].audioSavePath,[AudioRecorderEngine sharedAudioRecorderEngine].audioData.length,[AudioRecorderEngine sharedAudioRecorderEngine].audioDurationTime);
    };
}

- (IBAction)audioPlay:(UIButton *)sender {
    [[AudioRecorderEngine sharedAudioRecorderEngine] audioPlay];
}

- (IBAction)audioStop:(UIButton *)sender {
    [[AudioRecorderEngine sharedAudioRecorderEngine] audioStop];
    [[AudioRecorderEngine sharedAudioRecorderEngine]removeAudio];
}
@end
