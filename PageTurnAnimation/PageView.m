//
//  PageView.m
//  PageTurnAnimation
//
//  Created by Jimmy on 15/8/6.
//  Copyright (c) 2015年 Jimmy. All rights reserved.
//

#import "PageView.h"
#import "PurchaseManager.h"

@implementation PageView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


- (void)setAudioUrl:(NSString *)audioUrl{
    _audioUrl = audioUrl;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:_audioUrl] error:nil];
}

- (void)playAudio{
    if (_audioPlayer != nil) {
        if (![_audioPlayer isPlaying]) {
            [_audioPlayer setCurrentTime:0];
            [_audioPlayer play];
        }
    }
}

- (void)stopAudio{
    if (_audioPlayer != nil) {
        if ([_audioPlayer isPlaying]) {
            [_audioPlayer stop];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
