//
//  PlayViewController.m
//  ImpossibleSpotter
//
//  Created by Shibin S on 23/07/15.
//  Copyright (c) 2015 Shibin S. All rights reserved.
//

#import "PlayViewController.h"
#import "CustomIOSAlertView.h"

#define TIME 30

@interface PlayViewController ()
{
    BOOL isFullVersion;
    NSArray *randomPair;
}

@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (assign, nonatomic) int randomRowNumber;
@property (assign, nonatomic) int randomColumnNumber;
@property (assign, nonatomic) float redColorValue;
@property (assign, nonatomic) float greenColorValue;
@property (assign, nonatomic) float blueColorValue;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIView *pauseView;
@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (weak, nonatomic) IBOutlet UIButton *quitButton;
@property (weak, nonatomic) IBOutlet UIView *quitView;
@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;

@end

@implementation PlayViewController
{
    int clickCount, score, time;
    NSTimer *timer;
    BOOL isAppPausedWhenResignActive;
    BOOL isPaused;
    int randomShuffleValue;
    NSString *pairValue1;
    NSString *pairValue2;
    NSMutableArray *pairArray;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *array1 = @[@"O",@"0"];
    NSArray *array2 = @[@"B",@"P"];
    NSArray *array3 = @[@"R",@"P"];
    NSArray *array4 = @[@"K",@"X"];
    NSArray *array5 = @[@"q",@"p"];
    
    NSArray *array6 = @[@"5",@"S"];
    NSArray *array7 = @[@"3",@"8"];
    NSArray *array8 = @[@"d",@"d"];
    
    NSArray *array9 = @[@"B",@"R"];
    
    NSArray *array10 = @[@"2",@"Z"];
    NSArray *array11 = @[@"F",@"E"];
    NSArray *array12 = @[@"V",@"Y"];
    NSArray *array13 = @[@"q",@"g"];
    NSArray *array14 = @[@"6",@"9"];
    NSArray *array15 = @[@"I",@"1"];
    NSArray *array16 = @[@"u",@"v"];

    
    NSArray *array17 = @[@"c",@"o"];
    NSArray *array18 = @[@"X",@"H"];



    pairArray = [[NSMutableArray alloc]init];
    [pairArray addObject:array1];
    [pairArray addObject:array2];
    [pairArray addObject:array3];
    [pairArray addObject:array4];
    [pairArray addObject:array5];
    [pairArray addObject:array6];
    [pairArray addObject:array7];
    [pairArray addObject:array8];
    [pairArray addObject:array9];
    [pairArray addObject:array10];
    [pairArray addObject:array11];
    [pairArray addObject:array12];
    [pairArray addObject:array13];
    [pairArray addObject:array14];
    [pairArray addObject:array15];
    [pairArray addObject:array16];
    [pairArray addObject:array17];
    [pairArray addObject:array18];

    isFullVersion = [[NSUserDefaults standardUserDefaults]boolForKey:@"isFullVersion"];
    
    if (isFullVersion)
    {
        [self removeAds];
    }
    
    clickCount = 0;
    score = 0;
    time = TIME;
    isPaused = NO;
    isAppPausedWhenResignActive = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pauseGameWhenAppResignsActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resumeGameAfterAppBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
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
    self.timerLabel.text = [NSString stringWithFormat:@"Time : %i",time];
    self.pauseButton.layer.cornerRadius = 5.0;
    self.buttonView.layer.cornerRadius = 5.0;
    self.pauseButton.layer.cornerRadius = 5.0;
    self.pauseView.layer.cornerRadius = 5.0;
    self.resumeButton.layer.cornerRadius = 5.0;
    self.quitButton.layer.cornerRadius = 5.0;
    self.pauseButton.backgroundColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
    self.pauseView.hidden = YES;
    self.pauseView.hidden = YES;
    self.quitView.hidden = YES;
    self.buttonView.clipsToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(createButtonGridView) withObject:nil afterDelay:0];
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.bannerView.delegate = nil;
    self.bannerView = nil;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Grid Creation

