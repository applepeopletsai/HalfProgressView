//
//  ProgressView.m
//  HalfProgressView
//
//  Created by Daniel on 2017/11/6.
//  Copyright © 2017年 skywind. All rights reserved.
//

#import "ProgressView.h"
#import "HalfCircleView.h"
#import <CoreText/CoreText.h>

@interface ProgressView ()
@property (strong, nonatomic) HalfCircleView *circle;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *progressTimer;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation ProgressView

#pragma mark - Initialize
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"StartTime"]) {
            _startTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"StartTime"];
            [self startAnimation];
        }
    }
    return self;
}

- (void)initUI {
    CGFloat lineWidth = 0.01 * self.bounds.size.width;;
    
    CGRect timeLabelFrame = CGRectMake(0, 0, self.bounds.size.width - 60 - lineWidth * 2, 30);
    CGPoint timeLabelCenter = self.center;
    timeLabelCenter.y -= 25;
    _timeLabel = [[UILabel alloc] initWithFrame:timeLabelFrame];
    _timeLabel.center = timeLabelCenter;
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.attributedText = [self setAttributeString:[self.timeFormatter stringFromDate:[NSDate date]]];
    [self addSubview:_timeLabel];
    
    CGRect dateLabelFrame = timeLabelFrame;
    CGPoint dateLabelCenter = timeLabelCenter;
    dateLabelCenter.y -= 45;
    _dateLabel = [[UILabel alloc]initWithFrame:dateLabelFrame];
    _dateLabel.center = dateLabelCenter;
    _dateLabel.textColor = [UIColor lightGrayColor];
    _dateLabel.textAlignment = NSTextAlignmentCenter;
    _dateLabel.font = [UIFont systemFontOfSize:17.0];
    _dateLabel.text = [self.dateFormatter stringFromDate:[NSDate date]];
    [self addSubview:_dateLabel];
    
    CGRect frame = CGRectMake(0, 0, 50, 20);
    CGPoint leftLabelCenter = self.center;
    leftLabelCenter.x = 20;
    leftLabelCenter.y += 20;
    
    CGPoint rightLabelCenter = self.center;
    rightLabelCenter.x = self.bounds.size.width - 20;
    rightLabelCenter.y += 20;
    
    UILabel *leftLabel = [[UILabel alloc]initWithFrame:frame];
    leftLabel.center = leftLabelCenter;
    leftLabel.textColor = [UIColor blackColor];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.font = [UIFont systemFontOfSize:17.0];
    leftLabel.text = @"上班";
    [self addSubview:leftLabel];
    
    UILabel *rightLabel = [[UILabel alloc]initWithFrame:frame];
    rightLabel.center = rightLabelCenter;
    rightLabel.textColor = [UIColor blackColor];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.font = [UIFont systemFontOfSize:17.0];
    rightLabel.text = @"下班";
    [self addSubview:rightLabel];
    
    _circle = [[HalfCircleView alloc] initWithFrame:self.bounds lineWidth:lineWidth];
    [self addSubview:_circle];
    
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    }
}

#pragma mark - Getter
- (NSDateFormatter *)timeFormatter {
    if (!_timeFormatter) {
        _timeFormatter = [[NSDateFormatter alloc] init];
        _timeFormatter.locale = [NSLocale currentLocale];
        [_timeFormatter setDateFormat:@"hh:mm  a"];
    }
    return _timeFormatter;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.locale = [NSLocale currentLocale];
        [_dateFormatter setDateFormat:@"MM月dd日"];
    }
    return _dateFormatter;
}

#pragma mark - Setter
- (void)setDate:(NSString *)date {
    _dateLabel.text = date;
}

- (void)setTime:(NSString *)time {
    _timeLabel.attributedText = [self setAttributeString:[self.timeFormatter stringFromDate:[NSDate date]]];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    _circle.progress = progress;
}

#pragma markk - Methods
- (void)startTimer {
    if (_progressTimer) return;
    
    if (!_startTime) {
        _startTime = [NSDate date];
    }
    [[NSUserDefaults standardUserDefaults] setObject:_startTime forKey:@"StartTime"];
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

- (void)endTimer {
    if (!_progressTimer) return;
    
    _startTime = nil;
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"StartTime"];
    [_progressTimer invalidate];
    _progressTimer = nil;
}

- (void)startAnimation {
    [self updateProgress];
    [_circle animation];
    [self startTimer];
}

- (void)updateProgress {
    // 距離打卡上班時間的秒數
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:_startTime];
    
    // 八小時秒數
//    NSInteger totalSeconds = 8 * 60 * 60;
    NSInteger totalSeconds = 180;
    
    // 百分比
    CGFloat percentage = seconds / totalSeconds;
    
    if (percentage > 1.0) {
        percentage = 1.0;
        [self endTimer];
    }
    
    _progress = percentage;
    _circle.progress = percentage;
}

- (void)updateTime {
    _timeLabel.attributedText = [self setAttributeString:[self.timeFormatter stringFromDate:[NSDate date]]];
    _dateLabel.text = [self.dateFormatter stringFromDate:[NSDate date]];
}

- (NSMutableAttributedString *)setAttributeString:(NSString *)string {
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    [attString addAttribute:NSForegroundColorAttributeName
                      value:[UIColor orangeColor]
                      range:NSMakeRange(0,attString.length)];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont systemFontOfSize:40.0]
                      range:NSMakeRange(0,attString.length - 2)];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont systemFontOfSize:16.0]
                      range:NSMakeRange(attString.length - 2,2)];
    // 上標
    [attString addAttribute:(NSString *)kCTSuperscriptAttributeName
                      value:@2
                      range:NSMakeRange(attString.length - 2,2)];
    return attString;
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}
@end
