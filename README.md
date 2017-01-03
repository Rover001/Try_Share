
# IOS 音频录制 播放

`简单一句代码搞定`   `AVAudioRecorder 录制`   `AVPlayer  播放本地网络音频`

**AudioRecorderEngine**是一个单例类；
- 控制着音频录制播放，高效快捷；
- 自定制文件存储路径，删除文件；
- 播放本地、网络音频，一句话搞定。



[TOC]

##AudioRecorderEngine 介绍

> 音频录制

**音频开始录制：** [[AudioRecorderEngine sharedAudioRecorderEngine] audioRecorderPlay];

**音频结束录制：**[[AudioRecorderEngine sharedAudioRecorderEngine] audioRecorderStop];

`注意`：如果自定制录制文件存储位置，首先要设置文件的路径 [[AudioRecorderEngine sharedAudioRecorderEngine] setAudioSaveFilePath:`[这里是文件存储的路径地址]`];

>音频播放

**开始播放：**[[AudioRecorderEngine sharedAudioRecorderEngine] audioPlay];

**结束播放：**[[AudioRecorderEngine sharedAudioRecorderEngine] audioStop];
