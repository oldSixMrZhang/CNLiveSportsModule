//
//  CNReUpLoadTableViewCell.m
//  CNLiveNetAdd
//
//  Created by open on 2019/6/27.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import "CNReUpLoadTableViewCell.h"
#import "CNTrackUploadFailModel.h"
#import "UIColor+CNLiveExtension.h"
#import "CNLiveSportsDetailModel.h"
#import "CNHistoryTrackParam.h"
#import "CNHistoryViewModel.h"
#import "CNHistoryTrackPoint.h"
#import "CNTrackLoaclDataManager.h"

@interface CNReUpLoadTableViewCell ()

@property (nonatomic, strong) UIView  *bgView;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *distanceLabel;

@property (nonatomic, strong) QMUIButton *durationBtn;
@property (nonatomic, strong) QMUIButton *speedBtn;
@property (nonatomic, strong) QMUIButton *stepNumberBtn;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) QMUIButton *reUploadBtn;
@property (nonatomic, strong) QMUIButton *deleteBtn;

@property (nonatomic, strong) UILabel *desLabel;

@end

@implementation CNReUpLoadTableViewCell

static const NSInteger margin = 20;

#pragma mark - Init
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
        [self setupUI];
    }
    return self;
}

#pragma mark - UI
- (void)setupUI{
    [self.contentView addSubview:self.bgView];
    [self.contentView addSubview:self.line];
    
    [self.contentView addSubview:self.deleteBtn];
    [self.contentView addSubview:self.reUploadBtn];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.desLabel];

    [self.contentView addSubview:self.addressLabel];
    [self.contentView addSubview:self.distanceLabel];
    
    [self.contentView addSubview:self.durationBtn];
    [self.contentView addSubview:self.speedBtn];
    [self.contentView addSubview:self.stepNumberBtn];
    
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self).offset(10);
        make.right.equalTo(self.mas_right).offset(-10);
        make.bottom.equalTo(self.mas_bottom).offset(-10);
    }];
    _bgView.layer.cornerRadius = 5;
    _bgView.layer.masksToBounds = YES;
    
    
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-margin);
        make.bottom.equalTo(self.mas_bottom).offset(-margin);
        make.size.mas_equalTo(CGSizeMake(65, 26));
    }];
    _deleteBtn.layer.cornerRadius = 26/2;
    _deleteBtn.layer.masksToBounds = YES;
    _deleteBtn.layer.borderWidth = 1;
    _deleteBtn.layer.borderColor = [UIColor colorWithRed:54/255.0 green:194/255.0 blue:141/255.0 alpha:1.0].CGColor;
    
    [_reUploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.deleteBtn.mas_left).offset(-margin);
        make.bottom.equalTo(self.mas_bottom).offset(-margin);
        make.size.mas_equalTo(CGSizeMake(75, 26));
    }];
    _reUploadBtn.layer.cornerRadius = 26/2;
    _reUploadBtn.layer.masksToBounds = YES;
    _reUploadBtn.layer.borderWidth = 1;
    _reUploadBtn.layer.borderColor = [UIColor colorWithRed:54/255.0 green:194/255.0 blue:141/255.0 alpha:1.0].CGColor;
    
    
    
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.reUploadBtn.mas_top).with.offset(-margin/2);
        make.left.equalTo(self.contentView.mas_left).with.offset(margin);
        make.right.equalTo(self.contentView.mas_right).with.offset(-margin);
        make.height.offset(0.5);
    }];
    
    //日期
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(margin);
        make.top.left.equalTo(self).offset(25);
//        make.height.offset(20);
    }];
    
    //时间
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dateLabel);
        make.left.equalTo(self.dateLabel.mas_right).with.offset(margin);
//        make.height.offset(20);
    }];
    
    //描述
    [_desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-margin);
        make.centerY.equalTo(self.dateLabel);
    }];
    
    //地址
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dateLabel.mas_bottom).with.offset(10);
        make.left.equalTo(self.dateLabel.mas_left);
        make.right.equalTo(self.mas_right).with.offset(-margin);
