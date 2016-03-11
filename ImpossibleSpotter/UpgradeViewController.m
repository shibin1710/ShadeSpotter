//
//  UpgradeViewController.m
//  ImpossibleSpotter
//
//  Created by Shibin S on 26/07/15.
//  Copyright (c) 2015 Shibin S. All rights reserved.
//

#import "UpgradeViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface UpgradeViewController ()
{
    SKProductsRequest *productsRequest;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *upgradeActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *restorePurchaseButton;

@property (weak, nonatomic) IBOutlet UIButton *upgradeButton;

@end

@implementation UpgradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.upgradeButton.layer.cornerRadius = 5;
    self.restorePurchaseButton.layer.cornerRadius = 5;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
 
}
*/

- (IBAction)restoreButtonClicked:(id)sender {
    self.upgradeActivityIndicator.color = [UIColor colorWithRed:0.0/255.0 green:120.0/255.0 blue:0.0/255.0 alpha:1.0];
    [self.upgradeActivityIndicator startAnimating];
    self.upgradeButton.userInteractionEnabled = NO;
    self.restorePurchaseButton.userInteractionEnabled = NO;
    [self restorePurchase];
}
- (IBAction)purchaseButtonClicked:(id)sender
{
    self.upgradeActivityIndicator.color = [UIColor redColor];
    self.upgradeButton.userInteractionEnabled = NO;
    self.restorePurchaseButton.userInteractionEnabled = NO;
    [self.upgradeActivityIndicator startAnimating];
    [self removeAds];
}
- (IBAction)closeButtonClicked:(id)sender
{
    [self.view removeFromSuperview];
    if (productsRequest) {
        [productsRequest cancel];
    }
    self.upgradeButton.userInteractionEnabled = YES;
    self.restorePurchaseButton.userInteractionEnabled = YES;
    [self.upgradeActivityIndicator stopAnimating];
}

- (void)removeAds
{
    if([SKPaymentQueue canMakePayments]){
        productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"ShadeSpotterPro"]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        self.upgradeButton.userInteractionEnabled = YES;
        self.restorePurchaseButton.userInteractionEnabled = YES;
        [self.upgradeActivityIndicator stopAnimating];
        NSLog(@"User cannot make payments due to parental controls");
//        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Sorry, Unable to make payments." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [errorAlert show];
        // Here we need to pass a full frame
        CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
        
        // Add some custom content to the alert view
        [alertView setContainerView:[self createDemoViewForTag:33]];
        
        // Modify the parameters
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK", nil]];
        [alertView setDelegate:self];
        alertView.tag = 33;
        
        // You may use a Block, rather than a delegate.
        [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex)
         {
             [alertView close];
         }];
        
        [alertView setUseMotionEffects:true];
        
        // And launch the dialog
        [alertView show];
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = (int)[response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        self.upgradeButton.userInteractionEnabled = YES;
        self.restorePurchaseButton.userInteractionEnabled = YES;
        [self.upgradeActivityIndicator stopAnimating];
//        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Sorry, Unable to purchase now. Please try later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [errorAlert show];
        
        // Here we need to pass a full frame
        CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
        
        // Add some custom content to the alert view
        [alertView setContainerView:[self createDemoViewForTag:34]];
        
        // Modify the parameters
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK", nil]];
        [alertView setDelegate:self];
        alertView.tag = 34;
        
        // You may use a Block, rather than a delegate.
        [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex)
         {
             [alertView close];
         }];
        
        [alertView setUseMotionEffects:true];
        
        // And launch the dialog
        [alertView show];
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product
{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePurchase
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        if(SKPaymentTransactionStateRestored){
            NSLog(@"Transaction state -> Restored");
            //called when the user successfully restores a purchase
            [self doRemoveAds];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Your purchase has been restored. Enjoy the game." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [errorAlert show];
            
            // Here we need to pass a full frame
            CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
            
            // Add some custom content to the alert view
            [alertView setContainerView:[self createDemoViewForTag:35]];
            
            // Modify the parameters
            [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK", nil]];
            [alertView setDelegate:self];
            alertView.tag = 35;
            
            // You may use a Block, rather than a delegate.
            [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex)
             {
                 [alertView close];
             }];
            
            [alertView setUseMotionEffects:true];
            
            // And launch the dialog
            [alertView show];
            //this is called if your product id is not valid, this shouldn't be called unless that happens.
//            [self.homeTableView reloadData];
//            [self.playTableView reloadData];
            break;
        }
        
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    self.upgradeButton.userInteractionEnabled = YES;
    self.restorePurchaseButton.userInteractionEnabled = YES;
    [self.upgradeActivityIndicator stopAnimating];
//    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Sorry, Unable to restore purchase now. Please try later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [errorAlert show];
    
    // Here we need to pass a full frame
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createDemoViewForTag:36]];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK", nil]];
    [alertView setDelegate:self];
    alertView.tag = 36;
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex)
     {
         [alertView close];
     }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
