//
//  ViewController.h
//  PageTurnAnimation
//
//  Created by Jimmy on 15/8/6.
//  Copyright (c) 2015年 Jimmy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageView.h"

@interface ViewController : UIViewController<UIAlertViewDelegate>{
    NSArray *pagesArray;
    NSUInteger currentPageIndex;
    
    PageView *leftPage;
    PageView *currentPage;
    PageView *rightPage;
}

@end

