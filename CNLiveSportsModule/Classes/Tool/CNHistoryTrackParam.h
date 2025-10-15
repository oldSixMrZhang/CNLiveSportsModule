//
//  CNHistoryTrackParam.h
//  CNLiveNetAdd
//
//  Created by open on 2019/6/5.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
///历史轨迹参数model
@interface CNHistoryTrackParam : NSObject
@property (nonatomic, copy)   NSString *entityName;
@property (nonatomic, assign) NSUInteger startTime;
@property (nonatomic, assign) NSUInteger endTime;
@property (nonatomic, assign) BOOL isProcessed;
@property (nonatomic, strong) BTKQueryTrackProcessOption *processOption;
@property (nonatomic, assign) BTKTrackProcessOptionSupplementMode supplementMode;

@end

NS_ASSUME_NONNULL_END
