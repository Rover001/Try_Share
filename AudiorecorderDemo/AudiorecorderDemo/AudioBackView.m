//
//  AudioBackView.m
//  MaoZhua
//
//  Created by 心冷如灰 on 16/11/7.
//  Copyright © 2016年 心冷如灰. All rights reserved.
//

#import "AudioBackView.h"

#define  AudioWidth  self.frame.size.width
#define  AudioHeight self.frame.size.height
@interface AudioBackView ()
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) NSArray *images;
@end

@implementation AudioBackView

- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images {
    self = [super initWithFrame:frame];
    if (self) {
        self.images = images;
        [self setSubVies];
        
    }
    return self;
}

- (void)setSubVies {
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake((AudioWidth-80)/2, (AudioHeight-80)/2, 80, 80)];
    view.layer.cornerRadius = 5.0f;
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:view];
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake((view.frame.size.width-37)/2, (view.frame.size.height-40)/2, 37, 40.0f)];
    self.imageView.image = [UIImage imageNamed:self.images[0]];
    [view addSubview:self.imageView];
}
- (void)setProgress:(float)progress {
    _progress = progress;
   NSInteger i = floor(_progress/(1.0/(float)self.images.count));
//    UIImage *image = [UIImage imageNamed:self.images[0]];
//    if (0<_progress<=0.2) {
//        image = [UIImage imageNamed:self.images[1]];
//    } else if (0.2<_progress<=0.4) {
//        image = [UIImage imageNamed:self.images[2]];
//    } else if (0.4<_progress<=0.6) {
//        image = [UIImage imageNamed:self.images[3]];
//    } else if (0.6<_progress<=0.8) {
//        image = [UIImage imageNamed:self.images[4]];
//    } else if (0.75<_progress<=0.9) {
//        image = [UIImage imageNamed:self.images[5]];
//    } else if (0.9<_progress<=1.0) {
//        image = [UIImage imageNamed:self.images[6]];
//    }
    i = i-1;
    if (i<0) {
        i=0;
    }
    self.imageView.image = [UIImage imageNamed:self.images[i]];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