//    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Purchase was successful. Enjoy the game." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    // Here we need to pass a full frame
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createDemoViewForTag:37]];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK", nil]];
    [alertView setDelegate:self];
    alertView.tag = 37;
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex)
     {
         [alertView close];
     }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    for(SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                
                [alertView show];
//                [self.homeTableView reloadData];
//                [self.playTableView reloadData];
                [self doRemoveAds]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                self.upgradeButton.userInteractionEnabled = YES;
                self.restorePurchaseButton.userInteractionEnabled = YES;
                [self.upgradeActivityIndicator stopAnimating];
                //called when the transaction does not finnish
                if(transaction.error.code != SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    
//                    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Kuku Kube" message:@"Sorry, Unable to purchase now. Please try later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                    [errorAlert show];
                    // Here we need to pass a full frame
                    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
                    
                    // Add some custom content to the alert view
                    [alertView setContainerView:[self createDemoViewForTag:38]];
                    
                    // Modify the parameters
                    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK", nil]];
                    [alertView setDelegate:self];
                    alertView.tag = 38;
                    
                    // You may use a Block, rather than a delegate.
                    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex)
                     {
                         [alertView close];
                     }];
                    
                    [alertView setUseMotionEffects:true];
                    [alertView show];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                break;
               
            case SKPaymentTransactionStateDeferred:
                break;
        }
    }
}

- (void)doRemoveAds
{
    self.upgradeButton.userInteractionEnabled = YES;
    self.restorePurchaseButton.userInteractionEnabled = YES;
    [self.upgradeActivityIndicator stopAnimating];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFullVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"purchased" object:nil];
}

#pragma mark - Custom Alerts

- (UIView *)createDemoViewForTag:(int)tag
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 100)];
    switch (tag)
    {
        case 34:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 100)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:18];
            label.textColor = [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
            label.text = @"Sorry, Unable to purchase now. Please try later.";
            [demoView addSubview:label];
        }
            break;
        case 33:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 100)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:18];
            label.textColor = [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
            label.text = @"Sorry, Unable to make payments.";
            [demoView addSubview:label];
        }
            break;
        case 35:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 100)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:18];
            label.textColor = [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
            label.text =  @"Your purchase has been restored. Enjoy the game.";
            [demoView addSubview:label];
        }
            break;
        case 36:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 100)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:18];
            label.textColor = [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
            label.text =  @"Sorry, Unable to restore purchase now. Please try later.";
            [demoView addSubview:label];
        }
            break;
        case 37:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 100)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:18];
            label.textColor = [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
            label.text =  @"Purchase was successful. Enjoy the game.";
            [demoView addSubview:label];
        }
            break;
        case 38:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 100)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:18];
            label.textColor = [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
            label.text = @"Sorry, Unable to purchase now. Please try later.";
            [demoView addSubview:label];
        }
            break;
            
           
        default:
            break;
    }
    
    return demoView;
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
    [alertView close];
    
    if (alertView.tag == 1000)
    {

    }
}

@end
