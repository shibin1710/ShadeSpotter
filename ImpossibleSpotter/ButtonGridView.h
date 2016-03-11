//
//  ButtonGridView.h
//  KukuKube
//
//  Created by Shibin S on 11/11/14.
//  Copyright (c) 2014 Shibin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    GridShade,
    GridLetter,
    GridLetterColor
}GridType;

@protocol ButtonGridViewDataSource <NSObject>

@required

- (int)numberOfRows;
- (int)numberOfColumns;
- (UIColor *)colorForRow:(int)row Column:(int)column;
- (NSString *)letterForRow:(int)row Column:(int)column;

@end

@protocol ButtonGridViewDelegate <NSObject>

@optional

- (void)didSelectButtonWithRow:(int)rowNumber Column:(int)columnNumber;

@end

@interface ButtonGridView : UIView

@property (assign, nonatomic) int paddingWidth;
@property (assign, nonatomic) GridType gridType;
@property (assign, nonatomic) int paddingHeight;
@property (assign, nonatomic) float buttonCornerRadius;
@property (assign, nonatomic) BOOL isAnimating;
@property (assign, nonatomic) float animationDuration;
@property (assign, nonatomic) id<ButtonGridViewDelegate> delegate;
@property (assign, nonatomic) id<ButtonGridViewDataSource> dataSource;

@end