//        make.height.offset(25);
    }];
    
    //距离
    [_distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addressLabel.mas_bottom).with.offset(10);
        make.left.equalTo(self.addressLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right).with.offset(-margin);
//        make.height.offset(40);
    }];
    
    [_durationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.line.mas_top).with.offset(-10);
        make.left.equalTo(self.addressLabel.mas_left);
        make.height.offset(25);
        
    }];
    
    [_speedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.line.mas_top).with.offset(-10);
        make.left.equalTo(self.durationBtn.mas_right).with.offset(30);
        make.height.offset(25);
    }];
    
    //步数
    [_stepNumberBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.line.mas_top).with.offset(-10);
        make.left.equalTo(self.speedBtn.mas_right).with.offset(30);
        make.height.offset(25);
        
    }];
}
- (void)dealloc{
    
}
#pragma mark - Data
- (void)setModel:(CNTrackUploadFailModel *)model{
    _model = model;
    _dateLabel.text = [CNLiveTimeTools getDateByTimeStamp:model.startTime formatter:@"MM月dd日"];
    _timeLabel.text = [CNLiveTimeTools getDateByTimeStamp:model.startTime formatter:@"HH:mm"];
    _addressLabel.text = model.eventName;
    _distanceLabel.attributedText = [self setupDistanceString:model.totalKM];
    [_durationBtn setTitle:[CNLiveTimeTools getMMSSFromSS:model.totalTime] forState:UIControlStateNormal];
    [_speedBtn setTitle:model.speed forState:UIControlStateNormal];
    [_stepNumberBtn setTitle:model.totalStep forState:UIControlStateNormal];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - Private Methods
//时间 地点
- (NSMutableAttributedString *)setupDistanceString:(NSString *)str{
    NSString *strs = [NSString stringWithFormat:@"%@ 公里",str];
    NSMutableAttributedString *attri =  [[NSMutableAttributedString alloc] initWithString:strs];
    
    [attri addAttribute:NSForegroundColorAttributeName value:CNLiveColorWithHexString(@"#333333") range:NSMakeRange(0, strs.length)];
    [attri addAttribute:NSFontAttributeName value:UIFontCNMake(26) range:NSMakeRange(0, str.length)];
    [attri addAttribute:NSFontAttributeName value:UIFontCNMake(14) range:NSMakeRange(str.length, strs.length-str.length)];
    
    return attri;
}

- (void)deleteBtnAction{
    if (self.deleteClickBlock) {
        self.deleteClickBlock(self.index);
    }
}

- (void)reUploadAction{
    if (![CNLiveNetworking isNetworking]) {
        [QMUITips showInfo:@"暂无网络" inView:AppKeyWindow hideAfterDelay:1.5];
        return;
    }
    NSDictionary *dict = [self.model.endCoordsDictStr mj_JSONObject];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [dict[@"lat"] doubleValue];
    coordinate.longitude = [dict[@"long"] doubleValue];
    //请求自己的历史轨迹
    [self queryCurrentRunningEndPoint:^(NSArray *points) {
        __block BOOL isSuccess = NO;//是否到达了终点
        [points enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CNHistoryTrackPoint *minePoint = obj;
            CLLocation *originLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:minePoint.coordinate.latitude longitude:minePoint.coordinate.longitude];
            CLLocationDistance distance = [originLocation distanceFromLocation:currentLocation];
            if (distance < 50) {//表示到达终点了
                isSuccess = YES;
                *stop = YES;
            }
        }];
        if (isSuccess) {//到达了终点
            __block NSMutableArray *mutArr = [NSMutableArray arrayWithArray:points];
            __block int successCount = 0;
            NSArray *arr = [self.model.pointsArrStr mj_JSONObject];
            NSMutableArray<CNLiveSportsCoordinatesModel *> *models = [CNLiveSportsCoordinatesModel mj_objectArrayWithKeyValuesArray:arr];
            for (CNLiveSportsCoordinatesModel *pointNode in models) {
                CLLocation *originLocation = [[CLLocation alloc] initWithLatitude:[pointNode.latitude doubleValue] longitude:[pointNode.longitude doubleValue]];
                [mutArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CNHistoryTrackPoint *minePoint = obj;
                    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:minePoint.coordinate.latitude longitude:minePoint.coordinate.longitude];
                    CLLocationDistance distance = [originLocation distanceFromLocation:currentLocation];
                    if (distance < 50) {//表示这个点已经完成
                        [mutArr removeObjectsInRange:NSMakeRange(0, idx+1)];
                        successCount ++;
                        *stop = YES;
                    }
                }];
            }
            if (successCount*1.000/models.count*1.000 > 0.70) {//大于70%则认为任务完成
                [self uploadService:YES];
            }else{
                [self uploadService:NO];
            }
        }else{//没有到达终点，直接算未完成
            [self uploadService:NO];
        }
    }];
}

