//
//  ZZCountingLabel.h
//  CNLiveNetAdd
//
//  Created by open on 2019/6/14.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNRunEndCountingLabel : UILabel

@property (nonatomic, assign) CGFloat duration;

- (void)countingFrom:(CGFloat)fromValue to:(CGFloat)toValue;
- (void)countingFrom:(CGFloat)fromValue to:(CGFloat)toValue duration:(CGFloat)duration;

@end
