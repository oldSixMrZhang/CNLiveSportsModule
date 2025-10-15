//
//  CNHistoryViewModel.h
//  CNLiveNetAdd
//
//  Created by open on 2019/6/5.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNHistoryTrackParam.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^HistoryQueryCompletionHandler) (NSArray *points);

@interface CNHistoryViewModel : NSObject<BTKTrackDelegate>
@property (nonatomic, copy) HistoryQueryCompletionHandler completionHandler;

- (void)queryHistoryWithParam:(CNHistoryTrackParam *)param;

@end

NS_ASSUME_NONNULL_END
