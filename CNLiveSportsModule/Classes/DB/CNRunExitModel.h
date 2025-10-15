//
//  CNRunExitModel.h
//  CNLiveNetAdd
//
//  Created by open on 2019/6/24.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNRunExitModel : NSObject
//用户id
@property (nonatomic, copy)   NSString          *userId;

//赛事id
@property (nonatomic, copy)   NSString          *eventId;

//开始时间
@property (nonatomic, copy)   NSString          *startTime;

//当前步数 30s存一次
@property (nonatomic, copy)   NSString          *step;
//是否暂停
@property (nonatomic, copy)   NSString          *isStop;

//暂停时间
@property (nonatomic, copy)   NSString          *stopTime;
//重新开始的时间
@property (nonatomic, copy)   NSString          *reStartTime;
//暂停次数
@property (nonatomic, copy)   NSString          *stopCount;




//////////////////////////////////////////////////
//记录哪一天
@property (nonatomic, copy)   NSString          *time;

//开始的地点
@property (nonatomic, copy)   NSString          *startAdd;

//结束地点
@property (nonatomic, copy)   NSString          *stopAdd;

//卡路里
@property (nonatomic, copy)   NSString          *calorie;

//服务器赛道数据
@property (nonatomic, copy)   NSString          *eventData;

// 根据数据库查询结果初始化
- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet;
@end

NS_ASSUME_NONNULL_END