- (void)createButtonGridView
{
    for (UIView *view in self.buttonView.subviews)
    {
        [view removeFromSuperview];
    }
    
    ButtonGridView *buttonGridView= [[ButtonGridView alloc]initWithFrame:CGRectMake(0, 0, self.buttonView.frame.size.width, self.buttonView.frame.size.height)];
    
    randomShuffleValue = [self createRandomNumberBetweenLowerBound:0 upperBound:3];
    
    int randomNumberForLetter = [self createRandomNumberBetweenLowerBound:0 upperBound:pairArray.count-1];
    randomPair = [pairArray objectAtIndex:randomNumberForLetter];
    
    switch (self.mode) {
        case Shade:
            buttonGridView.gridType = GridShade;
            break;
            
        case Letter:
            buttonGridView.gridType = GridLetter;
            break;
            
        case Color:
            buttonGridView.gridType = GridLetterColor;
            break;
            
        case Shuffle:
            buttonGridView.gridType = randomShuffleValue;
            break;
            
        default:
            break;
    }
    buttonGridView.paddingWidth = 3;
    buttonGridView.paddingHeight = 3;
    buttonGridView.buttonCornerRadius = 5;
    buttonGridView.isAnimating = YES;
    buttonGridView.animationDuration = 0.15;
    buttonGridView.dataSource = self;
    buttonGridView.delegate = self;
    self.randomRowNumber = [self createRandowRowNumber];
    self.randomColumnNumber = [self createRandomColumnNumber];
    self.redColorValue =[self createRandomValueForColor];
    self.greenColorValue =[self createRandomValueForColor];
    self.blueColorValue =[self createRandomValueForColor];
    
    if (_mode == Letter || (_mode == Shuffle && randomShuffleValue == Letter))
    {
        buttonGridView.backgroundColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
    }
    else
    {
       buttonGridView.backgroundColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:0.5];
    }
    
    self.scoreLabel.textColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
    self.scoreLabel.text = [NSString stringWithFormat:@"Score : %i",score];
    self.timerLabel.textColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
    self.pauseButton.backgroundColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
    self.resumeButton.backgroundColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
    self.quitButton.backgroundColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
    self.buttonView.backgroundColor = [UIColor whiteColor];
    [self.buttonView addSubview:buttonGridView];
}

- (int)createRandowRowNumber
{
    return [self createRandomNumberBetweenLowerBound:0 upperBound:self.numberOfRows-1];
}

- (int)createRandomColumnNumber
{
    return [self createRandomNumberBetweenLowerBound:0 upperBound:self.numberOfColumns-1];
}

- (float)createRandomValueForColor
{
    return [self createRandomNumberBetweenLowerBound:50 upperBound:150]/255.0;
}

- (int)createRandomNumberBetweenLowerBound:(int)lowerBound upperBound:(int)upperBound
{
    return lowerBound + arc4random() % (upperBound - lowerBound);
}

- (float)getAlphaValue
{
    if (_mode == Color)
    {
        return 0.4 + (0.4 * clickCount)/ (clickCount + 1);
    }
    if (_mode == Shuffle && randomShuffleValue == Color)
    {
        return 0.4 + (0.4 * clickCount)/ (clickCount + 1);
    }
    return 0.47 + (0.47 * clickCount)/ (clickCount + 1);
}

- (int)getRowAndColumnNumber
{
    if (clickCount <= 2)
    {
        return 6;
    }
    else if (clickCount <= 6)
    {
        return 7;
    }
    else if (clickCount <= 10)
    {
        return 8;
    }
    else
    {
        return 9;
    }
}

- (NSString *)randomLetter
{
    NSMutableArray *randomLetters;
    if (randomLetters == nil)
        randomLetters = [NSMutableArray arrayWithCapacity: 26];
    if (randomLetters.count == 0)
    {
        for (unichar aChar = 'A';  aChar <= 'Z'; aChar++)
        {
            [randomLetters addObject: [NSString stringWithCharacters: &aChar length: 1]];
        }
    }
    NSUInteger randomIndex = arc4random_uniform((u_int32_t)randomLetters.count);
    NSString *result =  randomLetters[randomIndex];
    [randomLetters removeObjectAtIndex: randomIndex];
    return result;
}

#pragma mark - Grid View Delegate / DataSource Methods

- (int)numberOfColumns
{
    return [self getRowAndColumnNumber];
}

- (int)numberOfRows
{
    return [self getRowAndColumnNumber];
}

