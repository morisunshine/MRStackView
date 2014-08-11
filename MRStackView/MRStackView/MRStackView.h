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

@property (nonatomic) id<MRStackViewDelegate> delegate;

- (UIView *)dequeueReusablePage;

@end

@protocol MRStackViewDelegate

- (UIView *)stackView:(MRStackView *)stackView pageForIndex:(NSInteger)index;

- (NSInteger)numberOfPagesForStackView:(MRStackView *)stackView;

- (CGFloat)heightOfPagesForStackView:(MRStackView *)stackView;

- (void)stackView:(MRStackView *)stackView selectedPageAtIndex:(NSInteger)index;

- (UIViewController *)viewControllerForStackView:(MRStackView *)tackView selectedPageAtIndex:(NSInteger)index;

@end
