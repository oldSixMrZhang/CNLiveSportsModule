//
//  CNReUpLoadTableViewCell.h
//  CNLiveNetAdd
//
//  Created by open on 2019/6/27.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CNTrackUploadFailModel;
#define kCNReUpLoadTableViewCell @"CNReUpLoadTableViewCell"
@class CNReUpLoadTableViewCell;
@protocol CNReUpLoadTableViewCellDelegate <NSObject>
- (void)needToReloadTable:(CNReUpLoadTableViewCell *)cell index:(NSInteger)index;

@end
@interface CNReUpLoadTableViewCell : UITableViewCell
@property (nonatomic, weak) id <CNReUpLoadTableViewCellDelegate> delegate;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) CNTrackUploadFailModel *model;
@property (nonatomic, copy) void(^deleteClickBlock)(NSInteger index);

@end
