//
//  ButtonGridView.m
//  KukuKube
//
//  Created by Shibin S on 11/11/14.
//  Copyright (c) 2014 Shibin. All rights reserved.
//

#import "ButtonGridView.h"
#import <QuartzCore/QuartzCore.h>

@interface ButtonGridView ()

@property (assign, nonatomic) CGRect viewFrame;
@property (assign, nonatomic) int numberOfRows;
@property (assign, nonatomic) int numberOfColumns;

@end

@implementation ButtonGridView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.viewFrame = frame;
    }
    return self;
}

- (void)createButtonGridView
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfRows)]) {
        self.numberOfRows = [self.dataSource numberOfRows];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfColumns)]) {
        self.numberOfColumns = [self.dataSource numberOfColumns];
    }
    for (int i = 0; i < self.numberOfColumns; i++) {
        for (int j = 0; j < self.numberOfRows; j++) {
            
            float widthOfButton = (self.viewFrame.size.width - (self.numberOfColumns + 1) * self.paddingWidth)/self.numberOfColumns;
            float heightOfButton = (self.viewFrame.size.height - (self.numberOfRows + 1) * self.paddingHeight)/self.numberOfRows;
            CGRect buttonFrame = CGRectMake(self.paddingWidth * (1+i) + widthOfButton * i, self.paddingHeight * (1+j) + heightOfButton * j, widthOfButton, heightOfButton);
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(buttonFrame.origin.x + buttonFrame.size.width/8, buttonFrame.origin.y + buttonFrame.size.height/8, buttonFrame.size.width - buttonFrame.size.width/4, buttonFrame.size.height - buttonFrame.size.height/4)];
            [button addTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];
            int buttonTag = [self getUniqueTagValueWithRow:j Column:i];
            button.tag = buttonTag;
            UIColor *buttonColor = [UIColor blackColor];
            
            if (self.gridType == GridShade)
            {
                if (self.dataSource && [self.dataSource respondsToSelector:@selector(colorForRow:Column:)]) {
                    buttonColor = [self.dataSource colorForRow:j Column:i];
                }
                button.backgroundColor = buttonColor;

            }
            button.layer.cornerRadius = self.buttonCornerRadius;
            NSString *letter = @"";
            if (self.gridType == GridLetter || self.gridType == GridLetterColor)
            {
                if (self.dataSource && [self.dataSource respondsToSelector:@selector(letterForRow:Column:)])
                {
                    letter = [self.dataSource letterForRow:j Column:i];
                }
                [button setTitle:letter forState:UIControlStateNormal];
                [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:21]];
                
                if (self.gridType == GridLetterColor)
                {
                    if (self.dataSource && [self.dataSource respondsToSelector:@selector(colorForRow:Column:)]) {
                        UIColor *textColor = [self.dataSource colorForRow:j Column:i];
                        [button setTitleColor:textColor forState:UIControlStateNormal];
                        button.backgroundColor = [UIColor whiteColor];

                    }
                }
            }
           
            
            [self addSubview:button];

            if (!self.isAnimating) {
                self.animationDuration = 0;
            }
            [UIView animateWithDuration:self.animationDuration animations:^{
                button.frame = buttonFrame;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    [self createButtonGridView];
}

- (void)didSelectButton:(UIButton *)aButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectButtonWithRow:Column:)]) {
        [self.delegate didSelectButtonWithRow:[self getRowNumberForTag:(int)aButton.tag] Column:[self getColumnNumberForTag:(int)aButton.tag]];
    }

}

- (int)getUniqueTagValueWithRow:(int)rowNo Column:(int)columnNo
{
    return (rowNo * self.numberOfRows) + columnNo;
}

- (int)getRowNumberForTag:(int)tag
{
    return  floorf(tag / self.numberOfColumns);
}

- (int)getColumnNumberForTag:(int)tag
{
    return (tag % self.numberOfRows);
}



@end
