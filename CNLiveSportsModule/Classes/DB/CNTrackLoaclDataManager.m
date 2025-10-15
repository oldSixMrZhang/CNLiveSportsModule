//
//  CNTrackLoaclDataManager.m
//  CNLiveNetAdd
//
//  Created by open on 2019/6/21.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import "CNTrackLoaclDataManager.h"
#import "CNRunExitModel.h"
#import "CNTrackUploadFailModel.h"
#import "CNRunToolModel.h"

@interface CNTrackLoaclDataManager ()
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, copy) NSString *uploadFailPath;
@property (nonatomic, copy) NSString *runExitPath;
@property (nonatomic, copy) NSString *runToolPath;

@end

@implementation CNTrackLoaclDataManager
+ (instancetype)shareManager
{
    static CNTrackLoaclDataManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _runExitPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"CNTrackRunExit.sqlite"];
        _uploadFailPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"CNTrackUploadFail.sqlite"];
        _runToolPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"CNTrackRunTool.sqlite"];
        [self createUploadFailedDB];
        [self createRunExitDB];
        [self createRunToolDB];
    }
    return self;
}


//创建上传失败的数据库
- (void)createUploadFailedDB{
    // 数据库文件路径
    NSString *path = self.uploadFailPath;
    // 创建队列对象，内部会自动创建一个数据库, 并且自动打开
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        // 创表
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_UploadFail (id integer PRIMARY KEY AUTOINCREMENT, userId text, eventId text,eventName text,startTime text,endTime text,isStop text,stopTime text,reStartTime text,totalKM text,totalTime text,speed text,totalStep text,endCoordsDictStr text,pointsArrStr text,startLoaction text,endLocation text)"];
        //        if (![db columnExists:@"channelName" inTableWithName:@"t_videoCaches"] ) { //新添字段,先判断数据里有没有,没有,添加
        //            NSString *channelName = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",@"t_videoCaches",@"channelName"];
        //            BOOL isSuccess = [db executeUpdate:channelName];
        //            if (isSuccess) {
        //                NSLog(@"插入成功");
        //            }else {
        //                NSLog(@"插入失败");
        //            }
        //        }
        if (result) {
            NSLog(@"UploadFail数据表创建成功");
        }else {
            NSLog(@"UploadFail数据表创建失败");
        }
    }];
}
//创建APP退出或返回功能的数据库
- (void)createRunExitDB{
    // 数据库文件路径
    NSString *path = self.runExitPath;
    // 创建队列对象，内部会自动创建一个数据库, 并且自动打开
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];

    [_dbQueue inDatabase:^(FMDatabase *db) {
        // 创表
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_RunExit (id integer PRIMARY KEY AUTOINCREMENT, userId text, eventId text,startTime text,step text,time text,isStop text,stopTime text,reStartTime text,stopCount text,startAdd text,stopAdd text,calorie text,eventData text)"];
//        if (![db columnExists:@"channelName" inTableWithName:@"t_videoCaches"] ) { //新添字段,先判断数据里有没有,没有,添加
//            NSString *channelName = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",@"t_videoCaches",@"channelName"];
//            BOOL isSuccess = [db executeUpdate:channelName];
//            if (isSuccess) {
//                NSLog(@"插入成功");
//            }else {
//                NSLog(@"插入失败");
//            }
//        }
        if (result) {
            NSLog(@"runExit数据表创建成功");
        }else {
            NSLog(@"runExit数据表创建失败");
        }
    }];
}

- (void)createRunToolDB{
    // 数据库文件路径
    NSString *path = self.runToolPath;
    // 创建队列对象，内部会自动创建一个数据库, 并且自动打开
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        // 创表
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_RunTool (id integer PRIMARY KEY AUTOINCREMENT, userId text, eventId text,startTime text,step text,endTime text,pointsStr text,pointsCount text,endRun text)"];
        if (result) {
            NSLog(@"runTool数据表创建成功");
        }else {
            NSLog(@"runTool数据表创建失败");
        }
    }];
}

