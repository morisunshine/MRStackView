//
//  MRStackView.m
//  MRStackView
//
//  Created by sheldon on 14-8-8.
//  Copyright (c) 2014年 wheelab. All rights reserved.
//

#import "MRStackView.h"

#define PAGE_PEAK 80.f
#define MINIMUM_ALPHA 0.5f
#define MINIMUM_SCALE 0.9f
#define TOP_OFFSET_HIDE 20.f
#define BOTTOM_OFFSET_HIDE 20.f
#define COLLAPSED_OFFSET 5.f
#define SHADOW_VECTOR CGSizeMake(0.f,-.5f)
#define SHADOW_ALPHA .3f

@interface MRStackView()

@property (nonatomic) UIScrollView *scollView;
@property (nonatomic) NSMutableArray *reusablePages;
@property (nonatomic) NSMutableArray *pages;
@property (nonatomic) NSMutableArray *reusableBackgroundViews;
@property (nonatomic) NSMutableArray *backgroundViews;
@property (nonatomic) NSRange visibleRange;
@property (nonatomic) NSInteger selectedPageIndex;
@property (nonatomic) NSInteger pageCount;
@property (nonatomic) CGFloat pageHeight;
@property (nonatomic) CGFloat backgroundViewHeight;

@end

@implementation MRStackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self reloadVisiblePages];
}

- (void)setup
{
    self.pageCount = 0;
    self.selectedPageIndex = -1;
    self.pages = [[NSMutableArray alloc] init];
    self.backgroundViews = [[NSMutableArray alloc] init];
    self.reusablePages = [[NSMutableArray alloc] init];
    self.reusableBackgroundViews = [[NSMutableArray alloc] init];
    self.visibleRange = NSMakeRange(0, 0);
}

#pragma mark - Getters -

- (UIScrollView *)scollView
{
    if (!_scollView) {
        _scollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scollView.delegate = self;
        _scollView.backgroundColor = [UIColor clearColor];
        _scollView.showsVerticalScrollIndicator = NO;
        _scollView.alwaysBounceVertical = YES;
    }
    
    return _scollView;
}

#pragma mark - Page Selection -

- (void)selectPageAtIndex:(NSInteger)index
{
//    if (index != self.selectedPageIndex) {
//        self.selectedPageIndex = index;
//        [self hidePagesExcept:index];
//        [self showPagesFullScreen:index];
//
//        self.scollView.scrollEnabled = NO;
//    } else {
//        [self resetPages];
//        self.selectedPageIndex = -1;
//    }
}

- (void)resetPages
{
    NSInteger start = self.visibleRange.location;
    NSInteger stop = self.visibleRange.location + self.visibleRange.length;
    [UIView animateWithDuration:0.4 animations:^{
        for (NSInteger i = start; i < stop; i++) {
            
            UIView *page = self.pages[i];
            
            if (self.selectedPageIndex == i) {
                page.frame = CGRectMake(15, 15, CGRectGetWidth(page.frame) - 30, CGRectGetHeight(page.frame) - 15);
            } else {
                CGRect rect = page.frame;
                rect.origin.y = i * self.pageHeight;
                page.frame = rect;
            }
        }
    }];
    
    self.scollView.scrollEnabled = YES;
}

- (void)showPagesFullScreen:(NSInteger)index
{
    UIView *page = (UIView *)self.pages[index];
    CGRect rect = page.frame;
    NSLog(@"rect: %@", NSStringFromCGRect(rect));
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect newRect = rect;
        newRect.origin.y = -rect.origin.y;
        newRect.origin.x = page.frame.origin.x;
        page.frame = newRect;
    }];
}

- (void)hidePagesExcept:(NSInteger)index
{
    NSInteger start = self.visibleRange.location;
    NSInteger stop = self.visibleRange.location + self.visibleRange.length;
    [UIView animateWithDuration:0.4 animations:^{
        for (NSInteger i = start; i < stop; i++) {
            UIView *page = (UIView *)self.pages[i];
            CGRect rect = page.frame;
            rect.origin.y = self.scollView.contentOffset.y + CGRectGetHeight(self.frame) - BOTTOM_OFFSET_HIDE + i * COLLAPSED_OFFSET;
            page.frame = rect;
        }
    }];
}

#pragma mark - Displaying Pages -

- (void)reloadVisiblePages
{
    if (self.delegate) {
        self.pageCount = [self.delegate numberOfPagesForStackView:self];
        self.pageHeight = [self.delegate heightOfPagesForStackView:self];
        self.backgroundViewHeight = [self.delegate heightOfBackgroundViewForStackView:self];
    }
    
    [self.reusablePages removeAllObjects];
    [self.reusableBackgroundViews removeAllObjects];
    
    self.visibleRange = NSMakeRange(0, 0);
    
    for (NSInteger i = 0; i < self.backgroundViews.count; i++) {
        [self removeViewAtIndex:i];
    }
    
    [self.pages removeAllObjects];
    [self.backgroundViews removeAllObjects];
    
    for (NSInteger i = 0; i < self.pageCount; i++) {
        [self.pages addObject:[NSNull null]];
        [self.backgroundViews addObject:[NSNull null]];
    }
    
    self.scollView.frame = self.bounds;
    self.scollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), MAX(CGRectGetHeight(self.bounds), self.pageCount * self.backgroundViewHeight));
    [self addSubview:self.scollView];
    
    [self setPageAtOffset:self.scollView.contentOffset];
}

