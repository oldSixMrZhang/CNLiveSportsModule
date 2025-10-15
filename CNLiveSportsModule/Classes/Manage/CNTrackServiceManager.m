//
//  CNTrackServiceManager.m
//  CNLiveNetAdd
//
//  Created by open on 2019/6/10.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import "CNTrackServiceManager.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreMotion/CoreMotion.h>
#import "CNRunExitModel.h"
#import "CNTrackLoaclDataManager.h"
#import "CNRunToolModel.h"

#define GLOBAL_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

static NSString * const YYPushMessageNotificationIdentifier = @"YYPushMessageNotificationIdentifier";

@implementation CNTrackServiceManager{
    CMPedometer *_pedometer;//计步器
    NSInteger   _lastStepCount;//最新的步数或起止步数
    BOOL        _isUser;
}

+(CNTrackServiceManager *)defaultManager {
    static CNTrackServiceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CNTrackServiceManager alloc] init];
    });
    return manager;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _isServiceStarted = FALSE;
        _isGatherStarted = FALSE;
    }
    return self;
}

#pragma mark private function
-(void)startServiceWithOption:(BTKStartServiceOption *)startServiceOption {
    dispatch_async(GLOBAL_QUEUE, ^{
        [[BTKAction sharedInstance] startService:startServiceOption delegate:self];
        [[BTKAction sharedInstance] changeGatherAndPackIntervals:2 packInterval:10 delegate:self];
        [[BTKAction sharedInstance] setLocationAttributeWithActivityType:CLActivityTypeFitness desiredAccuracy:kCLLocationAccuracyBest distanceFilter:1];
    });
}

-(void)stopService {
    dispatch_async(GLOBAL_QUEUE, ^{
        [[BTKAction sharedInstance] stopService:self];
    });
}

-(void)startGather {
    dispatch_async(GLOBAL_QUEUE, ^{
        [[BTKAction sharedInstance] startGather:self];
    });
}

-(void)stopGather {
    dispatch_async(GLOBAL_QUEUE, ^{
        [[BTKAction sharedInstance] stopGather:self];
    });
}

#pragma mark - BTKTraceDelegate
-(void)onStartService:(BTKServiceErrorCode)error {
    // 维护状态标志
    if (error == BTK_START_SERVICE_SUCCESS || error == BTK_START_SERVICE_SUCCESS_BUT_OFFLINE) {
        NSLog(@"轨迹服务开启成功");
        self.isServiceStarted = TRUE;
    } else {
        NSLog(@"轨迹服务开启失败");
    }
    // 构造广播内容
    NSString *title = nil;
    NSString *message = nil;
    switch (error) {
        case BTK_START_SERVICE_SUCCESS:
            title = @"轨迹服务开启成功";
            message = @"成功登录到服务端";
            break;
        case BTK_START_SERVICE_SUCCESS_BUT_OFFLINE:
            title = @"轨迹服务开启成功";
            message = @"当前网络不畅，未登录到服务端。网络恢复后SDK会自动重试";
            break;
        case BTK_START_SERVICE_PARAM_ERROR:
            title = @"轨迹服务开启失败";
            message = @"参数错误,点击右上角设置按钮设置参数";
            break;
        case BTK_START_SERVICE_INTERNAL_ERROR:
            title = @"轨迹服务开启失败";
            message = @"SDK服务内部出现错误";
            break;
        case BTK_START_SERVICE_NETWORK_ERROR:
            title = @"轨迹服务开启失败";
            message = @"网络异常";
            break;
        case BTK_START_SERVICE_AUTH_ERROR:
            title = @"轨迹服务开启失败";
            message = @"鉴权失败，请检查AK和MCODE等配置信息";
            break;
        case BTK_START_SERVICE_IN_PROGRESS:
            title = @"轨迹服务开启失败";
            message = @"正在开启服务，请稍后再试";
            break;
        case BTK_SERVICE_ALREADY_STARTED_ERROR:
            title = @"轨迹服务开启失败";
            message = @"已经成功开启服务，请勿重复开启";
            break;
        default:
            title = @"轨迹服务开启失败";
            message = @"轨迹服务开启结果未知";
            break;
    }
    NSDictionary *info = @{@"type":@(TRACK_SERVICE_OPERATION_TYPE_START_SERVICE),
                           @"title":title,
                           @"message":message,
                           };
    // 发送广播
    [[NSNotificationCenter defaultCenter] postNotificationName:TrackServiceOperationResultNotification object:nil userInfo:info];
}

