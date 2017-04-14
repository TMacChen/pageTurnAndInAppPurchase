//
//  PurchaseManager.h
//  PageTurnAnimation
//
//  Created by Jimmy on 15/8/6.
//  Copyright (c) 2015年 Jimmy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"


#define ProductIdA @"com.jimmy.productA"
#define ProductIdB @"com.jimmy.productB"
#define ProductIdC @"com.jimmy.productC"
#define ProductIdD @"com.jimmy.productD"

@interface PurchaseManager : NSObject<SKRequestDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver>{
    SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;
}

+(PurchaseManager *)shareManager;
-(void)requestProUpgradeProductData;
- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseProUpgrade:(SKProduct *)product;
- (void)restore;

@end
