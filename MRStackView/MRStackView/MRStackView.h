//
//  MRStackView.h
//  MRStackView
//
//  Created by sheldon on 14-8-8.
//  Copyright (c) 2014年 wheelab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRStackViewDelegate;

@interface MRStackView : UIView <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scollView;
@property (nonatomic, weak) id<MRStackViewDelegate> delegate;
@property (nonatomic) CGFloat contentViewTop;
@property (nonatomic) NSMutableArray *pages;
@property (nonatomic) NSInteger selectedPageIndex;

- (UIView *)dequeueReusablePage;
- (UIView *)dequeueReusableBackgroundView;
- (void)resetPagesAndBackgroundView;
- (void)reloadVisiblePages;

@end

@protocol MRStackViewDelegate <NSObject>

- (UIView *)stackView:(MRStackView *)stackView pageForRowAtIndex:(NSInteger)index;

- (UIView *)stackView:(MRStackView *)stackView backgroundViewForRowAtIndex:(NSInteger)index;

- (NSInteger)numberOfPagesForStackView:(MRStackView *)stackView;

- (CGFloat)heightOfPagesForStackView:(MRStackView *)stackView;

- (CGFloat)heightOfBackgroundViewForStackView:(MRStackView *)stackView;

@optional

- (void)stackView:(MRStackView *)stackView selectedPageAtIndex:(NSInteger)index;

- (void)stackView:(MRStackView *)stackView showAnimationWithIndex:(NSInteger)index;

- (void)stackView:(MRStackView *)stackView resetPagesAndBackgroundViewWithIndex:(NSInteger)index;

@end
