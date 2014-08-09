//
//  MRStackView.m
//  MRStackView
//
//  Created by sheldon on 14-8-8.
//  Copyright (c) 2014年 wheelab. All rights reserved.
//

#import "MRStackView.h"

#define OFFSET_TOP 30.f
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
@property (nonatomic) NSInteger selectedPageIndex;
@property (nonatomic) CGFloat trackedTranslation;
@property (nonatomic) NSInteger pageCount;
@property (nonatomic) CGFloat pageHeight;
@property (nonatomic) NSMutableArray *pages;
@property (nonatomic) NSRange visiblePages;
@property (nonatomic) UIViewController *currentViewController;

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
    
    if (self.delegate) {
        self.pageCount = [self.delegate numberOfPagesForStackView:self];
        self.pageHeight = [self.delegate heightOfPagesForStackView:self];
    }
    
    [self.reusablePages removeAllObjects];
    self.visiblePages = NSMakeRange(0, 0);
    
    for (NSInteger i = 0; i < self.pages.count; i++) {
        [self removePageAtIndex:i];
    }
    
    [self.pages removeAllObjects];
    
    for (NSInteger i = 0; i < self.pageCount; i++) {
        [self.pages addObject:[NSNull null]];
    }
    
    self.scollView.frame = self.bounds;
    self.scollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), MAX(CGRectGetHeight(self.bounds), OFFSET_TOP + self.pageCount * self.pageHeight));
    [self addSubview:self.scollView];
    
    [self setPageAtOffset:self.scollView.contentOffset];
    [self reloadVisiblePages];
}

- (void)setup
{
    self.pageCount = 0;
    self.selectedPageIndex = -1;
    self.pages = [[NSMutableArray alloc] init];
    self.reusablePages = [[NSMutableArray alloc] init];
    self.visiblePages = NSMakeRange(0, 0);
}

#pragma mark - Getters -

- (UIScrollView *)scollView
{
    if (!_scollView) {
        _scollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scollView.delegate = self;
        _scollView.backgroundColor = [UIColor clearColor];
        _scollView.showsVerticalScrollIndicator = NO;
    }
    
    return _scollView;
}

#pragma mark - Page Selection -

- (void)selectPageAtIndex:(NSInteger)index
{
    if (index != self.selectedPageIndex) {
        self.selectedPageIndex = index;
        [self hidePagesExcept:index];
        [self showPagesFullScreen:index];

        self.scollView.scrollEnabled = NO;
    } else {
        [self resetPages];
        self.selectedPageIndex = -1;
    }
}

- (void)resetPages
{
    NSInteger start = self.visiblePages.location;
    NSInteger stop = self.visiblePages.location + self.visiblePages.length;
    [UIView beginAnimations:@"starckReset" context:nil];
    [UIView setAnimationDuration:0.4];
    
    [UIView commitAnimations];
    [UIView animateWithDuration:0.4 animations:^{
        for (NSInteger i = start; i < stop; i++) {
            UIView *page = self.pages[i];
            CGRect rect = page.frame;
            rect.origin.y = OFFSET_TOP + i * self.pageHeight;
            page.frame = rect;
        }
    } completion:^(BOOL finished) {
        if (finished) {
            UIView *view = self.currentViewController.view;
            [view removeFromSuperview];
            [self.currentViewController removeFromParentViewController];
        }
        
    }];
    self.scollView.scrollEnabled = YES;
}

- (void)showPagesFullScreen:(NSInteger)index
{
    UIView *viewControllerView;
    UIView *page = (UIView *)self.pages[index];
    if (self.delegate) {
        self.currentViewController = [self.delegate viewControllerForStackView:self selectedPageAtIndex:index];
        viewControllerView = self.currentViewController.view;
        [page addSubview:viewControllerView];
        UIViewController *parentViewController = (UIViewController *)self.delegate;
        [parentViewController addChildViewController:self.currentViewController];
        [self.currentViewController willMoveToParentViewController:parentViewController];
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect rect  = page.frame;
        rect.origin.y = self.scollView.contentOffset.y;
        page.frame = rect;
    }];
}

