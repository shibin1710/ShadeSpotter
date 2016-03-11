//
//  ViewController.m
//  ImpossibleSpotter
//
//  Created by Shibin S on 21/07/15.
//  Copyright (c) 2015 Shibin S. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UpgradeViewController.h"

@interface ViewController ()
{
    BOOL isFullVersion;
}

@property (weak, nonatomic) IBOutlet UIButton *textSpotterButton;
@property (weak, nonatomic) IBOutlet UIButton *colorSpotterButton;
@property (weak, nonatomic) IBOutlet UIButton *shadeSpotterButton;
@property (weak, nonatomic) IBOutlet UIButton *soundToggleButton;
@property (strong, nonatomic) ResultViewController *resultViewController;
@property (strong, nonatomic) PlayViewController *playViewController;
@property (strong, nonatomic) NSArray *musicArray;
@property (weak, nonatomic) IBOutlet UIButton *upgradeButton;
@property (weak, nonatomic) IBOutlet UIButton *leaderboardButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleModeButton;
@property (strong, nonatomic) UIViewController *gameCenterViewController;
@property (assign, nonatomic) BOOL gameCenterEnabled;
@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;
@property (strong, nonatomic) UpgradeViewController *upgradeViewController;


@end

@implementation ViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gameCenterEnabled = NO;
    self.musicArray = @[@"Music1",@"Music2"];
    self.textSpotterButton.layer.cornerRadius = 5;
    self.colorSpotterButton.layer.cornerRadius = 5;
    self.shadeSpotterButton.layer.cornerRadius = 5;
    self.shuffleModeButton.layer.cornerRadius = 5;
    self.upgradeButton.layer.cornerRadius = 5;
    self.leaderboardButton.layer.cornerRadius = 5;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAds) name:@"purchased" object:nil];

    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"soundOn"] == nil)
    {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:1] forKey:@"soundOn"];
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"isFullVersion"] == nil)
    {
        [[NSUserDefaults standardUserDefaults]setObject:@NO forKey:@"isFullVersion"];
    }
    
    isFullVersion = [[NSUserDefaults standardUserDefaults]boolForKey:@"isFullVersion"];
    
    if (isFullVersion)
    {
        [self.upgradeButton setTitle:@"Rate Game" forState:UIControlStateNormal];
        [self removeAds];
    }
    else
    {
        [self.upgradeButton setTitle:@"Upgrade" forState:UIControlStateNormal];
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"ColorSpotterTotalScore"] == nil)
    {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"ColorSpotterTotalScore"];
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"AppUsageCount"] == nil)
    {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"AppUsageCount"];
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"ShadeSpotterTotalScore"] == nil)
    {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"ShadeSpotterTotalScore"];
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"LetterSpotterTotalScore"] == nil)
    {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"LetterSpotterTotalScore"];
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"ShuffleModeTotalScore"] == nil)
    {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"ShuffleModeTotalScore"];
    }
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"soundOn"]boolValue] == YES)
    {
        self.soundToggleButton.selected = YES;
    }

    [self authenticateLocalPlayer];
    [self playMusic];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.bannerView.hidden = YES;
    self.bannerView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.bannerView.delegate = nil;
    self.bannerView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Sounds

- (IBAction)toggleSound:(UIButton *)sender {
    
    if (sender.selected)
    {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"soundOn"];
        self.soundToggleButton.selected = NO;
        [self.myPlayer pause];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:1] forKey:@"soundOn"];
        [self playMusic];
        self.soundToggleButton.selected = YES;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self playMusic];
}

- (void)playMusic
{
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"soundOn"]boolValue])
    {
        return;
    }
    
    int randomNumber = arc4random() % (self.musicArray.count);
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[self.musicArray objectAtIndex:randomNumber] ofType:@"mp3"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
    
    // create new audio player
    self.myPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:nil];
    self.myPlayer.delegate = self;
    [self.myPlayer play];
    
}

- (void)didPauseGame
{
    [self.myPlayer pause];
}

- (void)didResumeGame
{
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"soundOn"]boolValue])
    {
        return;
    }
    
    [self.myPlayer play];
}

#pragma mark - Play Methods

- (void)didEndGameWithScore:(int)score forLevel:(int)level
{
    self.resultViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ResultViewController"];
    self.resultViewController.currentScore = score;
    self.resultViewController.currentMode = level;
    self.resultViewController.delegate = self;
    [self presentViewController:self.resultViewController animated:NO completion:^{
        [self.playViewController.view removeFromSuperview];
        self.playViewController = nil;
    }];
}

- (void)didTapPlayAgain
{
    int currentMode = [[[NSUserDefaults standardUserDefaults]objectForKey:@"currentMode"]intValue];
    
    [self.resultViewController dismissViewControllerAnimated:NO completion:^{
        self.resultViewController = nil;
    }];
    self.playViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayViewController"];
    
    switch (currentMode)
    {
        case 1:
            self.playViewController.mode = Shade;
            break;
        case 2:
            self.playViewController.mode = Letter;
            break;
        case 3:
            self.playViewController.mode = Color;
            break;
        case 4:
            self.playViewController.mode = Shuffle;
            break;
        default:
            break;
    }
    
    self.playViewController.delegate = self;
    [self.view addSubview:self.playViewController.view];
}

#pragma mark - UI Actions

- (IBAction)shadeSpotterClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:@1 forKey:@"currentMode"];
    self.playViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayViewController"];
    self.playViewController.mode = Shade;
    self.playViewController.delegate = self;
    [self.view addSubview:self.playViewController.view];
}

