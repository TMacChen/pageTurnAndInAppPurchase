//
//  ViewController.m
//  PageTurnAnimation
//
//  Created by Jimmy on 15/8/6.
//  Copyright (c) 2015年 Jimmy. All rights reserved.
//

#import "ViewController.h"
#import "BookPage.h"
#import "PurchaseManager.h"
#import "ProductsTableViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (nonatomic,retain) PageView *leftPage;

@property (nonatomic,retain) PageView *currentPage;

@property (nonatomic,retain) PageView *rightPage;

@property(nonatomic, copy) void(^animationCompletionBlock)(void);

@end

@implementation ViewController
@synthesize leftPage;
@synthesize currentPage;
@synthesize rightPage;
@synthesize animationCompletionBlock;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    BookPage *page1 = [[BookPage alloc]init];
    page1.narrationName = @"1.m4a";
    page1.turnAnimation = YES;
    page1.bgColor = [UIColor redColor];
    
    BookPage *page2 = [[BookPage alloc]init];
    page2.narrationName = @"2.m4a";
    page2.turnAnimation = YES;
    page2.bgColor = [UIColor blueColor];
    
    BookPage *page3 = [[BookPage alloc]init];
    page3.narrationName = @"3.m4a";
    page3.turnAnimation = YES;
    page3.bgColor = [UIColor greenColor];
    
    pagesArray = [NSArray arrayWithObjects:page1,page2,page3, nil];
    currentPageIndex = 0;
    
    if ([pagesArray count] > currentPageIndex) {
        if (currentPageIndex > 0) {
            self.leftPage = [self loadPageView:pagesArray[currentPageIndex-1]];
            [self.view addSubview:leftPage];
        }
        self.currentPage = [self loadPageView:pagesArray[currentPageIndex]];
        
        [self.view addSubview:currentPage];
        if ([pagesArray count] > currentPageIndex+1) {
            self.rightPage = [self loadPageView:pagesArray[currentPageIndex+1]];
            [self.view addSubview:rightPage];
        }
        [self.view bringSubviewToFront:currentPage];
    }
    [currentPage playAudio];
    
    UISwipeGestureRecognizer *swipe;
    
    swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePage:)];
    [swipe setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:swipe];
    
    swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipePage:)];
    [swipe setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:swipe];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getListFinished:) name:kInAppPurchaseManagerProductsFetchedNotification object:nil];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"客官请买" style:UIBarButtonItemStylePlain target:self action:@selector(buyClick)];
    [self.navigationItem setRightBarButtonItem:item];
}


- (void)buyClick{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate startActive];
    PurchaseManager *manager = [PurchaseManager shareManager];
    [manager loadStore];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.currentPage) {
        [self.currentPage stopAudio];
    }
}

- (void)getListFinished:(NSNotification *)notification{
    NSArray *products = notification.userInfo[@"products"];
    
    NSLog(@"count: %lu",(unsigned long)[products count]);
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate stopActive];
    
    ProductsTableViewController *table = [self.storyboard instantiateViewControllerWithIdentifier:@"tableViewPage"];
    table.allProducts = products;
    [self.navigationController pushViewController:table animated:YES];
}

- (PageView *)loadPageView:(BookPage *)bookPage {
    PageView *pageView = [[PageView alloc] initWithFrame:self.view.bounds];
    [pageView setAudioUrl:[NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourceURL],bookPage.narrationName]];
    [pageView setBackgroundColor:bookPage.bgColor];
    return pageView;
}


- (void)swipePage:(UISwipeGestureRecognizer *)recognizer{
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (currentPageIndex >= [pagesArray count] - 1) {
            UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"Last page" message:@"This is the last page" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [view show];
            return;
        }
    }else{
        if (currentPageIndex <= 0) {
            UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"First page" message:@"This is the first page" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [view show];
            return;
        }
    }
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 1.0f;
    animation.timingFunction = UIViewAnimationOptionTransitionNone;
    [animation setRemovedOnCompletion:YES];
    PageView *fromView, *toView;

    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        currentPageIndex ++;
        
        self.leftPage = currentPage;
        self.currentPage = rightPage;
        if (currentPageIndex < [pagesArray count]-1) {
            self.rightPage = [self loadPageView:pagesArray[currentPageIndex+1]];
        }
        
        fromView = leftPage;
        toView = currentPage;
        
        BookPage *toPage = pagesArray[currentPageIndex];
        if (!toPage.turnAnimation) {
            animation = nil;
        } else {
            animation.type = @"pageCurl";
            animation.subtype = kCATransitionFromRight;
        }
    }else{
        currentPageIndex --;
        
        self.rightPage = currentPage;
        self.currentPage = leftPage;
        if (currentPageIndex > 0) {
            self.leftPage = [self loadPageView:pagesArray[currentPageIndex-1]];
        }
        
        fromView = rightPage;
        toView = currentPage;
        
        BookPage *toPage = pagesArray[currentPageIndex];
        if (!toPage.turnAnimation) {
            animation = nil;
        } else {
            animation.type = @"pageUnCurl";
            animation.subtype = kCATransitionFromRight;
        }
    }
    
    [fromView stopAudio];
    
    if (self.animationCompletionBlock != nil) {
        [self setAnimationCompletionBlock:nil];
    }
    [self setAnimationCompletionBlock:^(void){
        [toView playAudio];
    }];
    
    [self.view.layer addAnimation:animation forKey:nil];
    [self.view insertSubview:toView aboveSubview:fromView];
    [fromView removeFromSuperview];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    animationCompletionBlock();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