//请求
- (void)uploadService:(BOOL)isSuccessTrack{
    NSString *strUrl = CNSportsChinaSaveRecordUrl;
    NSDictionary *dict = @{
                           @"eventId":self.model.eventId,
                           @"sid":CNUserShareModelUid,
                           @"employTime":self.model.totalTime,
                           @"mileage":self.model.totalKM,
                           @"pace":self.model.speed,
                           @"step":self.model.totalStep,
                           //@"roadmap":imgUrlStr,
                           @"startTime":self.model.startTime,
                           @"endTime":self.model.endTime,
                           @"isPause":self.model.isStop.length>0?@"1":@"0",
                           @"pauseTime":self.model.isStop.length>0?self.model.stopTime:@"",
                           @"continueTime":self.model.isStop.length>0?self.model.reStartTime:@"",
                           @"completeStatus":isSuccessTrack?@"1":@"0"
                           };
    [CNLiveNetworking requestNetworkWithMethod:CNLiveRequestMethodPOST URLString:strUrl Param:dict CacheType:CNLiveNetworkCacheTypeNetworkOnly CompletionBlock:^(NSURLSessionTask *requestTask, id responseObject, NSError *error) {
        if (error) {
            [QMUITips showInfo:@"服务异常，请重试" inView:AppKeyWindow hideAfterDelay:1.5];
            //弹窗，是否暂存，是否重试
//            [self alertEndSelect:isSuccessTrack img:imgUrlStr];
        }else{
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSString *resultCode = [NSString stringWithFormat:@"%@", responseObject[@"errorCode"]];
                if ([resultCode isEqualToString:@"0"]) {
                    //删除数据库中的逻辑辅助数据
                    [[CNTrackLoaclDataManager shareManager] deleteFUploadModel:self.model];
                    [QMUITips showInfo:@"重新上传成功" inView:AppKeyWindow hideAfterDelay:1.5];
                    if ([self.delegate respondsToSelector:@selector(needToReloadTable:index:)]) {
                        [self.delegate needToReloadTable:self index:self.index];
                    }
                }else{
                    [QMUITips showInfo:@"服务异常，请重试" inView:AppKeyWindow hideAfterDelay:1.5];
                }
            }else{
                [QMUITips showInfo:@"服务异常，请重试" inView:AppKeyWindow hideAfterDelay:1.5];
            }
        }
    }];
}

