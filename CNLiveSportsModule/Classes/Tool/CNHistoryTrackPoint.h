//
//  CNHistoryTrackPoint.h
//  CNLiveNetAdd
//
//  Created by open on 2019/6/5.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNHistoryTrackPoint : NSObject
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) NSUInteger loctime;
@property (nonatomic, assign) NSUInteger direction;
@property (nonatomic, assign) double speed;
@end

NS_ASSUME_NONNULL_END
