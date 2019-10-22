//
//  ViewController.m
//  HalfProgressView
//
//  Created by Daniel on 2017/11/6.
//  Copyright © 2017年 skywind. All rights reserved.
//

#import "ViewController.h"
#import "ProgressView.h"

@interface ViewController ()
@property (strong, nonatomic) ProgressView *progressView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addCircle];
}

- (void)addCircle {
    CGFloat margin = 15.0f;
    CGFloat circleWidth = [UIScreen mainScreen].bounds.size.width - 2 * margin;
    _progressView = [[ProgressView alloc] initWithFrame:CGRectMake(0, 0, circleWidth, circleWidth)];
    _progressView.center = self.view.center;
    [self.view addSubview:_progressView];
}

- (IBAction)start:(id)sender {
    [_progressView startTimer];
}

- (IBAction)end:(id)sender {
    [_progressView endTimer];
}


@end
