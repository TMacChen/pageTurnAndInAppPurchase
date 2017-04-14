//
//  PurchaseManager.m
//  PageTurnAnimation
//
//  Created by Jimmy on 15/8/6.
//  Copyright (c) 2015年 Jimmy. All rights reserved.
//

#import "PurchaseManager.h"
#import "ProductsTableViewController.h"

@implementation PurchaseManager
static PurchaseManager *manager;

+(PurchaseManager *)shareManager{
    if (!manager) {
        manager = [[PurchaseManager alloc] init];
    }
    return manager;
}

- (void)loadStore
{
    // get the product description (defined in early sections)
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    [self requestProUpgradeProductData];
}

- (void)requestProUpgradeProductData
{
    NSArray *productIds = [NSArray arrayWithObjects:ProductIdA,ProductIdB,ProductIdC,ProductIdD,nil];
    NSSet *productIdentifiers = [NSSet setWithArray:productIds];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
    // we will release the request object in the delegate callback
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response NS_AVAILABLE_IOS(3_0){
    NSArray *products = response.products;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:products,@"products", nil];
    NSLog(@"products:%lu",(unsigned long)[products count]);
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:nil userInfo:dic];
}

- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

- (void)purchaseProUpgrade:(SKProduct *)product
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
//    if ([transaction.payment.productIdentifier isEqualToString:ProductIdA])
//    {
//        // save the transaction receipt to disk
//        [[NSUserDefaults standardUserDefaults] setValue:[[NSBundle mainBundle] appStoreReceiptURL] forKey:@"isBought"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
}
//
// enable pro features
//

    
- (void)downloadContent:(SKPaymentTransaction *)transaction
{
    // start download
    [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads{
    for (SKDownload *download in downloads) {
        if (download.downloadState == SKDownloadStateFinished) {
            [self processDownload:download]; // not written yet
            [queue finishTransaction:download.transaction];
        } else if (download.downloadState == SKDownloadStateActive) {
            NSString *productID = download.contentIdentifier; // in app purchase identifier
            NSTimeInterval remaining = download.timeRemaining; // secs
            float progress = download.progress; // 0.0 -> 1.0
            NSLog(@"progress: %f, id: %@",progress,download.contentIdentifier);
            
            // NOT SHOWN: use the productID to notify your model of download progress...
            
        } else {
            NSLog(@"Warn: not handled: %ld", (long)download.downloadState);
        }
    }
    
}

- (void) processDownload:(SKDownload*)download;
{
    
    NSLog(@"finish");
//    // convert url to string, suitable for NSFileManager
//    NSString *path = [download.contentURL path];
//    
//    // files are in Contents directory
//    path = [path stringByAppendingPathComponent:@"Contents"];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSError *error = nil;
//    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:&error];
//    NSString *dir = [PurchaseManager downloadableContentPathForProductId:download.contentIdentifier]; // not written yet
//    
//    for (NSString *file in files) {
//        NSString *fullPathSrc = [path stringByAppendingPathComponent:file];
//        NSString *fullPathDst = [dir stringByAppendingPathComponent:file];
//        
//        // not allowed to overwrite files - remove destination file
//        [fileManager removeItemAtPath:fullPathDst error:NULL];
//        
//        if ([fileManager moveItemAtPath:fullPathSrc toPath:fullPathDst error:&error] == NO) {
//            NSLog(@"Error: unable to move item: %@", error);
//        }
//    }
    
    // NOT SHOWN: use download.contentIdentifier to tell your model that we've been downloaded
}

+ (NSString *) downloadableContentPath;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    directory = [directory stringByAppendingPathComponent:@"Downloads"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:directory] == NO) {
        
        NSError *error;
        if ([fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
            NSLog(@"Error: Unable to create directory: %@", error);
        }
        
        NSURL *url = [NSURL fileURLWithPath:directory];
        // exclude downloads from iCloud backup
        if ([url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error] == NO) {
            NSLog(@"Error: Unable to exclude directory from backup: %@", error);
        }
    }
    
    return directory;
}


//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    NSLog(@"user info:%@",transaction.error);
    
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        if (transaction.transactionState != SKPaymentTransactionStateRestored) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
        }
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}
//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"123");
    
    [self recordTransaction:transaction];
    if (transaction.downloads) {
        [self downloadContent:transaction];
    }else{
        [self finishTransaction:transaction wasSuccessful:YES];
    }
}
//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    if (transaction.downloads) {
        [self downloadContent:transaction];
    }else{
        [self finishTransaction:transaction wasSuccessful:YES];
    }
}
//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    [self finishTransaction:transaction wasSuccessful:NO];
    
    // this is fine, the user just cancelled, so don’t notify
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)restore{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:nil];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:nil];
}

@end
