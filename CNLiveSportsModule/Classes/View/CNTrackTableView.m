//
//  CNTrackTableView.m
//  CNLiveNetAdd
//
//  Created by open on 2019/6/19.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import "CNTrackTableView.h"

@implementation CNTrackTableView
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {//从底部往上区域手势事件不响应
    if (![self.layer containsPoint:point]) {
        return NO;
    }
    if (self.view) {
        if ([self.view.layer containsPoint:point]) {
            return YES;
        }
    }
    if (point.y < self.receiverHeight) {
        return NO;
    }
    return YES;
}

@end