#pragma mark -- 自己的历史轨迹
- (void)queryCurrentRunningEndPoint:(void(^)(NSArray *))handle{
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
    if ([self.model.isStop isEqualToString:@"yes"]) {
        CNHistoryTrackParam * paramInfo =[[CNHistoryTrackParam alloc]init];
        [paramInfo setStartTime:[self.model.startTime integerValue]];
        [paramInfo setEndTime:[self.model.stopTime integerValue]];
        [paramInfo setEntityName:CNUserShareModelUid];
        [paramInfo setIsProcessed:true];
        BTKQueryTrackProcessOption *processOption = [[BTKQueryTrackProcessOption alloc] init];
        processOption.radiusThreshold = 100;
        processOption.denoise = true;
        processOption.vacuate = true;
        processOption.mapMatch = false;
        processOption.transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING;
        paramInfo.processOption = processOption;
        paramInfo.supplementMode = BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_WALKING;
        CNHistoryViewModel *vm = [[CNHistoryViewModel alloc] init];
        vm.completionHandler = ^(NSArray *points) {
            [tempArray addObjectsFromArray:points];
            if (self.model.reStartTime.length > 0) {
                CNHistoryTrackParam * paramInfo2 =[[CNHistoryTrackParam alloc]init];
                [paramInfo2 setStartTime:[self.model.reStartTime integerValue]];
                [paramInfo2 setEndTime:[self.model.endTime integerValue]];
                [paramInfo2 setEntityName:CNUserShareModelUid];
                [paramInfo2 setIsProcessed:true];
                BTKQueryTrackProcessOption *processOption2 = [[BTKQueryTrackProcessOption alloc] init];
                processOption2.radiusThreshold = 100;
                processOption2.denoise = true;
                processOption2.vacuate = true;
                processOption2.mapMatch = false;
                processOption2.transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING;
                paramInfo2.processOption = processOption;
                paramInfo2.supplementMode = BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_WALKING;
                CNHistoryViewModel *vm2 = [[CNHistoryViewModel alloc] init];
                vm2.completionHandler = ^(NSArray *points) {
                    [tempArray addObjectsFromArray:points];
                    handle(tempArray);
                };
                [vm2 queryHistoryWithParam:paramInfo2];
            }else{
                handle(tempArray);
            }
        };
        [vm queryHistoryWithParam:paramInfo];
    }else{
        CNHistoryTrackParam * paramInfo =[[CNHistoryTrackParam alloc]init];
        [paramInfo setStartTime:[self.model.startTime integerValue]];
        [paramInfo setEndTime:[self.model.endTime integerValue]];
        [paramInfo setEntityName:CNUserShareModelUid];
        [paramInfo setIsProcessed:true];
        BTKQueryTrackProcessOption *processOption = [[BTKQueryTrackProcessOption alloc] init];
        processOption.radiusThreshold = 100;
        processOption.denoise = true;
        processOption.vacuate = true;
        processOption.mapMatch = false;
        processOption.transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING;
        paramInfo.processOption = processOption;
        paramInfo.supplementMode = BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_WALKING;
        CNHistoryViewModel *vm = [[CNHistoryViewModel alloc] init];
        vm.completionHandler = ^(NSArray *points) {
            [tempArray addObjectsFromArray:points];
            handle(tempArray);
        };
        [vm queryHistoryWithParam:paramInfo];
    }
    
}
#pragma mark - Lazy loading
-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = kWhiteColor;
    }
    return _bgView;
}

- (UILabel *)dateLabel{
    if(_dateLabel == nil){
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = CNLiveColorWithHexString(@"666666");
        _dateLabel.font = UIFontCNMake(14);
        
    }
    return _dateLabel;
    
}

- (UILabel *)timeLabel{
    if(_timeLabel == nil){
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = CNLiveColorWithHexString(@"888888");
        _timeLabel.font = UIFontCNMake(14);
        _timeLabel.userInteractionEnabled = YES;
        
    }
    return _timeLabel;
    
}

- (UILabel *)addressLabel{
    if(_addressLabel == nil){
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.textColor = CNLiveColorWithHexString(@"333333");
        _addressLabel.font = UIFontCNMake(12);
        _addressLabel.userInteractionEnabled = YES;
        
    }
    return _addressLabel;
    
}

- (UILabel *)distanceLabel{
    if(_distanceLabel == nil){
        _distanceLabel = [[UILabel alloc] init];
        _distanceLabel.textColor = CNLiveColorWithHexString(@"333333");
        _distanceLabel.font = UIFontCNMake(30);
        _distanceLabel.userInteractionEnabled = YES;
        
    }
    return _distanceLabel;
    
}

