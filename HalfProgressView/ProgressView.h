//
//  ProgressView.h
//  HalfProgressView
//
//  Created by Daniel on 2017/11/6.
//  Copyright © 2017年 skywind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *time;
@property (assign,nonatomic) CGFloat progress;

- (void)startTimer;
- (void)endTimer;
@end