-(void)onStopService:(BTKServiceErrorCode)error {
    // 维护状态标志
    if (error == BTK_STOP_SERVICE_NO_ERROR) {
        NSLog(@"轨迹服务停止成功");
        self.isServiceStarted = FALSE;
    } else {
        NSLog(@"轨迹服务停止失败");
    }
    // 构造广播内容
    NSString *title = nil;
    NSString *message = nil;
    switch (error) {
        case BTK_STOP_SERVICE_NO_ERROR:
            title = @"轨迹服务停止成功";
            message = @"SDK已停止工作";
            break;
        case BTK_STOP_SERVICE_NOT_YET_STARTED_ERROR:
            title = @"轨迹服务停止失败";
            message = @"还没有开启服务，无法停止服务";
            break;
        case BTK_STOP_SERVICE_IN_PROGRESS:
            title = @"轨迹服务停止失败";
            message = @"正在停止服务，请稍后再试";
            break;
        default:
            title = @"轨迹服务停止失败";
            message = @"轨迹服务停止结果未知";
            break;
    }
    NSDictionary *info = @{@"type":@(TRACK_SERVICE_OPERATION_TYPE_STOP_SERVICE),
                           @"title":title,
                           @"message":message,
                           };
    // 发送广播
    [[NSNotificationCenter defaultCenter] postNotificationName:TrackServiceOperationResultNotification object:nil userInfo:info];
}

-(void)onStartGather:(BTKGatherErrorCode)error {
    // 维护状态标志
    if (error == BTK_START_GATHER_SUCCESS) {
        NSLog(@"开始采集成功");
        self.isGatherStarted = TRUE;
    } else {
        NSLog(@"开始采集失败");
    }
    // 构造广播内容
    NSString *title = nil;
    NSString *message = nil;
    switch (error) {
        case BTK_START_GATHER_SUCCESS:
            title = @"开始采集成功";
            message = @"开始采集成功";
            break;
        case BTK_GATHER_ALREADY_STARTED_ERROR:
            title = @"开始采集失败";
            message = @"已经在采集轨迹，请勿重复开始";
            break;
        case BTK_START_GATHER_BEFORE_START_SERVICE_ERROR:
            title = @"开始采集失败";
            message = @"开始采集必须在开始服务之后调用";
            break;
        case BTK_START_GATHER_LOCATION_SERVICE_OFF_ERROR:
            title = @"开始采集失败";
            message = @"没有开启系统定位服务";
            break;
        case BTK_START_GATHER_LOCATION_ALWAYS_USAGE_AUTH_ERROR:
            title = @"开始采集失败";
            message = @"没有开启后台定位权限";
            break;
        case BTK_START_GATHER_INTERNAL_ERROR:
            title = @"开始采集失败";
            message = @"SDK服务内部出现错误";
            break;
        default:
            title = @"开始采集失败";
            message = @"开始采集轨迹的结果未知";
            break;
    }
    NSDictionary *info = @{@"type":@(TRACK_SERVICE_OPERATION_TYPE_START_GATHER),
                           @"title":title,
                           @"message":message,
                           };
    // 发送广播
    [[NSNotificationCenter defaultCenter] postNotificationName:TrackServiceOperationResultNotification object:nil userInfo:info];
}

-(void)onStopGather:(BTKGatherErrorCode)error {
    // 维护状态标志
    if (error == BTK_STOP_GATHER_NO_ERROR) {
        NSLog(@"停止采集成功");
        self.isGatherStarted = FALSE;
    } else {
        NSLog(@"停止采集失败");
    }
    // 构造广播内容
    NSString *title = nil;
    NSString *message = nil;
    switch (error) {
        case BTK_STOP_GATHER_NO_ERROR:
            title = @"停止采集成功";
            message = @"SDK停止采集本设备的轨迹信息";
            break;
        case BTK_STOP_GATHER_NOT_YET_STARTED_ERROR:
            title = @"停止采集失败";
            message = @"还没有开始采集，无法停止";
            break;
        default:
            title = @"停止采集失败";
            message = @"停止采集轨迹的结果未知";
            break;
    }
    NSDictionary *info = @{@"type":@(TRACK_SERVICE_OPERATION_TYPE_STOP_GATHER),
                           @"title":title,
                           @"message":message,
                           };
    // 发送广播
    [[NSNotificationCenter defaultCenter] postNotificationName:TrackServiceOperationResultNotification object:nil userInfo:info];
}

