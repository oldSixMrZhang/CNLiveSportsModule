//
//  CNTraceConst.h
//  CNLiveNetAdd
//
//  Created by open on 2019/6/5.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/** CNLocationGPSState 枚举识别GPS信号状态
 *
 */
typedef NS_ENUM(int, CNLocationGPSState) {
    CNLocationGPSStateGood = 0,    ///GPS好
    CNLocationGPSStateMedium,      ///GPS中
    CNLocationGPSStatePoor,        ///GPS差
    CNLocationGPSStateNull         ///GPS无
};

@interface CNTraceConst : NSObject
//FOUNDATION_EXPORT NSString * const AK;
//FOUNDATION_EXPORT NSString * const MCODE;
//FOUNDATION_EXPORT NSUInteger const serviceID;
FOUNDATION_EXPORT NSString * const TrackServiceOperationResultNotification;
FOUNDATION_EXPORT NSString * const TrackServiceGetPushMessageNotification;

@end

NS_ASSUME_NONNULL_END