- (void)hidePagesExcept:(NSInteger)index
{
    NSInteger start = self.visiblePages.location;
    NSInteger stop = self.visiblePages.location + self.visiblePages.length;
    [UIView beginAnimations:@"stackHide" context:nil];
    [UIView setAnimationDuration:0.4];
    for (NSInteger i = start; i < stop; i++) {
        if (self.selectedPageIndex != i) {
            UIView *page = (UIView *)self.pages[i];
            CGRect rect = page.frame;
            rect.origin.y = self.scollView.contentOffset.y + CGRectGetHeight(self.frame) - BOTTOM_OFFSET_HIDE + i * COLLAPSED_OFFSET;
            page.frame = rect;
        }
    }
    
    [UIView commitAnimations];
}

#pragma mark - Displaying Pages -

- (void)reloadVisiblePages
{
    
}

- (void)setPageAtOffset:(CGPoint)offset
{
    if (0 < self.pages.count) {
        CGPoint startPoint = CGPointMake(offset.x - CGRectGetMinX(self.scollView.frame), offset.y - CGRectGetMinY(self.scollView.frame));
        CGPoint endPoint = CGPointMake(MAX(0, startPoint.x) + CGRectGetWidth(self.bounds), MAX(OFFSET_TOP, startPoint.y) + CGRectGetHeight(self.bounds));
        
        NSInteger startIndex = 0;
        for (NSInteger i = 0; i < self.pages.count; i++) {
            if (self.pageHeight * (i+1) > startPoint.y) {
                startIndex = 1;
                break;
            }
        }
        
        NSInteger endIndex = 0;
        for (NSInteger i = 0; i < self.pages.count; i++) {
            if ((self.pageHeight * i < endPoint.y && self.pageHeight * (i + 1) >= endPoint.y) || i == self.pages.count - 1) {
                endIndex = i + 1;
                break;
            }
        }
        
        startIndex = MAX(startIndex - 1, 0);
        endIndex = MIN(endIndex, self.pages.count - 1);
        CGFloat pagedLength = endIndex - startIndex + 1;
        
        if (self.visiblePages.location != startIndex || self.visiblePages.length != pagedLength) {
            _visiblePages.location = startIndex;
            _visiblePages.length = pagedLength;
            for (NSInteger i = startIndex; i <= endIndex; i++) {
                [self setPageAtIndex:i];
            }
            
            for (NSInteger i = 0; i < startIndex; i++) {
                [self removePageAtIndex:i];
            }
            
            for (NSInteger i = endIndex + 1; i < self.pages.count; i++) {
                [self removePageAtIndex:i];
            }
        }
        
    }
}

- (void)setPageAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.pages.count) {
        UIView *page = self.pages[index];
        if ((!page || (NSObject *)page == [NSNull null]) && self.delegate) {
            page = [self.delegate stackView:self pageForIndex:index];
            [self.pages replaceObjectAtIndex:index withObject:page];
            page.frame = CGRectMake(0, index * self.pageHeight, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
            self.layer.zPosition = index;
        }
        
        if (!page.superview) {
            if ((index == 0 || self.pages[index - 1] == [NSNull null]) && index+1 < self.pages.count) {
                UIView *topPage = self.pages[index + 1];
                [self.scollView insertSubview:page belowSubview:topPage];
            } else {
                [self.scollView addSubview:page];
            }
            
            page.tag = index;
        }
        
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

- (UIView *)dequeueReusablePage
{
    UIView *page = [self.reusablePages lastObject];
    if (page && (NSObject *)page != [NSNull null]) {
        [self.reusablePages removeLastObject];
        return page;
    }
    
    return nil;
}

- (void)removePageAtIndex:(NSInteger)index
{
    UIView *page = self.pages[index];
    if (page && (NSObject *)page != [NSNull null]) {
        page.layer.transform = CATransform3DIdentity;
        [page removeFromSuperview];
        [self enqueueReusablePage:page];
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
    [self reloadVisiblePages];
}

@end
