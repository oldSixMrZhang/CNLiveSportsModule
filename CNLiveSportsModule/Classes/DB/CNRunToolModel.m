//
//  CNRunToolModel.m
//  CNLiveNetAdd
//
//  Created by open on 2019/7/4.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import "CNRunToolModel.h"

@implementation CNRunToolModel
- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet
{
    if (!resultSet) return nil;
    _userId = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"userId"]];
    _eventId = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"eventId"]];
    _startTime = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"startTime"]];
    _step = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"step"]];
    _endTime = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"endTime"]];
    _pointsStr = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"pointsStr"]];
    _pointsCount = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"pointsCount"]];
    _endRun = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"endRun"]];

    return self;
}
@end
