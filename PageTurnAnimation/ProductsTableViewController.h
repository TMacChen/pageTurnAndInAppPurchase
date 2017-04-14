//
//  ProductsTableViewController.h
//  PageTurnAnimation
//
//  Created by Jimmy on 15/8/7.
//  Copyright (c) 2015年 Jimmy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface ProductsTableViewController : UITableViewController<UIAlertViewDelegate>{
    SKProduct *selectedProduct;
}

@property (nonatomic ,strong) NSArray *allProducts;

@end
