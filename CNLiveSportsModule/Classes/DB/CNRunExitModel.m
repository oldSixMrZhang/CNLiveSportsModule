//
//  CNRunExitModel.m
//  CNLiveNetAdd
//
//  Created by open on 2019/6/24.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import "CNRunExitModel.h"

@implementation CNRunExitModel
- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet
{
    if (!resultSet) return nil;
    _userId = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"userId"]];
    _eventId = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"eventId"]];
    _startTime = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"startTime"]];
    _step = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"step"]];
    _time = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"time"]];
    _isStop = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"isStop"]];
    _stopTime = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"stopTime"]];
    _reStartTime = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"reStartTime"]];
    _stopCount = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"stopCount"]];
    _startAdd = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"startAdd"]];
    _stopAdd = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"stopAdd"]];
    _calorie = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"calorie"]];
    _eventData = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"eventData"]];
    return self;
}
@end
