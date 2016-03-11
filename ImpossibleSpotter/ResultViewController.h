//
//  ResultViewController.h
//  ImpossibleSpotter
//
//  Created by Shibin S on 25/07/15.
//  Copyright (c) 2015 Shibin S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <iAd/iAd.h>
#import "CustomIOSAlertView.h"

@protocol ResultDelegate <NSObject>

- (void)didTapPlayAgain;
//- (void)homeButtonTapped:(BOOL)showAdScreen;

@end

@interface ResultViewController : UIViewController<GKGameCenterControllerDelegate,ADBannerViewDelegate,CustomIOSAlertViewDelegate>

@property (assign, nonatomic) id<ResultDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (assign, nonatomic) int currentScore;
@property (assign, nonatomic) int currentMode;


@end
