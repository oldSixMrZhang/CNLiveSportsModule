//
//  CNTrackUploadFailModel.h
//  CNLiveNetAdd
//
//  Created by open on 2019/6/26.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CNTrackUploadFailModel : NSObject
//用户id
@property (nonatomic, copy)   NSString          *userId;

//赛事id
@property (nonatomic, copy)   NSString          *eventId;

//赛事名称
@property (nonatomic, copy)   NSString          *eventName;

//开始时间
@property (nonatomic, copy)   NSString          *startTime;

//结束时间
@property (nonatomic, copy)   NSString          *endTime;

//是否暂停
@property (nonatomic, copy)   NSString          *isStop;

//暂停时间
@property (nonatomic, copy)   NSString          *stopTime;

//重新开始的时间
@property (nonatomic, copy)   NSString          *reStartTime;

//公里
@property (nonatomic, copy)   NSString          *totalKM;

//用时
@property (nonatomic, copy)   NSString          *totalTime;

//配速
@property (nonatomic, copy)   NSString          *speed;

//步数
@property (nonatomic, copy)   NSString          *totalStep;

//赛事的终点坐标是个字典
@property (nonatomic, copy)   NSString          *endCoordsDictStr;

//运营打的点
@property (nonatomic, copy)   NSString          *pointsArrStr;

//----
//开始的地点
@property (nonatomic, copy)   NSString          *startLoaction;
//结束的地点
@property (nonatomic, copy)   NSString          *endLocation;

// 根据数据库查询结果初始化
- (instancetype)initWithFMResultSet:(FMResultSet *)resultSet;
@end

