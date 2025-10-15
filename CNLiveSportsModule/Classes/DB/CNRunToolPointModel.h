//
//  CNRunToolPointModel.h
//  CNLiveNetAdd
//
//  Created by open on 2019/7/4.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**打点的model*/
@interface CNRunToolPointModel : NSObject


//经度
@property (nonatomic, copy) NSString *latitude;
//纬度
@property (nonatomic, copy) NSString *longitude;

//地点名称
@property (nonatomic, copy) NSString *pointName;
@end

NS_ASSUME_NONNULL_END
