//
//  CNTrackServiceManager.h
//  CNLiveNetAdd
//
//  Created by open on 2019/6/10.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ServiceOperationType) {
    TRACK_SERVICE_OPERATION_TYPE_START_SERVICE,
    TRACK_SERVICE_OPERATION_TYPE_STOP_SERVICE,
    TRACK_SERVICE_OPERATION_TYPE_START_GATHER,
    TRACK_SERVICE_OPERATION_TYPE_STOP_GATHER,
};
@class CNRunExitModel;

@protocol CNTrackServiceManagerDelegate <NSObject>

- (void)currentPedometer:(CNRunExitModel *)model;
- (void)currentToolPedometer:(NSInteger)stepCount;

@end
@interface CNTrackServiceManager : NSObject <BTKTraceDelegate>

@property (nonatomic, weak) id <CNTrackServiceManagerDelegate>delegate;
+(CNTrackServiceManager *)defaultManager;
@property (nonatomic, assign) BOOL isStartRecord;

@property (nonatomic, assign) BOOL noAcceptFenceNotify;
@property (nonatomic, assign) BOOL isClickGoOn;

/**
 标志是否已经开启轨迹服务
 */
@property (nonatomic, assign) BOOL isServiceStarted;

/**
 标志是否已经开始采集
 */
@property (nonatomic, assign) BOOL isGatherStarted;

/**
 开启轨迹服务

 @param startServiceOption 开启服务的选项
 */
-(void)startServiceWithOption:(BTKStartServiceOption *)startServiceOption;

/**
 停止轨迹服务
 */
-(void)stopService;

/**
 开始采集
 */
-(void)startGather;

/**
 停止采集
 */
-(void)stopGather;



//////////////////

- (void)recordStep:(NSDate *)date isUser:(BOOL)isU;
@end
