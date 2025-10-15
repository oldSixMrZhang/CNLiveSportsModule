//
//  CNTrackLoaclDataManager.h
//  CNLiveNetAdd
//
//  Created by open on 2019/6/21.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CNRunExitModel;
@class CNTrackUploadFailModel;
@class CNRunToolModel;

@interface CNTrackLoaclDataManager : NSObject
// 获取单例
+ (instancetype)shareManager;

// 插入数据
- (void)insertExitModel:(CNRunExitModel *)model;

// 根据user id获取数据
- (CNRunExitModel *)getExitModel:(NSString *)userId;

// 更新数据
- (void)updateExitModel:(CNRunExitModel *)model;

// 删除数据
- (void)deleteExitModel:(NSString *)userId;



// 插入数据
- (void)insertFUploadModel:(CNTrackUploadFailModel *)model;

// 根据user id获取数据list 并排序
- (NSArray *)getFUploadModel:(NSString *)userId;

// 删除单条数据，由开始时间
- (void)deleteFUploadModel:(CNTrackUploadFailModel *)model;


- (void)insertRunToolModel:(CNRunToolModel *)model;
- (void)updateRunToolModel:(CNRunToolModel *)model;
- (CNRunToolModel *)getRunToolModel:(NSString *)userId;
- (void)deleteRunToolModel:(CNRunToolModel *)model;
//- (CNLiveAlbumAudioListModel *)getWaitingModel;                    // 获取第一条等待的数据
//- (CNLiveAlbumAudioListModel *)getLastDownloadingModel;            // 获取最后一条正在下载的数据
//- (NSArray<CNLiveAlbumAudioListModel *> *)getAllCacheData;         // 获取所有数据
//- (NSArray<CNLiveAlbumAudioListModel *> *)getAllDownloadingData;   // 根据lastStateTime倒叙获取所有正在下载的数据
//- (NSArray<CNLiveAlbumAudioListModel *> *)getAllDownloadedData;    // 获取所有下载完成的数据
//- (NSArray<CNLiveAlbumAudioListModel *> *)getAllUnDownloadedData;  // 获取所有未下载完成的数据（包含正在下载、等待、暂停、错误）
//- (NSArray<CNLiveAlbumAudioListModel *> *)getAllWaitingData;       // 获取所有等待下载的数据
//- (CNLiveAlbumAudioListModel *)getModelwithActivityId:(NSString *)activityId; //根据ativityId获取数据
//
//
//// 更新数据
//- (void)updateWithModel:(CNLiveAlbumAudioListModel *)model option:(CNDBUpdateOption)option;
//
//// 删除数据
//- (void)deleteModelWithUrl:(NSString *)activityId;
@end


