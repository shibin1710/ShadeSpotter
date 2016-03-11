//
//  ViewController.h
//  ImpossibleSpotter
//
//  Created by Shibin S on 21/07/15.
//  Copyright (c) 2015 Shibin S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ResultViewController.h"
#import <GameKit/GameKit.h>
#import "CustomIOSAlertView.h"
#import <iAd/iAd.h>

@interface ViewController : UIViewController<PlayDelegate,AVAudioPlayerDelegate,ResultDelegate,UIAlertViewDelegate,CustomIOSAlertViewDelegate,GKGameCenterControllerDelegate,ADBannerViewDelegate>

@property (strong, nonatomic) AVAudioPlayer *myPlayer;

@end

