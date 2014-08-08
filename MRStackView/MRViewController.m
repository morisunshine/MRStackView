//
//  MRViewController.m
//  MRStackView
//
//  Created by sheldon on 14-8-8.
//  Copyright (c) 2014年 wheelab. All rights reserved.
//

#import "MRViewController.h"
#import "MRStackView.h"

@interface MRViewController () <MRStackViewDelegate>
{
    NSMutableArray *pages_;
}

@property (nonatomic, retain) MRStackView *stackView;
@property (nonatomic, retain) NSMutableArray *pages;

@end

@implementation MRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.stackView];
    self.view.backgroundColor = [UIColor grayColor];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters -

- (NSMutableArray *)pages
{
    if (!_pages) {
        _pages = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < 40; i++) {
            UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
            view.backgroundColor = [self colorRandom];
            [_pages addObject:view];
        }
    }
    
    return _pages;
}

- (MRStackView *)stackView
{
    if (!_stackView) {
        _stackView = [[MRStackView alloc] initWithFrame:self.view.bounds];
        _stackView.delegate = self;
    }
    
    return _stackView;
}

#pragma mark - MRStackView Delegate -

- (NSInteger)numberOfPagesForStackView:(MRStackView *)stackView
{
    return self.pages.count;
}

- (CGFloat)heightOfPagesForStackView:(MRStackView *)stackView
{
    return 80;
}

- (UIView *)stackView:(MRStackView *)stackView pageForIndex:(NSInteger)index
{
    UIView *thisView = [stackView dequeueReusablePage];
    if (!thisView) {
        thisView = [[UIView alloc] initWithFrame:self.view.bounds];
        thisView.backgroundColor = [self colorRandom];
        thisView.layer.cornerRadius = 5;
        thisView.layer.masksToBounds = YES;
    }
    return thisView;
}

- (void)stackView:(MRStackView *)stackView selectedPageAtIndex:(NSInteger)index
{
    
}

- (UIViewController *)viewControllerForStackView:(MRStackView *)tackView selectedPageAtIndex:(NSInteger)index
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.backgroundColor = [UIColor whiteColor];
    
    return viewController;
}

#pragma mark - Private Methods -

- (UIColor *)colorRandom
{
    NSMutableArray *comps = [NSMutableArray new];
    
    for (int i=0;i<3;i++) {
        NSUInteger r = arc4random_uniform(256);
        CGFloat randomColorComponent = (CGFloat)r/255.f;
        [comps addObject:@(randomColorComponent)];
    }
    
    UIColor *color = [UIColor colorWithRed:[comps[0] floatValue] green:[comps[1] floatValue] blue:[comps[2] floatValue] alpha:1.0];
    
    return color;
}

@end
