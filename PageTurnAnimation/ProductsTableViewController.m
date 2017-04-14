//
//  ProductsTableViewController.m
//  PageTurnAnimation
//
//  Created by Jimmy on 15/8/7.
//  Copyright (c) 2015年 Jimmy. All rights reserved.
//

#import "ProductsTableViewController.h"
#import "ProductCell.h"
#import "SKProduct+LocalizedPrice.h"
#import "PurchaseManager.h"
#import "AppDelegate.h"

@interface ProductsTableViewController ()

@end

@implementation ProductsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseFinished) name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseFailed) name:kInAppPurchaseManagerTransactionFailedNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self allProducts] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"product" forIndexPath:indexPath];
    
    // Configure the cell...
    SKProduct *product = self.allProducts[indexPath.row];
    cell.nameLabel.text = product.localizedTitle;
    cell.priceLabel.text = product.localizedPrice;
    
    [cell.buyButton addTarget:self action:@selector(buyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)buyBtnClick:(UIButton *)sender{
    ProductCell *cell ;
    if ([sender.superview.superview isKindOfClass:[ProductCell class]]) {
        cell = (ProductCell *)sender.superview.superview;
    }else{
        cell = (ProductCell *)sender.superview.superview.superview;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    SKProduct *product = self.allProducts[indexPath.row];
    
    selectedProduct = product;
    
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"确定买吗？" message:@"求求你买吧" delegate:self cancelButtonTitle:@"死开" otherButtonTitles:@"有钱，买",@"已买过", nil];
    [view show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (buttonIndex == alertView.cancelButtonIndex) {
        NSLog(@"不买就不买");
    }else if (buttonIndex == alertView.firstOtherButtonIndex){
        // buy
        [delegate startActive];
        if(selectedProduct){
            PurchaseManager *manager = [PurchaseManager shareManager];
            if ([manager canMakePurchases]) {
                [manager purchaseProUpgrade:selectedProduct];
            }
        }
    }else{
        // restore
        [delegate startActive];
        PurchaseManager *manager = [PurchaseManager shareManager];
        [manager restore];
    }
}

-(void)purchaseFinished{
    NSLog(@"yes");
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate stopActive];
}

-(void)purchaseFailed{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Purchases failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [delegate stopActive];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