#pragma mark - 插入一条数据
- (void)insertExitModel:(CNRunExitModel *)model
{
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.runExitPath];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"INSERT INTO t_RunExit (userId,eventId,startTime,step,time,isStop,stopTime,reStartTime,stopCount,startAdd,stopAdd,calorie,eventData) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)", model.userId.length>0?model.userId :@"",
                       model.eventId.length>0?model.eventId:@"",
                       model.startTime.length>0?model.startTime:@"",
                       model.step.length>0?model.step:@"",
                       model.time.length>0?model.time:@"",
                       model.isStop.length>0?model.isStop:@"",
                       model.stopTime.length>0?model.stopTime:@"",
                       model.reStartTime.length>0?model.reStartTime:@"",
                       model.stopCount.length>0?model.stopCount:@"",
                       model.startAdd.length>0?model.startAdd:@"",
                       model.stopAdd.length>0?model.stopAdd:@"",
                       model.calorie.length>0?model.calorie:@"",
                       model.eventData.length>0?model.eventData :@""];//,model.schedule ?model.schedule:@"",model.channelName ? model.channelName:@"",model.time ? model.time:@"",model.url, model.resumeData, [NSNumber numberWithInteger:model.totalFileSize], [NSNumber numberWithInteger:model.tmpFileSize], [NSNumber numberWithInteger:model.state], [NSNumber numberWithFloat:model.progress], [NSNumber numberWithDouble:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0],model.fileSize];
        if (result) {
            NSLog(@"插入成功");
        }else {
            NSLog(@"插入失败");
        }
    }];
}

// 根据赛事id获取数据
- (CNRunExitModel *)getExitModel:(NSString *)userId{
    __block CNRunExitModel *model = nil;
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.runExitPath];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM t_RunExit WHERE userId = ?", userId];
        while ([resultSet next]) {
            model = [[CNRunExitModel alloc] initWithFMResultSet:resultSet];
        }
    }];
    return model;
}

// 更新数据
- (void)updateExitModel:(CNRunExitModel *)model{
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.runExitPath];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"UPDATE t_RunExit SET eventId = ?, startTime = ?, step = ?, time = ?, isStop = ?, stopTime = ?,reStartTime = ?,stopCount = ?, startAdd = ?, stopAdd = ? ,calorie = ? ,eventData = ? WHERE userId = ?", model.eventId, model.startTime,model.step,model.time,model.isStop,model.stopTime,model.reStartTime,model.stopCount,
         model.startAdd,model.stopAdd,model.calorie,model.eventData,model.userId];
        if (result) {
            NSLog(@"更新成功");
        }else {
            NSLog(@"更新失败");
        }
    }];
}

// 删除数据
- (void)deleteExitModel:(NSString *)userId{
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.runExitPath];
    [_dbQueue inDatabase:^(FMDatabase *db) { // where 后面跟的是条件
        BOOL result = [db executeUpdate:@"DELETE FROM t_RunExit WHERE userId = ?", userId];
        if (result) {
            NSLog(@"删除成功");
        }else {
            NSLog(@"删除失败");
        }
    }];
}

// 插入数据
- (void)insertFUploadModel:(CNTrackUploadFailModel *)model{
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.uploadFailPath];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"INSERT INTO t_UploadFail (userId,eventId,eventName,startTime,endTime,isStop,stopTime,reStartTime,totalKM,totalTime,speed,totalStep,endCoordsDictStr,pointsArrStr,startLoaction,endLocation) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?)",
                       model.userId.length>0?model.userId :@"",
                       model.eventId.length>0?model.eventId:@"", model.eventName.length>0?model.eventName:@"",
                       model.startTime.length>0?model.startTime:@"",
                       model.endTime.length>0?model.endTime:@"",
                       model.isStop.length>0?model.isStop:@"",
                       model.stopTime.length>0?model.stopTime:@"",
                       model.reStartTime.length>0?model.reStartTime:@"",
                       model.totalKM.length>0?model.totalKM:@"",
                       model.totalTime.length>0?model.totalTime:@"",
                       model.speed.length>0?model.speed:@"",
                       model.totalStep.length>0?model.totalStep:@"",model.endCoordsDictStr.length>0?model.endCoordsDictStr:@"",model.pointsArrStr.length>0?model.pointsArrStr:@"",model.startLoaction.length>0?model.startLoaction:@"",model.endLocation.length>0?model.endLocation:@""];
        if (result) {
            NSLog(@"插入成功");
        }else {
            NSLog(@"插入失败");
        }
    }];
}

