//
//  CNStartRunningViewController.h
//  CNLiveNetAdd
//
//  Created by open on 2019/6/13.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import "CNCommonViewController.h"
#import "CNLiveSportsDetailModel.h"

@protocol CNStartRunningVCDelegate <NSObject>

- (void)backToFrontVC;

@end
@interface CNStartRunningViewController : CNCommonViewController
@property (nonatomic, weak) id<CNStartRunningVCDelegate> delegate;
@property (nonatomic, strong) CNLiveSportsDetailModel       *sportsDetailModel;
@property (nonatomic, copy) NSString                        *eventID;
@property (nonatomic, copy) NSString                        *eventName;
@property (nonatomic, copy) NSString                        *pointsStr;

@end