- (IBAction)textSpotterClicked:(id)sender
{
    if (isFullVersion)
    {
        [[NSUserDefaults standardUserDefaults]setObject:@2 forKey:@"currentMode"];
        self.playViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayViewController"];
        self.playViewController.mode = Letter;
        self.playViewController.delegate = self;
        [self.view addSubview:self.playViewController.view];
    }
    else
    {
        // Here we need to pass a full frame
        CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
        
        // Add some custom content to the alert view
        [alertView setContainerView:[self createDemoViewForTag:1004]];
        
        // Modify the parameters
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Upgrade",@"Later", nil]];
        [alertView setDelegate:self];
        alertView.tag = 1004;
        
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

- (IBAction)colorSpotterClicked:(id)sender
{
//    if (isFullVersion)
//    {
        [[NSUserDefaults standardUserDefaults]setObject:@3 forKey:@"currentMode"];
        self.playViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayViewController"];
        self.playViewController.mode = Color;
        self.playViewController.delegate = self;
        [self.view addSubview:self.playViewController.view];
//    }
//    else
//    {
//        // Here we need to pass a full frame
//        CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
//        
//        // Add some custom content to the alert view
//        [alertView setContainerView:[self createDemoViewForTag:1004]];
//        
//        // Modify the parameters
//        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Upgrade",@"Later", nil]];
//        [alertView setDelegate:self];
//        alertView.tag = 1004;
//        
//        // You may use a Block, rather than a delegate.
//        [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex)
//         {
//             [alertView close];
//         }];
//        
//        [alertView setUseMotionEffects:true];
//        
//        // And launch the dialog
//        [alertView show];
//    }

}

- (IBAction)shuffleModeClicked:(id)sender
{
    if (isFullVersion)
    {
        [[NSUserDefaults standardUserDefaults]setObject:@4 forKey:@"currentMode"];
        self.playViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayViewController"];
        self.playViewController.mode = Shuffle;
        self.playViewController.delegate = self;
        [self.view addSubview:self.playViewController.view];
    }
    else
    {
        // Here we need to pass a full frame
        CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
        
        // Add some custom content to the alert view
        [alertView setContainerView:[self createDemoViewForTag:1004]];
        
        // Modify the parameters
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Upgrade",@"Later", nil]];
        [alertView setDelegate:self];
        alertView.tag = 1004;
        
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

- (IBAction)upgradeClicked:(id)sender
{
    if (isFullVersion)
    {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/expensemobile/id1023196343?ls=1&mt=8"]];
    }
    else
    {
        self.upgradeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UpgradeViewController"];
        [self.view addSubview:self.upgradeViewController.view];
    }
}

#pragma mark - Custom Alerts

- (UIView *)createDemoViewForTag:(int)tag
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 100)];
    switch (tag)
    {
        case 1000:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 100)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:18];
            label.textColor = [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
            label.text = @"Do you want to sign in to Game Center?";
            [demoView addSubview:label];
        }
        break;
            
        case 1004:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 100)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:18];
            label.textColor = [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
            label.text = @"This mode is locked. Upgrade the app to Pro version to unlock this mode. Do you want to upgrade now?";
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
        if (buttonIndex == 0)
        {
            [self presentViewController:self.gameCenterViewController animated:YES completion:nil];
        }
    }
    if (alertView.tag == 1004)
    {
        if (buttonIndex == 0)
        {
            self.upgradeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UpgradeViewController"];
            [self.view addSubview:self.upgradeViewController.view];        }
    }
}

#pragma mark - Game Center

- (void)authenticateLocalPlayer
{
    // Instantiate a GKLocalPlayer object to use for authenticating a player.
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
        if (viewController != nil)
        {
            self.gameCenterViewController = viewController;
            
            // Here we need to pass a full frame
            CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
            
            // Add some custom content to the alert view
            [alertView setContainerView:[self createDemoViewForTag:1000]];
            
            // Modify the parameters
            [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Yes",@"No", nil]];
            [alertView setDelegate:self];
            alertView.tag = 1000;
            
            // You may use a Block, rather than a delegate.
            [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex)
             {
                 [alertView close];
             }];
            
            [alertView setUseMotionEffects:true];
            
            // And launch the dialog
            [alertView show];
        }
        else
        {
            if ([GKLocalPlayer localPlayer].authenticated)
            {
                // If the player is already authenticated then indicate that the Game Center features can be used.
                _gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil)
                    {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                }];
            }
            else
            {
                _gameCenterEnabled = NO;
            }
        }
    };
}


-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard
{
    // Init the following view controller object.
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    // Set self as its delegate.
    gcViewController.gameCenterDelegate = self;
    
    // Depending on the parameter, show either the leaderboard or the achievements.
    if (shouldShowLeaderboard)
    {
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    }
    else
    {
        gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
    }
    
    // Finally present the view controller.
    [self presentViewController:gcViewController animated:YES completion:nil];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)leaderboardClicked:(id)sender
{
    [self showLeaderboardAndAchievements:YES];
}

#pragma mark - Advertisement

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    self.bannerView.hidden = NO;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    self.bannerView.hidden = YES;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    self.bannerView.hidden = YES;
}

- (void)removeAds
{
    self.bannerView.alpha = 0;
    self.bannerView.hidden = YES;
    isFullVersion = YES;
    [self.upgradeButton setTitle:@"Rate Game" forState:UIControlStateNormal];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