- (UIColor *)colorForRow:(int)row Column:(int)column
{
    if (row == self.randomRowNumber && column == self.randomColumnNumber) {
        return [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:[self getAlphaValue]];
    }
    return [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
}

- (NSString *)letterForRow:(int)row Column:(int)column
{

    if (row == self.randomRowNumber && column == self.randomColumnNumber) {
        
        if (_mode == Letter)
        {
            return [randomPair firstObject];
        }
        
        if (_mode == Shuffle && randomShuffleValue == Letter)
        {
            return [randomPair firstObject];
        }
    }
    else
    {
        if (_mode == Letter)
        {
            return [randomPair lastObject];
        }
        
        if (_mode == Shuffle && randomShuffleValue == Letter)
        {
            return [randomPair lastObject];
        }
    }
    
    if (_mode == Shuffle && randomShuffleValue == Color)
    {
        return [self randomLetter];
    }
    
    if (_mode == Color)
    {
        return [self randomLetter];
    }
    return @"N";
}

- (void)didSelectButtonWithRow:(int)rowNumber Column:(int)columnNumber
{
    if (rowNumber == self.randomRowNumber && columnNumber == self.randomColumnNumber)
    {
        clickCount ++;
        score ++;
        [self createButtonGridView];
    }
    else
    {
        score --;
    }
    
    self.scoreLabel.text = [NSString stringWithFormat:@"Score : %i",score];
}

#pragma make - Timer Methods

- (void)startTimer
{
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
}

- (void)timerTick
{
    time --;
    self.timerLabel.text = [NSString stringWithFormat:@"Time : %i",(int)time];

    if (time <= 0)
    {
        [timer invalidate];
        timer = nil;

        if (self.delegate && [self.delegate respondsToSelector:@selector(didEndGameWithScore:forLevel:)])
        {
            [self.delegate didEndGameWithScore:score forLevel:_mode];
        }
    }
}

#pragma mark - UI Actions

- (IBAction)pauseButtonClicked:(id)sender
{
    [self pauseGame];
}

- (void)pauseGame
{
    self.buttonView.hidden = YES;
    self.pauseView.hidden = NO;
    self.quitView.hidden = NO;
    self.pauseButton.hidden = YES;
    isPaused = YES;
    self.pauseView.backgroundColor = [UIColor colorWithRed:self.redColorValue green:self.greenColorValue blue:self.blueColorValue alpha:1];
    [timer invalidate];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPauseGame)])
    {
        [self.delegate didPauseGame];
    }
}

- (IBAction)resumeVieButtonClicked:(id)sender
{
    [self resumeGame];
}

- (IBAction)resumeButtonClicked:(id)sender
{
    [self resumeGame];
}

- (void)resumeGame
{
    self.buttonView.hidden = NO;
    self.pauseView.hidden = YES;
    self.quitView.hidden = YES;
    self.pauseButton.hidden = NO;
    isPaused = NO;
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didResumeGame)])
    {
        [self.delegate didResumeGame];
    }
}

- (IBAction)quitButtonClicked:(id)sender
{
    [timer invalidate];
    
    // Here we need to pass a full frame
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createDemoViewForTag:100]];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Yes",@"No", nil]];
    [alertView setDelegate:self];
    alertView.tag = 100;
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex)
     {
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];
}

- (void)resumeGameAfterAppBecomeActive
{
    if (isAppPausedWhenResignActive)
    {
        return;
    }
    [self resumeGame];
}

- (void)pauseGameWhenAppResignsActive
{
    if (isPaused)
    {
        isAppPausedWhenResignActive = YES;
    }
    [self pauseGame];
}

#pragma mark - Custom Alert Methods

- (UIView *)createDemoViewForTag:(int)tag
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 100)];
    
    switch (tag)
    {
        case 100:
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 260, 100)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Georgia" size:18];
            label.textColor = [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
            label.text = @"Do you really want to quit the game?";
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
        case 100:
            if (buttonIndex == 0)
            {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didResumeGame)])
                {
                    [self.delegate didResumeGame];
                }
                [self.view removeFromSuperview];
            }
            
            break;
            
        default:
            break;
    }
    
    [alertView close];
}

#pragma mark - Advertisements

- (void)removeAds
{
    self.bannerView.alpha = 0;
    self.bannerView.hidden = YES;
    isFullVersion = YES;
}

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



@end
