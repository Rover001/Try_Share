//
//  AudioBackView.h
//  MaoZhua
//
//  Created by 心冷如灰 on 16/11/7.
//  Copyright © 2016年 心冷如灰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioBackView : UIView
@property (nonatomic,assign) float progress;


/*
 注意 这个控件 只是满足我自己的，可以自定制
 */
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images NS_DESIGNATED_INITIALIZER;


@end