-(void)onGetPushMessage:(BTKPushMessage *)message {
    if (self.noAcceptFenceNotify) {
        return;
    }
    NSLog(@">>>>>>>>>>>接收到BD通知<<<<<<<<<<<<<");
    // 不是地理围栏的报警，不解析
    if (message.type != 0x03 && message.type != 0x04) {
        return;
    }
    BTKPushMessageFenceAlarmContent *content = (BTKPushMessageFenceAlarmContent *)message.content;
    NSString *fenceID = [NSString stringWithFormat:@"%lu", (unsigned long)content.fenceID];
    NSString *monitoredObject = [NSString stringWithFormat:@"「%@」", content.monitoredObject];
    NSString *action = nil;
    if (content.actionType == BTK_FENCE_MONITORED_OBJECT_ACTION_TYPE_ENTER) {
        action = @"进入";
    } else {
        action = @"离开";
    }
    NSString *fenceType = nil;
    if (message.type == 0x03) {
        fenceType = @"服务端围栏";
    } else {
        fenceType = @"客户端围栏";
    }
    // 通过触发报警的轨迹点，解析出触发报警的时间
    BTKFenceAlarmLocationPoint *currentPoint = content.currentPoint;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *alarmDate = [NSDate dateWithTimeIntervalSince1970:currentPoint.loctime];
    NSString *alarmDateStr = [dateFormatter stringFromDate:alarmDate];
    
    NSString *pushMessage = [NSString stringWithFormat:@"终端 %@ 在 %@ %@ %@%@", monitoredObject, alarmDateStr, action, fenceType, fenceID];
    NSDictionary *dict = @{
                           @"action":action,
                           @"fenceType":fenceType,
                           @"fenceID":fenceID
                           };
    NSLog(@"推送消息: %@", pushMessage);
    [[NSNotificationCenter defaultCenter] postNotificationName:TrackServiceGetPushMessageNotification object:nil userInfo:@{@"message":dict}];
}

-(void)setIsStartRecord:(BOOL)isStartRecord{
    _isStartRecord = isStartRecord;
    if (!isStartRecord) {
        if (_pedometer) {
            [_pedometer stopPedometerUpdates];
            _pedometer = nil;
        }
    }
}

- (void)recordStep:(NSDate *)date isUser:(BOOL)isU{
    if (!self.isStartRecord) {
        return;
    }
    _isUser = isU;
    if (isU) {
        CNRunExitModel *tempM = [[CNTrackLoaclDataManager shareManager] getExitModel:CNUserShareModelUid];
        if (tempM.step.length > 0 && ![tempM.step isEqualToString:@"<null>"]) {
            _lastStepCount = [tempM.step integerValue];
        }else{
            _lastStepCount = 0;
        }
    }else{
        CNRunToolModel *model = [[CNTrackLoaclDataManager shareManager] getRunToolModel:CNUserShareModelUid];
        if (model.step.length > 0 && ![model.step isEqualToString:@"<null>"]) {
            _lastStepCount = [model.step integerValue];
        }else{
            _lastStepCount = 0;
        }
    }
    

    //开始记录步数
    if([CMPedometer isStepCountingAvailable]){
        //开始计步
        _pedometer = [CMPedometer new];
        [_pedometer startPedometerUpdatesFromDate:date withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
            [self performSelectorOnMainThread:@selector(updateStepTotal:) withObject:pedometerData waitUntilDone:YES];
        }];
    }
}

//更新步数和公里数和配速
- (void)updateStepTotal:(CMPedometerData *)pedometerData{
    if (_isUser) {
        CNRunExitModel *tempM = [[CNTrackLoaclDataManager shareManager] getExitModel:CNUserShareModelUid];
        tempM.step = [NSString stringWithFormat:@"%ld",([pedometerData.numberOfSteps integerValue]  + _lastStepCount)];
        [[CNTrackLoaclDataManager shareManager] updateExitModel:tempM];
        if ([self.delegate respondsToSelector:@selector(currentPedometer:)]) {
            [self.delegate currentPedometer:tempM];
        }
    }else{
        CNRunToolModel *model = [[CNTrackLoaclDataManager shareManager] getRunToolModel:CNUserShareModelUid];
        NSInteger step = [pedometerData.numberOfSteps integerValue] +_lastStepCount;
        model.step = [NSString stringWithFormat:@"%ld",([pedometerData.numberOfSteps integerValue]  + _lastStepCount)];
        [[CNTrackLoaclDataManager shareManager] updateRunToolModel:model];
        if ([self.delegate respondsToSelector:@selector(currentToolPedometer:)]) {
            [self.delegate currentToolPedometer:step];
        }
    }
}
@end
