//
//  HalfCircleView.m
//  HalfProgressView
//
//  Created by Daniel on 2017/11/6.
//  Copyright © 2017年 skywind. All rights reserved.
//

#import "HalfCircleView.h"

//static CGFloat endPointMargin = 1.0;
static CGFloat endPointMargin = 21.0;
static CGFloat margin = 20.0;

@interface HalfCircleView ()
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (strong, nonatomic) UIImageView *endPoint;
@property (assign,nonatomic) CGFloat lineWidth;
@property (assign,nonatomic) CGFloat radius;
@property (strong, nonatomic) UIBezierPath *path;
@property (assign, nonatomic) BOOL startAnimation;
@end

@implementation HalfCircleView
- (instancetype)initWithFrame:(CGRect)frame lineWidth:(CGFloat)lineWidth {
    self = [super initWithFrame:frame];
    if (self) {
        _lineWidth = lineWidth;
        _startAnimation = NO;
        [self buildLayout];
    }
    return self;
}

- (void)buildLayout {
    CGFloat centerX = self.bounds.size.width / 2.0;
    CGFloat centerY = self.bounds.size.height / 2.0;
    _radius = (self.bounds.size.width - _lineWidth) / 2.0 - margin;
    
    _path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY) radius:_radius startAngle:M_PI endAngle:M_PI * 2 clockwise:YES];
    
    // 背景圓環
    CAShapeLayer *backLayer = [CAShapeLayer layer];
    backLayer.frame = self.bounds;
    backLayer.fillColor =  [[UIColor clearColor] CGColor];
    backLayer.strokeColor  = [UIColor lightGrayColor].CGColor;
    backLayer.lineWidth = _lineWidth;
    backLayer.path = [_path CGPath];
    backLayer.strokeEnd = 1;
    [self.layer addSublayer:backLayer];
    
    // 創建進度layer
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = self.bounds;
    _progressLayer.fillColor =  [[UIColor clearColor] CGColor];
    
    // 指定path的渲染顏色
    _progressLayer.strokeColor  = [[UIColor orangeColor] CGColor];
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.lineWidth = _lineWidth;
    _progressLayer.path = [_path CGPath];
    _progressLayer.strokeEnd = 0;
    [self.layer addSublayer:_progressLayer];
    
    // 設置漸變顏色
//    CAGradientLayer *gradientLayer =  [CAGradientLayer layer];
//    gradientLayer.frame = self.bounds;
//    gradientLayer.colors = @[[UIColor redColor],[UIColor yellowColor]];//要cgcolor
//    gradientLayer.startPoint = CGPointMake(0, 0);
//    gradientLayer.endPoint = CGPointMake(0, 1);
//    [gradientLayer setMask:_progressLayer]; // 用progressLayer來截取漸變層
//    [self.layer addSublayer:gradientLayer];
    
    // 用於顯示結束位置的icon
    _endPoint = [[UIImageView alloc] init];
//    _endPoint.frame = CGRectMake(0, 0, _lineWidth - endPointMargin * 2,_lineWidth - endPointMargin * 2);
    _endPoint.hidden = YES;
    _endPoint.frame = CGRectMake(0, 0, 10, 10);
    _endPoint.backgroundColor = [UIColor whiteColor];
    _endPoint.image = [UIImage imageNamed:@"icon"];
    _endPoint.layer.masksToBounds = YES;
    _endPoint.layer.cornerRadius = _endPoint.bounds.size.width / 2;
    [self updateEndPoint];
    [self addSubview:_endPoint];
}

- (void)setProgress:(CGFloat)progress {
    if (!_startAnimation) {
        _progress = progress;
        _progressLayer.strokeEnd = progress;
        [self updateEndPoint];
        [_progressLayer removeAllAnimations];
        [_endPoint.layer removeAllAnimations];
    }
}

- (void)animation {
    _startAnimation = YES;
    
    //Animate path
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 2.0;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0];
    pathAnimation.toValue = [NSNumber numberWithFloat:_progress];
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_progressLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    CAKeyframeAnimation *leafAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    leafAnimation.duration = 2.0;
    leafAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    leafAnimation.calculationMode = kCAAnimationCubicPaced; // 此屬性極為重要!!
    
    CGFloat centerX = self.bounds.size.width / 2.0;
    CGFloat centerY = self.bounds.size.height / 2.0;
    leafAnimation.path = [[UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY) radius:_radius startAngle:M_PI endAngle:M_PI * (1 + _progress) clockwise:YES] CGPath];
    [_endPoint.layer addAnimation:leafAnimation forKey:@"position"];
    
    [self performSelector:@selector(endAnimation) withObject:nil afterDelay:2.0];
}

- (void)endAnimation {
    _startAnimation = NO;
}

// 更新icon的位置
- (void)updateEndPoint {
    CGFloat angle = M_PI * _progress; // 轉成弧度
    NSInteger index = angle / M_PI_2; // 區分在第幾象限內
    CGFloat needAngle = angle - index * M_PI_2; // 用於計算正弦/餘弦的角度
    CGFloat x = 0,y = 0;
    
    switch (index) {
        case 0:
            NSLog(@"第四象限");
            x = _radius - cosf(needAngle) * _radius;
            y = _radius - sinf(needAngle) * _radius;
            break;
        case 1:
            NSLog(@"第一象限");
            x = _radius + sinf(needAngle) * _radius;
            y = _radius - cosf(needAngle) * _radius;
            break;
        case 2:
            NSLog(@"第二象限");
            x = _radius + cosf(needAngle) * _radius;
            y = _radius + sinf(needAngle) * _radius;
            break;
        case 3:
            NSLog(@"第三象限");
            x = _radius - sinf(needAngle) * _radius;
            y = _radius + cosf(needAngle) * _radius;
            break;
        default: break;
    }
    
    //更新圓環的frame
//    CGRect rect = _endPoint.frame;
//    rect.origin.x = x + endPointMargin;
//    rect.origin.y = y + endPointMargin;
//    _endPoint.frame = rect;
    
    CGPoint center = _endPoint.center;
    center.x = x + endPointMargin;
    center.y = y + endPointMargin;
    _endPoint.center = center;
    
    // 移動到最前
    [self bringSubviewToFront:_endPoint];
    
    _endPoint.hidden = NO;
    if (_progress == 0) {
        _endPoint.hidden = YES;
   }
}

@end