- (void)setPageAtOffset:(CGPoint)offset
{
    if (0 < self.backgroundViews.count) {
        CGPoint startPoint = CGPointMake(offset.x - CGRectGetMinX(self.scollView.frame), offset.y - CGRectGetMinY(self.scollView.frame));
        CGPoint endPoint = CGPointMake(MAX(0, startPoint.x) + CGRectGetWidth(self.bounds), startPoint.y + CGRectGetHeight(self.bounds));
        
        NSInteger startIndex = 0;
        for (NSInteger i = 0; i < self.backgroundViews.count; i++) {
            if (self.backgroundViewHeight * (i+1) > startPoint.y) {
                startIndex = i;
                break;
            }
        }
        
        NSInteger endIndex = 0;
        for (NSInteger i = 0; i < self.backgroundViews.count; i++) {
            if ((self.backgroundViewHeight * i < endPoint.y && self.backgroundViewHeight * (i + 1) >= endPoint.y) || i == self.backgroundViews.count - 1) {
                endIndex = i + 1;
                break;
            }
        }
        
        startIndex = MAX(startIndex - 1, 0);
        endIndex = MIN(endIndex, self.backgroundViews.count - 1);
        CGFloat pagedLength = endIndex - startIndex + 1;
        
        if (self.visibleRange.location != startIndex || self.visibleRange.length != pagedLength) {
            
            _visibleRange.location = startIndex;
            _visibleRange.length = pagedLength;
            
            for (NSInteger i = startIndex; i <= endIndex; i++) {
                [self setPageAtIndex:i];
            }
            
            for (NSInteger i = 0; i < startIndex; i++) {
                [self removeViewAtIndex:i];
            }
            
            for (NSInteger i = endIndex + 1; i < self.backgroundViews.count; i++) {
                [self removeViewAtIndex:i];
            }
        }
    }
}

- (void)setPageAtIndex:(NSInteger)index
{
    if (0 <= index && index < self.backgroundViews.count) {

        UIView *backgroundView = self.backgroundViews[index];
        UIView *page = self.pages[index];
        if (((!page || (NSObject *)page == [NSNull null]) ||
            (!backgroundView || (NSObject *)backgroundView == [NSNull null])) &&
            self.delegate) {
            page = [self.delegate stackView:self pageForRowAtIndex:index];
            backgroundView = [self.delegate stackView:self backgroundViewForRowAtIndex:index];
            
            [self.pages replaceObjectAtIndex:index withObject:page];
            [self.backgroundViews replaceObjectAtIndex:index withObject:backgroundView];
            
            backgroundView.frame = CGRectMake(0,
                                              index * self.backgroundViewHeight,
                                              CGRectGetWidth(self.bounds),
                                              self.backgroundViewHeight);
            backgroundView.layer.shadowOpacity = 0.3;
            backgroundView.layer.shadowOffset = CGSizeMake(-0.2, 0.2);
            backgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
            backgroundView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backgroundView.bounds].CGPath;
            
            page.frame = CGRectMake(CGRectGetMinX(page.frame),
                                    index * self.backgroundViewHeight + 10,
                                    CGRectGetWidth(page.frame),
                                    self.pageHeight);
        }
        
        [self.scollView insertSubview:backgroundView atIndex:2*index];
        [self.scollView insertSubview:page atIndex:2*index + 1];
        
        
        if (page.gestureRecognizers.count < 1) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
            [page addGestureRecognizer:tap];
        }
    }
}

#pragma mark - Reuse Methods -

- (void)enqueueReusablePage:(UIView *)page
{
    [self.reusablePages addObject:page];
}

- (void)enqueueReusableBackgroundView:(UIView *)backgroundView
{
    [self.reusableBackgroundViews addObject:backgroundView];
}

- (UIView *)dequeueReusablePage
{
    UIView *page = [self.reusablePages lastObject];
    if (page && (NSObject *)page != [NSNull null]) {
        [self.reusablePages removeLastObject];
        
        return page;
    }
    
    return nil;
}

- (UIView *)dequeueReusableBackgroundView
{
    UIView *backgroundView = [self.reusableBackgroundViews lastObject];
    if (backgroundView && (NSObject *)backgroundView != [NSNull null]) {
        [self.reusableBackgroundViews removeLastObject];
        
        return backgroundView;
    }
    
    return nil;
}

- (void)removeViewAtIndex:(NSInteger)index
{
    UIView *backgroundView = self.backgroundViews[index];
    UIView *page = self.pages[index];
    
    if (backgroundView && (NSObject *)backgroundView != [NSNull null]&&
        page && (NSObject *)page != [NSNull null]) {
        [backgroundView removeFromSuperview];
        [page removeFromSuperview];
        [self enqueueReusableBackgroundView:backgroundView];
        [self enqueueReusablePage:page];
        [self.backgroundViews replaceObjectAtIndex:index withObject:[NSNull null]];
        [self.pages replaceObjectAtIndex:index withObject:[NSNull null]];
    }
}

#pragma mark - Actions -

- (IBAction)tapped:(UITapGestureRecognizer *)sender
{
    UIView *page = sender.view;
    NSInteger index = [self.pages indexOfObject:page];
    [self selectPageAtIndex:index];
    [self.delegate stackView:self selectedPageAtIndex:index];
}

#pragma mark - ScollView Delegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setPageAtOffset:scrollView.contentOffset];
}

@end
