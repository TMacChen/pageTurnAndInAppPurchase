//
//  ProductCell.m
//  PageTurnAnimation
//
//  Created by Jimmy on 15/8/7.
//  Copyright (c) 2015年 Jimmy. All rights reserved.
//

#import "ProductCell.h"

@implementation ProductCell

- (void)awakeFromNib {
    // Initialization code
    [self.progressView setHidden:YES];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
