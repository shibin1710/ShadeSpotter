//
//  UpgradeViewController.h
//  ImpossibleSpotter
//
//  Created by Shibin S on 26/07/15.
//  Copyright (c) 2015 Shibin S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "CustomIOSAlertView.h"

@interface UpgradeViewController : UIViewController<SKProductsRequestDelegate,SKPaymentTransactionObserver,CustomIOSAlertViewDelegate>

@end
