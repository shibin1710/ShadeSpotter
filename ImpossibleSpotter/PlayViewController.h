//
//  PlayViewController.h
//  ImpossibleSpotter
//
//  Created by Shibin S on 23/07/15.
//  Copyright (c) 2015 Shibin S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtonGridView.h"
#import "CustomIOSAlertView.h"
#import <iAd/iAd.h>

typedef enum {
    
    Shade,
    Letter,
    Color,
    Shuffle
}Mode;

@protocol PlayDelegate <NSObject>

- (void)didEndGameWithScore:(int)score forLevel:(int)level;
- (void)didPauseGame;
- (void)didResumeGame;

@end

@interface PlayViewController : UIViewController<ButtonGridViewDataSource,ButtonGridViewDelegate,CustomIOSAlertViewDelegate,ADBannerViewDelegate>

@property (assign, nonatomic) id<PlayDelegate> delegate;
@property (assign, nonatomic) Mode mode;

@end