- (QMUIButton *)durationBtn{
    if(_durationBtn == nil){
        _durationBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        _durationBtn.titleLabel.font = UIFontCNMake(13);
        [_durationBtn setTitleColor:CNLiveColorWithHexString(@"666666") forState:UIControlStateNormal];
        [_durationBtn setTitle:@"00:00:00" forState:UIControlStateNormal];
        [_durationBtn setImage:[UIImage imageNamed:@"sports_china_wdjl_time"] forState:UIControlStateNormal];
        _durationBtn.adjustsImageWhenHighlighted = NO;
        _durationBtn.imagePosition = QMUIButtonImagePositionRight;
        _durationBtn.spacingBetweenImageAndTitle = 5;
        _durationBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
    }
    return _durationBtn;
    
}

- (QMUIButton *)speedBtn{
    if(_speedBtn == nil){
        _speedBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        _speedBtn.titleLabel.font = UIFontCNMake(13);
        [_speedBtn setTitleColor:CNLiveColorWithHexString(@"666666") forState:UIControlStateNormal];
        [_speedBtn setTitle:@"0" forState:UIControlStateNormal];
        [_speedBtn setImage:[UIImage imageNamed:@"sports_china_wdjl_speed"] forState:UIControlStateNormal];
        _speedBtn.adjustsImageWhenHighlighted = NO;
        _speedBtn.imagePosition = QMUIButtonImagePositionRight;
        _speedBtn.spacingBetweenImageAndTitle = 5;
        _speedBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
    }
    return _speedBtn;
    
}

- (QMUIButton *)stepNumberBtn{
    if(_stepNumberBtn == nil){
        _stepNumberBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        _stepNumberBtn.titleLabel.font = UIFontCNMake(13);
        [_stepNumberBtn setTitleColor:CNLiveColorWithHexString(@"666666") forState:UIControlStateNormal];
        [_stepNumberBtn setTitle:@"0" forState:UIControlStateNormal];
        [_stepNumberBtn setImage:[UIImage imageNamed:@"sports_china_wdjl_step"] forState:UIControlStateNormal];
        _stepNumberBtn.adjustsImageWhenHighlighted = NO;
        _stepNumberBtn.imagePosition = QMUIButtonImagePositionRight;
        _stepNumberBtn.spacingBetweenImageAndTitle = 5;
        _stepNumberBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
    }
    return _stepNumberBtn;
    
}

- (UIView *)line{
    if(_line == nil){
        _line = [[UIView alloc] init];
        _line.backgroundColor = CNLiveColorWithHexString(@"ebebeb");
        
    }
    return _line;
    
}

- (QMUIButton *)deleteBtn{
    if(_deleteBtn == nil){
        _deleteBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setTitle:@"删 除" forState:UIControlStateNormal];
        _deleteBtn.titleLabel.font = UIFontCNMake(12);
        [_deleteBtn setTitleColor:[UIColor colorWithRed:54/255.0 green:194/255.0 blue:141/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

-(QMUIButton *)reUploadBtn{
    if(_reUploadBtn == nil){
        _reUploadBtn = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_reUploadBtn setTitle:@"重新上传" forState:UIControlStateNormal];
        _reUploadBtn.titleLabel.font = UIFontCNMake(12);
        [_reUploadBtn setTitleColor:[UIColor colorWithRed:54/255.0 green:194/255.0 blue:141/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_reUploadBtn addTarget:self action:@selector(reUploadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reUploadBtn;
}

-(UILabel *)desLabel{
    if(_desLabel == nil){
        _desLabel = [[UILabel alloc] init];
        _desLabel.textColor = [UIColor colorWithRed:254/255.0 green:78/255.0 blue:78/255.0 alpha:1.0];
        _desLabel.font = UIFontCNMake(12);
        _desLabel.userInteractionEnabled = YES;
        _desLabel.text = @"上传失败";
    }
    return _desLabel;
}
@end
