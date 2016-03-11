//
//  ResultViewController.m
//  ImpossibleSpotter
//
//  Created by Shibin S on 25/07/15.
//  Copyright (c) 2015 Shibin S. All rights reserved.
//

#import "ResultViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UpgradeViewController.h"

@interface ResultViewController ()
{
    int totalScore;
    BOOL isFullVersion;
}
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *rateMeButton;
@property (weak, nonatomic) IBOutlet UIButton *removeAdsButton;
@property (assign, nonatomic) NSString *leaderBoardIdentifier;
@property (assign, nonatomic) NSString *totalScoreLeaderBoardIdentifier;
@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;
@property (strong, nonatomic) UpgradeViewController *upgradeViewController;


@end

@implementation ResultViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isFullVersion = [[NSUserDefaults standardUserDefaults]boolForKey:@"isFullVersion"];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAds) name:@"purchased" object:nil];
    
    if (isFullVersion)
    {
        [self.rateMeButton setTitle:@"Leaderboard" forState:UIControlStateNormal];
        [self removeAds];
    }
    else
    {
        self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
        [self.rateMeButton setTitle:@"Remove Ads" forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAds) name:@"purchased" object:nil];
    
    int appUsageCount = [[[NSUserDefaults standardUserDefaults]objectForKey:@"AppUsageCount"]intValue];
    appUsageCount = appUsageCount + 1;
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:appUsageCount] forKey:@"AppUsageCount"];
        
    if (appUsageCount >= 15) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:@"AppUsageCount"];
        // Here we need to pass a full frame
        CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
        
        // Add some custom content to the alert view
        [alertView setContainerView:[self createDemoViewForTag:10]];
        
        // Modify the parameters
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Download",@"Later", nil]];
        [alertView setDelegate:self];
        alertView.tag = 10;
        
        // You may use a Block, rather than a delegate.
        [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex)
         {
             [alertView close];
         }];
        
        [alertView setUseMotionEffects:true];
        
        // And launch the dialog
        [alertView show];
    }
    
    
    self.retryButton.layer.cornerRadius = 5;
    self.homeButton.layer.cornerRadius = 5;
    self.rateMeButton.layer.cornerRadius = 5;
    self.removeAdsButton.layer.cornerRadius = 5;
    self.scoreLabel.text = [NSString stringWithFormat:@"%i",self.currentScore];
    int totalScoreInUserDefaults;
    
    switch (self.currentMode)
    {
        case 0:
            self.leaderBoardIdentifier = @"ShadeSpotter";
            self.totalScoreLeaderBoardIdentifier = @"ShadeSpotterTS";
            totalScoreInUserDefaults = [[[ NSUserDefaults standardUserDefaults]objectForKey:@"ShadeSpotterTotalScore"]intValue];
            totalScore = totalScoreInUserDefaults + self.currentScore;
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:totalScore] forKey:@"ShadeSpotterTotalScore"];
            break;
        case 1:
            self.leaderBoardIdentifier = @"LetterSpotter";
            self.totalScoreLeaderBoardIdentifier = @"LetterSpotterTS";
            totalScoreInUserDefaults = [[[ NSUserDefaults standardUserDefaults]objectForKey:@"LetterSpotterTotalScore"]intValue];
            totalScore = totalScoreInUserDefaults + self.currentScore;
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:totalScore] forKey:@"LetterSpotterTotalScore"];
            break;
        case 2:
            self.leaderBoardIdentifier = @"ColorSpotter";
            self.totalScoreLeaderBoardIdentifier = @"ColorSpotterTotal";
            totalScoreInUserDefaults = [[[ NSUserDefaults standardUserDefaults]objectForKey:@"ColorSpotterTotalScore"]intValue];
            totalScore = totalScoreInUserDefaults + self.currentScore;
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:totalScore] forKey:@"ColorSpotterTotalScore"];
            break;
        case 3:
            self.leaderBoardIdentifier = @"ShuffeMode";
            self.totalScoreLeaderBoardIdentifier = @"ShuffeModeTS";
            totalScoreInUserDefaults = [[[ NSUserDefaults standardUserDefaults]objectForKey:@"ShuffleModeTotalScore"]intValue];
            totalScore = totalScoreInUserDefaults + self.currentScore;
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:totalScore] forKey:@"ShuffleModeTotalScore"];
            break;
        default:
            break;
    }
    
    [self reportScore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - UI Actions

- (IBAction)playAgainTapped:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapPlayAgain)])
    {
        [self.delegate didTapPlayAgain];
    }
}

- (IBAction)homeButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (IBAction)leaderboardTapped:(id)sender
{
    NSString *mode = @"";
    
    switch (self.currentMode)
    {
        case 0:
            mode = @"Shade Spotter";
            break;
        case 1:
            mode = @"Letter Spotter";
            break;
        case 2:
            mode = @"Color Spotter";
            break;
        case 3:
            mode = @"Shuffle";
            break;
        default:
            break;
    }
    
    NSString *text = [NSString stringWithFormat:@"I scored %i in %@ Mode in Shade Spotter Combo Game. Download from Appstore and beat my score. \n https://itunes.apple.com/app/id1023196343",self.currentScore,mode];
    
//    UIImage *kukuImage = [UIImage imageNamed:@"iconimage.png"];
    UIActivityViewController *shareController = [[UIActivityViewController alloc]initWithActivityItems:@[text] applicationActivities:nil];
    [self presentViewController:shareController animated:YES completion:nil];
}

- (IBAction)removeAdsTapped:(id)sender
{
    if (isFullVersion)
    {
        [self showLeaderboardAndAchievements:YES];
    }
    else
    {
        self.upgradeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UpgradeViewController"];
        [self.view addSubview:self.upgradeViewController.view];
    }
}

#pragma mark - Game Center

-(void)reportScore
{
    // Create a GKScore object to assign the score and report it as a NSArray object.
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:self.leaderBoardIdentifier];
    score.value = self.currentScore;
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    
    score = [[GKScore alloc] initWithLeaderboardIdentifier:self.totalScoreLeaderBoardIdentifier];
    score.value = totalScore;
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
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

#pragma mark - Advertisements

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
    self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyNone;
    self.bannerView.alpha = 0;
    self.bannerView.hidden = YES;
    isFullVersion = YES;
    [self.rateMeButton setTitle:@"Leaderboard" forState:UIControlStateNormal];
}

#pragma mark - Custom Alert Methods

- (UIView *)createDemoViewForTag:(int)tag
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 100)];
    
    switch (tag)
    {
        case 10:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 100)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:17];
            label.textColor = [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
            label.text = @"Now track your expense and income on one app. Download Expense Manager App for free.";
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
    switch (alertView.tag) {
        case 10:
            if (buttonIndex == 0)
            {
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/expensemobile/id931178948?ls=1&mt=8"]];
            }
            
            break;
            
        default:
            break;
    }
    
    [alertView close];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