// 根据user id获取数据list 并排序
- (NSArray *)getFUploadModel:(NSString *)userId{
//     order by lastStateTime desc
    __block NSArray<CNTrackUploadFailModel *> *array = nil;
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.uploadFailPath];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM t_UploadFail WHERE userId = ?", userId];
        NSMutableArray *tmpArr = [NSMutableArray array];
        while ([resultSet next]) {
            [tmpArr addObject:[[CNTrackUploadFailModel alloc] initWithFMResultSet:resultSet]];
        }
        array = tmpArr;
    }];
    return array;
}

// 删除单条数据，由开始时间
- (void)deleteFUploadModel:(CNTrackUploadFailModel *)model{
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.uploadFailPath];
    [_dbQueue inDatabase:^(FMDatabase *db) { // where 后面跟的是条件
        BOOL result = [db executeUpdate:@"DELETE FROM t_UploadFail WHERE startTime = ?", model.startTime];
        if (result) {
            NSLog(@"删除成功");
        }else {
            NSLog(@"删除失败");
        }
    }];
}

- (void)insertRunToolModel:(CNRunToolModel *)model
{
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.runToolPath];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"INSERT INTO t_RunTool (userId,eventId,startTime,step,endTime,pointsStr,pointsCount,endRun) VALUES (?, ?, ?,?, ?, ?,?,?)", model.userId.length>0?model.userId :@"",
                       model.eventId.length>0?model.eventId:@"",
                       model.startTime.length>0?model.startTime:@"",
                       model.step.length>0?model.step:@"",
                       model.endTime.length>0?model.endTime:@"",
                       model.pointsStr.length>0?model.pointsStr:@"",model.pointsCount.length>0?model.pointsCount:@"",model.endRun.length>0?model.endRun:@""];
        if (result) {
            NSLog(@"插入成功");
        }else {
            NSLog(@"插入失败");
        }
    }];
}

// 更新数据
- (void)updateRunToolModel:(CNRunToolModel *)model{
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.runToolPath];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"UPDATE t_RunTool SET eventId = ?, startTime = ?,step = ?, endTime = ?, pointsStr = ?, pointsCount = ?,endRun = ? WHERE userId = ?", model.eventId, model.startTime,model.step,model.endTime,model.pointsStr,model.pointsCount,model.endRun,model.userId];
        if (result) {
            NSLog(@"更新成功");
        }else {
            NSLog(@"更新失败");
        }
    }];
}

// 根据赛事id获取数据
- (CNRunToolModel *)getRunToolModel:(NSString *)userId{
    __block CNRunToolModel *model = nil;
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.runToolPath];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM t_RunTool WHERE userId = ?", userId];
        while ([resultSet next]) {
            model = [[CNRunToolModel alloc] initWithFMResultSet:resultSet];
        }
    }];
    return model;
}

// 删除单条数据
- (void)deleteRunToolModel:(CNRunToolModel *)model{
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.runToolPath];
    [_dbQueue inDatabase:^(FMDatabase *db) { // where 后面跟的是条件
        BOOL result = [db executeUpdate:@"DELETE FROM t_RunTool WHERE userId = ?", model.userId];
        if (result) {
            NSLog(@"删除成功");
        }else {
            NSLog(@"删除失败");
        }
    }];
}


@end

