//
//  HalfCircleView.h
//  HalfProgressView
//
//  Created by Daniel on 2017/11/6.
//  Copyright © 2017年 skywind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HalfCircleView : UIView
@property (assign,nonatomic) CGFloat progress;

- (instancetype)initWithFrame:(CGRect)frame lineWidth:(CGFloat)lineWidth;

- (void)updateEndPoint;
- (void)animation;
@end
