//
//  CNRunToolModel.h
//  CNLiveNetAdd
//
//  Created by open on 2019/7/4.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CNRunToolPointModel;
NS_ASSUME_NONNULL_BEGIN

@interface CNRunToolModel : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *step;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, copy) NSString *pointsStr;
@property (nonatomic, copy) NSString *pointsCount;
@property (nonatomic, copy) NSString *endRun;
- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet;
@end

NS_ASSUME_NONNULL_END
