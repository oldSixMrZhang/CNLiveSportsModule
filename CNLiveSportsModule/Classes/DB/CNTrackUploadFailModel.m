//
//  CNTrackUploadFailModel.m
//  CNLiveNetAdd
//
//  Created by open on 2019/6/26.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import "CNTrackUploadFailModel.h"

@implementation CNTrackUploadFailModel
- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet
{
    if (!resultSet) return nil;
    _userId = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"userId"]];
    _eventId = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"eventId"]];
    _eventName = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"eventName"]];
    _startTime = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"startTime"]];
    _endTime = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"endTime"]];
    _isStop = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"isStop"]];
    _stopTime = [NSString stringWithFormat:@"%@",[resultSet objectForColumn:@"stopTime"]];
    _reStartTime = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"reStartTime"]];
    _totalKM = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"totalKM"]];
    _totalTime = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"totalTime"]];
    _speed = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"speed"]];
    _totalStep = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"totalStep"]];
    _endCoordsDictStr = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"endCoordsDictStr"]];
    _pointsArrStr = [NSString stringWithFormat:@"%@", [resultSet objectForColumn:@"pointsArrStr"]];
    return self;
}
@end
