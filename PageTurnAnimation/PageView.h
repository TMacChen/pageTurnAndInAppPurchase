//
//  PageView.h
//  PageTurnAnimation
//
//  Created by Jimmy on 15/8/6.
//  Copyright (c) 2015年 Jimmy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PageView : UIView<UIAlertViewDelegate>{
    
}

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSString *audioUrl;

- (void)playAudio;
- (void)stopAudio;

@end
