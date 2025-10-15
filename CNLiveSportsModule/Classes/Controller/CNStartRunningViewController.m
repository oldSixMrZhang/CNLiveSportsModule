//
//  CNStartRunningViewController.m
//  CNLiveNetAdd
//
//  Created by open on 2019/6/13.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import "CNStartRunningViewController.h"
#import "CNRunEndCircleProgress.h"
#import <CoreMotion/CoreMotion.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BMKLocationkit/BMKLocationComponent.h>//定位功能
#import "CNLinePointNode.h"
#import "CNHistoryTrackParam.h"
#import "CNHistoryViewModel.h"
#import "CNHistoryTrackPoint.h"
#import <BaiduTraceSDK/BaiduTraceSDK.h>//鹰眼服务
#import "CNTrackTableView.h"
#import "CNTrackServiceManager.h"
#import "CNTrackLoaclDataManager.h"
#import "CNRunExitModel.h"
#import "CNLiveUploadManager.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "CNTrackUploadFailModel.h"
#import "CNReUploadViewController.h"



@interface CNStartRunningViewController ()
<
BMKMapViewDelegate,
BMKLocationManagerDelegate,
BTKFenceDelegate,
UITableViewDelegate,
UITableViewDataSource,
CNTrackServiceManagerDelegate
>
//倒计时
@property (nonatomic, strong) UIView            *startCountdownView;//倒计时321
@property (nonatomic, strong) UILabel           *startCountdownLab;//倒计时321
//倒计时结束后

@property (nonatomic, strong) UIView            *fristBgView;//倒计时321
@property (nonatomic, strong) QMUIButton        *backFirstBtn;//backFirstBtn
@property (nonatomic, strong) UILabel           *currentKMLab;//0.00公里

@property (nonatomic, strong) UILabel           *gpsLab;//"GPS"
@property (nonatomic, strong) UIImageView       *currentGPSImgView;//"GPS"img
@property (nonatomic, strong) UILabel           *currentGPSLab;//GPS

@property (nonatomic, strong) UIButton          *detailMapBtn;//mapBtn
@property (nonatomic, strong) UILabel           *mapDesLab;//GPS


@property (nonatomic, strong) UIImageView       *speedImgView;//speed
@property (nonatomic, strong) UILabel           *currentSpeedLab;
@property (nonatomic, strong) UILabel           *speedDesLab;

@property (nonatomic, strong) UIImageView       *timeImgView;//time
@property (nonatomic, strong) UILabel           *currentTimeLab;
@property (nonatomic, strong) UILabel           *timeDesLab;

@property (nonatomic, strong) UIImageView       *stepImgView;//step
@property (nonatomic, strong) UILabel           *currentStepLab;
@property (nonatomic, strong) UILabel           *stepDesLab;

@property (nonatomic, strong) QMUIButton        *stopRunningBtn;//mapBtn
@property (nonatomic, strong) QMUIButton        *goonRunningBtn;//mapBtn
@property (nonatomic, strong) UIView            *endRunningBgView;//mapBtn
@property (nonatomic, strong) QMUIButton        *endRunningBtn;//mapBtn
@property (nonatomic, strong) UIImageView       *endTipView;//mapBtn
@property (nonatomic, strong) UILabel           *endTipLab;//mapBtn
@property (strong, nonatomic) CNRunEndCircleProgress            *progressView;
@property (nonatomic, strong) UILongPressGestureRecognizer      *longPress;//tap
@property (nonatomic, strong) NSTimer           *endTimer;//点击了结束按钮事件响应timer
@property (nonatomic, strong) NSTimer           *startRunningTimer;//跑步的累计时间

#pragma mark -- 地图.h
@property (nonatomic, strong) BMKMapView            *mapView;//地图
@property (nonatomic, strong) BMKPolyline           *originalPolyLine; //当前界面的多边形（运动轨迹）
@property (nonatomic, strong) BMKPointAnnotation    *startAnnotation; //当前界面的标注
@property (nonatomic, strong) BMKPointAnnotation    *endAnnotation; //当前界面的标注
@property (nonatomic, strong) QMUIButton            *backBtn;//backBtn
@property (nonatomic, strong) QMUIButton            *GPSBtn;//backBtn
@property (nonatomic, strong) QMUIButton            *tipGPSBtn;//resetBtn
@property (nonatomic, strong) QMUIButton            *resetBtn;//resetBtn
@property (nonatomic, strong) UIImageView           *mapBottomView;//mapBottom
@property (nonatomic, strong) UILabel               *mapCurrentSpeedLab;//mapBottom
@property (nonatomic, strong) UILabel               *mapSpeedLab;//mapBottom
@property (nonatomic, strong) UILabel               *mapCurrentTimeLab;//mapBottom
@property (nonatomic, strong) UILabel               *mapTimeLab;//mapBottom
@property (nonatomic, strong) UILabel               *mapCurrentKMLab;//mapBottom
@property (nonatomic, strong) UILabel               *mapKMLab;//mapBottom


#pragma mark -- 定位.h
@property (nonatomic, strong) BMKLocationManager    *locationManager;//定位管理
@property (nonatomic, strong) BMKUserLocation       *userLocation; //当前位置对象

@property (nonatomic, assign) CNLocationGPSState    gpsState; //gps信号状态
#pragma mark -- 定位画线.h
@property (nonatomic, strong) BMKPolyline           *stopBeforePolyLine; //停止前的路线
@property (nonatomic, assign) NSInteger             recordReInTime; //停止前的路线

@property (nonatomic, strong) CLLocation            *firstStopAfterLinePoint;//停止后的路线的第一个点
@property (nonatomic, strong) BMKPolyline           *stopAfterPolyLine; //停止后的路线
@property (nonatomic, strong) BMKPolyline           *frontStopAfterPolyLine; //停止后的前一半路线
//不退出控制器，暂停之前的线
@property (nonatomic, strong) BMKPolyline           *noExitStopFrontPolyLine; //停止后的路线


@property (nonatomic, strong) NSMutableArray        *locationPoints;//用于画线的集合
@property (nonatomic, strong) CLLocation            *currentLocation;// 中间变量->location类型(地理位置)

#pragma mark -- 本地地理围栏.h

#pragma mark -- 结束view.h
@property (nonatomic, strong) CNTrackTableView     *tableView;
@property (nonatomic, strong) UIButton             *saveBtn;
@property (nonatomic, strong) UIView               *preSaveView;
@property (nonatomic, strong) UIImageView          *loadingSaveView;

@property (nonatomic, strong) UILabel              *successStateLab;//tableviewcell中的一个变量

#pragma mark -- 判断进入页面的方式.h
@property (nonatomic, strong) CNRunExitModel        *exitModel;
@end

@implementation CNStartRunningViewController{
    BOOL        _isStopEnd;//是否停止了长按结束按钮
    double      _pressEndBtnCurrentTime;//计时器走了多长时间（最长2，到2 isStopEnd置为yes）
    NSInteger   _totalTime;//跑步累计时间，单位秒
    NSInteger   _startRunningDate;
    BOOL        _isEndRunning;
    CGFloat     angle;
    NSInteger   _endRunningDate;
    UIImageView *_headImg;//用于长按了结束按钮后拖动的问题
    
    NSInteger   _stopDate;//暂停的时间
    NSInteger   _reStartDate;//重新开始的时间
    NSInteger   _lastStepCount;//最新的步数或起止步数
    NSNumber    *localFenceId;
    
    CNTrackUploadFailModel *failModel;//上传失败的model，存数据库
    NSString    *_endStatus;
    BOOL        _isStopRun;//用于判断是否在此控制器中是否点击了暂停，通过此控制器返回或其他操作都不做处理
    BOOL        _isStopAnimation;

}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_endTimer) {
        [_endTimer invalidate];
        _endTimer = nil;
    }
    if (_startRunningTimer) {
        [_startRunningTimer invalidate];
        _startRunningTimer = nil;
    }
    NSLog(@"CNStartRunningViewController 释放了");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.mapView viewWillAppear];
    self.mapView.delegate = self;
    _locationManager.delegate = self;
    self.recordReInTime = [CNLiveTimeTools getNowTimestamp];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil;
    if (_isEndRunning) {
        _locationManager.delegate = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *str = [self.sportsDetailModel mj_JSONString];
    [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"CN_OLD_TRACK"];
    
    [CNTrackServiceManager defaultManager].delegate = self;
    self.view.backgroundColor = [UIColor blackColor];
    _isStopRun = NO;
    [self.view addSubview:self.mapView];
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    self.mapView.hidden = YES;
    self.exitModel = [[CNTrackLoaclDataManager shareManager]getExitModel:CNUserShareModelUid];
    //查询一次服务器围栏：实时状态查询，是为了使服务器围栏监控生效
    [self queryRealtimeStatus];
    
    if (self.exitModel && self.exitModel.eventId.length > 0) {
        [self initData];
        [self addFirstView];
        [self startRunningTime];
    }else{
        [self startCountdown:^{
            [self initData];
            self.view.backgroundColor = [UIColor blackColor];
            [self addFirstView];
            [self startRunningTime];
        }];
    }
}
#pragma mark -- CNTrackServiceManagerDelegate
-(void)currentPedometer:(CNRunExitModel *)model{
    if (!model) {
        return;
    }
    double km = ([model.step integerValue])*60.0/100/1000;
    //不四舍五入
    NSInteger tempStep = [model.step integerValue];
    if (tempStep > 0) {
        self.currentStepLab.text = [NSString stringWithFormat:@"%ld",[model.step integerValue]];//步数
    }else{
        self.currentStepLab.text = @"0";
    }
    self.exitModel.step = self.currentStepLab.text;
    NSDictionary *attributesNum = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:70]};
    NSDictionary *attributesKM = @{NSFontAttributeName:[UIFont systemFontOfSize:15]};
    NSAttributedString *attributedString = [self attributedText:@[[NSString stringWithFormat:@"%.2f",floor((km)*100)/100],@" 公里"] attributeAttay:@[attributesNum,attributesKM]];
    self.currentKMLab.attributedText = attributedString;
    self.currentSpeedLab.text = [self getPaceSpeed:_totalTime distance:km];
    self.mapCurrentKMLab.text = [NSString stringWithFormat:@"%.2f",floor((km)*100)/100];
    self.mapCurrentSpeedLab.text = [self getPaceSpeed:_totalTime distance:km];
}
#pragma mark -- mapDelegate
-(void)mapViewDidFinishLoading:(BMKMapView *)mapView{
    //地图加载完成后，添加运营的线，添加终点的本地围栏
    [self addMapOriginalLine];
    //请求自己的历史轨迹
    CNRunExitModel *tempM = [[CNTrackLoaclDataManager shareManager] getExitModel:CNUserShareModelUid];
    if (tempM && [tempM.isStop isEqualToString:@"yes"]) {
        [self.locationPoints removeAllObjects];
        [self queryTwoMineHistoryLine];
    }else if (tempM){
        [self queryOneMineHistoryLine];
    }
    
    [self.mapView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mapView).offset(10);
        make.top.equalTo(self.mapView).offset(kVerticalStatusHeight + 10);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    [self.mapView addSubview:self.GPSBtn];
    [self.GPSBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backBtn);
        make.right.equalTo(self.mapView.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(78, 29));
    }];
    [self.mapView addSubview:self.tipGPSBtn];
    [self.tipGPSBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.GPSBtn.mas_right);
        make.top.equalTo(self.GPSBtn.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(140, 36));
    }];
    [self addMapBottomView];
}

//line delegate
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    //    if ([overlay isKindOfClass:[BMKCircle class]]) {
    //        BMKCircleView *circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
    //        circleView.fillColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.3];
    //        circleView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0];
    //        return circleView;
    //    }else{
    if ([overlay isKindOfClass:[BMKPolyline class]] && [overlay isEqual:self.originalPolyLine]) {
        BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithPolyline:(BMKPolyline *)overlay];
        polylineView.lineWidth = 2;
        polylineView.strokeColor = [RGBOF(0x5BC4A4) colorWithAlphaComponent:1];
        return polylineView;
    } else {
        BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithPolyline:(BMKPolyline *)overlay];
        polylineView.lineWidth = 2;
        polylineView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:1];
        return polylineView;
    }
    
    return nil;
}
//annotation delegate
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        NSString *AnnotationViewID = @"startStopAnnotation";
        BMKAnnotationView *annotationView = nil;
        if (annotationView == nil) {
            annotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        }
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -38/2+5, 68, 68)];
        bgView.image = [UIImage imageNamed:@"map-fw"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -38/2+5, 30, 38)];
        if (annotation == _startAnnotation) {
            imageView.image = [UIImage imageNamed:@"map_location-start"];
        } else if (annotation == _endAnnotation){
            imageView.image = [UIImage imageNamed:@"map_location-finish"];
        }
        //        else{
        //            annotationView.image = [UIImage imageNamed:@"icon_fence_center"];
        //            return annotationView;
        //        }
        //        if (annotation == _startAnnotation || annotation == _endAnnotation) {
        UIView *underView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 7)];
        underView.backgroundColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:0.5];
        underView.centerX = imageView.centerX+2;
        underView.centerY = imageView.centerY+38/2-3;
        underView.layer.cornerRadius = 6;
        underView.layer.masksToBounds = YES;
        bgView.centerX = underView.centerX;
        bgView.centerY = underView.centerY - 8;
        [annotationView addSubview:bgView];
        [annotationView addSubview:underView];
        [annotationView addSubview:imageView];
        annotationView.frame = CGRectMake(0, -38/2+5, 30, 38);
        annotationView.enabled3D = YES;
        annotationView.hidePaopaoWhenSingleTapOnMap = YES;
        annotationView.hidePaopaoWhenDoubleTapOnMap = YES;
        annotationView.hidePaopaoWhenTwoFingersTapOnMap = YES;
        annotationView.hidePaopaoWhenSelectOthers = YES;
        return annotationView;
        //        }
    }
    return nil;
}

#pragma mark -- 定位delegate
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    NSLog(@"定位失败");
}

// 定位SDK中，方向变更的回调
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateHeading:(CLHeading * _Nullable)heading{
    if (!heading) {
        return;
    }
    self.userLocation.heading = heading;
    [self.mapView updateLocationData:self.userLocation];
}

// 定位SDK中，位置变更的回调
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
    if (error) {
    //不处理
    }
    if (!location) {
        return;
    }
    CLLocationAccuracy gpsValue = location.location.horizontalAccuracy;
    if (gpsValue > 0 && gpsValue <= 20) {//gps信号好
        self.gpsState = CNLocationGPSStateGood;
    }else if (gpsValue > 20 && gpsValue <= 60){//gps信号中
        self.gpsState = CNLocationGPSStateMedium;
    }else if (gpsValue > 60 && gpsValue < 200){//gps信号差
        self.gpsState = CNLocationGPSStatePoor;
    }else{//gps信号无
        self.gpsState = CNLocationGPSStateNull;
    }
    self.userLocation.location = location.location;
    [self.mapView updateLocationData:self.userLocation];//动态更新我的位置数据
    if (gpsValue < 100 && !_isStopRun) {
        if (!self.currentLocation) {
            self.currentLocation = location.location;
        }
        if (self.locationPoints.count == 0) {
            [self.locationPoints addObject:location.location];
        }
        CLLocationDistance distance = [location.location distanceFromLocation:self.currentLocation];
        if (distance < 3){
            return;
        }
        [self.locationPoints addObject:location.location];
        //画线
        // 直接画stopAfter后的线，如果有暂停，就查出来后画before线，如果没有暂停，就查出来后直接附加到stopAfter线上
        if (self.locationPoints.count > 1) {
            [self addStopAfterPolyLine];
            self.currentLocation = location.location;
        }
    }
}

//权限改变
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusDenied) {
        dispatch_async(dispatch_get_main_queue(), ^{
            QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            }];
            QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"" message:@"无法获取你的位置信息。\n 请到手机系统的[隐私]->[定位服务]中打开定位服务，并允许网家家使用定位服务" preferredStyle:QMUIAlertControllerStyleAlert];
            [alertController addAction:action1];
            [alertController showWithAnimated:YES];
        });
    }
}

- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager doRequestAlwaysAuthorization:(CLLocationManager * _Nonnull)locationManager{
    [locationManager requestAlwaysAuthorization];
}
#pragma mark -- private 历史轨迹
- (void)getHistoryPoints{
    //请求自己的历史轨迹
    if ([self.exitModel.isStop isEqualToString:@"yes"]) {
        [self queryTwoMineHistoryLine];
    }else{
        [self queryOneMineHistoryLine];
    }
}

#pragma mark -- private 实时画轨迹
- (void)addStopAfterPolyLine{
    if (self.firstStopAfterLinePoint) {
        [self.locationPoints insertObject:self.firstStopAfterLinePoint atIndex:0];
    }
    CLLocationCoordinate2D coors[self.locationPoints.count];
    NSInteger count = 0;
    for (size_t i = 0; i < self.locationPoints.count; i++) {
        CLLocation *location = [self.locationPoints objectAtIndex:i];
        coors[i] = location.coordinate;
        count++;
    }
    self.stopAfterPolyLine = [BMKPolyline polylineWithCoordinates:coors count:count];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.stopAfterPolyLine) {// 防止重复绘制
            [self.mapView removeOverlay:self.stopAfterPolyLine];
        }
        [self.mapView addOverlay:self.stopAfterPolyLine];
    });
}

#pragma mark -- private map
- (void)queryTwoMineHistoryLine{
    CNRunExitModel *tempM = self.exitModel;
    CNHistoryTrackParam * paramInfo =[[CNHistoryTrackParam alloc]init];
    [paramInfo setStartTime:[tempM.startTime integerValue]];
    [paramInfo setEndTime:[tempM.stopTime integerValue]];
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
        if (points.count > 0) {
            NSMutableArray *mu = [NSMutableArray arrayWithCapacity:0];
            for (CNHistoryTrackPoint *point in points) {
                CLLocation *location = [[CLLocation alloc] initWithLatitude:point.coordinate.latitude longitude:point.coordinate.longitude];
                [mu addObject:location];
            }
            //画线
            CLLocationCoordinate2D coors[mu.count];
            NSInteger count = 0;
            for (size_t i = 0; i < mu.count; i++) {
                CLLocation *location = [mu objectAtIndex:i];
                coors[i] = location.coordinate;
                count++;
            }
            self.stopBeforePolyLine = [BMKPolyline polylineWithCoordinates:coors count:count];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.stopBeforePolyLine) {// 防止重复绘制
                    [self.mapView removeOverlay:self.stopBeforePolyLine];
                }
                [self.mapView addOverlay:self.stopBeforePolyLine];
            });
        }
    };
    [vm queryHistoryWithParam:paramInfo];
    
    if (tempM.reStartTime.length == 0 || [tempM.reStartTime isEqualToString:@"<null>"]) {
        tempM.reStartTime = [NSString stringWithFormat:@"%ld",[CNLiveTimeTools getNowTimestamp]];
        [[CNTrackLoaclDataManager shareManager] updateExitModel:tempM];
        return;
    }
    CNHistoryTrackParam * paramInfo2 =[[CNHistoryTrackParam alloc]init];
    [paramInfo2 setStartTime:[tempM.reStartTime integerValue]];
    if (_isEndRunning) {
        [paramInfo2 setEndTime:_endRunningDate];
    }else{
        [paramInfo2 setEndTime:self.recordReInTime];
    }
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
        if (points.count > 0) {
            NSMutableArray *mu = [NSMutableArray arrayWithCapacity:0];
            for (CNHistoryTrackPoint *point in points) {
                CLLocation *location = [[CLLocation alloc] initWithLatitude:point.coordinate.latitude longitude:point.coordinate.longitude];
                [mu addObject:location];
            }
            self.firstStopAfterLinePoint = [mu lastObject];
            //画线
            CLLocationCoordinate2D coors[mu.count];
            NSInteger count = 0;
            for (size_t i = 0; i < mu.count; i++) {
                CLLocation *location = [mu objectAtIndex:i];
                coors[i] = location.coordinate;
                count++;
            }
            self.frontStopAfterPolyLine = [BMKPolyline polylineWithCoordinates:coors count:count];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.frontStopAfterPolyLine) {// 防止重复绘制
                    [self.mapView removeOverlay:self.frontStopAfterPolyLine];
                }
                [self.mapView addOverlay:self.frontStopAfterPolyLine];
            });
        }
    };
    [vm2 queryHistoryWithParam:paramInfo2];
}
- (void)queryOneMineHistoryLine{
    CNRunExitModel *tempM = self.exitModel;
    CNHistoryTrackParam * paramInfo =[[CNHistoryTrackParam alloc]init];
    [paramInfo setStartTime:[tempM.startTime integerValue]];
    if (_isEndRunning) {
        [paramInfo setEndTime:_endRunningDate];
    }else{
        [paramInfo setEndTime:self.recordReInTime];
    }
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
        if (points.count > 0) {
            NSMutableArray *mu = [NSMutableArray arrayWithCapacity:0];
            for (CNHistoryTrackPoint *point in points) {
                CLLocation *location = [[CLLocation alloc] initWithLatitude:point.coordinate.latitude longitude:point.coordinate.longitude];
                [mu addObject:location];
            }
            self.firstStopAfterLinePoint = [mu lastObject];
            //画线
            CLLocationCoordinate2D coors[mu.count];
            NSInteger count = 0;
            for (size_t i = 0; i < mu.count; i++) {
                CLLocation *location = [mu objectAtIndex:i];
                coors[i] = location.coordinate;
                count++;
            }
            self.frontStopAfterPolyLine = [BMKPolyline polylineWithCoordinates:coors count:count];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.frontStopAfterPolyLine) {// 防止重复绘制
                    [self.mapView removeOverlay:self.frontStopAfterPolyLine];
                }
                [self.mapView addOverlay:self.frontStopAfterPolyLine];
            });
        }
    };
    [vm queryHistoryWithParam:paramInfo];
}

- (void)addMapOriginalLine{
    CNHistoryTrackParam * paramInfo =[[CNHistoryTrackParam alloc]init];
    [paramInfo setStartTime:[self.sportsDetailModel.startTime integerValue]];
    [paramInfo setEndTime:[self.sportsDetailModel.endTime integerValue]];
    [paramInfo setEntityName:self.sportsDetailModel.entityName];
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
        NSMutableArray *pointNodes = [NSMutableArray arrayWithCapacity:0];
        for (CNHistoryTrackPoint *point in points) {
            CNLinePointNode *pointNode = [[CNLinePointNode alloc] init];
            pointNode.coordinate  = point.coordinate;
            [pointNodes addObject:pointNode];
        }
        CLLocationCoordinate2D paths[pointNodes.count];
        for (NSUInteger i = 0; i < pointNodes.count; i ++) {
            CNLinePointNode *node = pointNodes[i];
            paths[i] = node.coordinate;
        }
        self.originalPolyLine = [BMKPolyline polylineWithCoordinates:paths count:pointNodes.count];
        self->_startAnnotation = [[BMKPointAnnotation alloc] init];
        self->_startAnnotation.coordinate = paths[0];
        self->_startAnnotation.title = @"起点";
        self->_endAnnotation = [[BMKPointAnnotation alloc] init];
        self->_endAnnotation.coordinate = paths[pointNodes.count-1];
        self->_endAnnotation.title = @"终点";
        
        //确认终点后，先查询客服端围栏，后面再判断要不要添加客户端围栏
        [self queryLocalFence];
        dispatch_async(dispatch_get_main_queue(), ^{
            /**
             向地图View添加Overlay，需要实现BMKMapViewDelegate的-mapView:viewForOverlay:
             方法来生成标注对应的View
             
             @param overlay 要添加的overlay
             */
            [self.mapView addOverlay:self.originalPolyLine];
            //将标注添加到当前地图View中
            [self->_mapView addAnnotation:self->_startAnnotation];
            //将标注添加到当前地图View中
            [self->_mapView addAnnotation:self->_endAnnotation];
            [self mapViewFitPolyLine:self.originalPolyLine];
            
        });
    };
    [vm queryHistoryWithParam:paramInfo];
}

//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat leftTopX, leftTopY, rightBottomX, rightBottomY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    // 左上角顶点
    leftTopX = pt.x;
    leftTopY = pt.y;
    // 右下角顶点
    rightBottomX = pt.x;
    rightBottomY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        leftTopX = pt.x < leftTopX ? pt.x : leftTopX;
        leftTopY = pt.y < leftTopY ? pt.y : leftTopY;
        rightBottomX = pt.x > rightBottomX ? pt.x : rightBottomX;
        rightBottomY = pt.y > rightBottomY ? pt.y : rightBottomY;
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(leftTopX, leftTopY);
    rect.size = BMKMapSizeMake(rightBottomX - leftTopX, rightBottomY - leftTopY);
    UIEdgeInsets padding = UIEdgeInsetsMake(100, 50, 100, 50);
    [_mapView fitVisibleMapRect:rect edgePadding:padding withAnimated:YES];
}

- (void)addMapBottomView{
    [self.mapView addSubview:self.mapBottomView];
    [self.mapBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.mapView);
        make.bottom.equalTo(self.mapView.mas_bottom).offset(-kVerticalBottomSafeHeight);
        make.height.equalTo(@(130));
    }];
    
    [self.mapView addSubview:self.resetBtn];
    [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mapView).offset(10);
        make.bottom.equalTo(self.mapBottomView.mas_top).offset(-20);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    [self.mapBottomView addSubview:self.mapCurrentTimeLab];
    [self.mapCurrentTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mapBottomView);
        make.top.equalTo(self.mapBottomView).offset(27);
    }];
    [self.mapBottomView addSubview:self.mapTimeLab];
    [self.mapTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mapBottomView);
        make.top.equalTo(self.mapCurrentTimeLab.mas_bottom).offset(21);
    }];
    [self.mapBottomView addSubview:self.mapCurrentSpeedLab];
    [self.mapCurrentSpeedLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mapCurrentTimeLab);
        make.left.equalTo(self.mapBottomView).offset(30);
        make.width.equalTo(@(SCREEN_WIDTH/3-40));
    }];
    [self.mapBottomView addSubview:self.mapSpeedLab];
    [self.mapSpeedLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mapTimeLab);
        make.centerX.equalTo(self.mapCurrentSpeedLab);
    }];
    [self.mapBottomView addSubview:self.mapCurrentKMLab];
    [self.mapCurrentKMLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mapCurrentTimeLab);
        make.right.equalTo(self.mapBottomView.mas_right).offset(-40);
    }];
    [self.mapBottomView addSubview:self.mapKMLab];
    [self.mapKMLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mapTimeLab);
        make.centerX.equalTo(self.mapCurrentKMLab);
    }];
}

-(void)setGpsState:(CNLocationGPSState)gpsState{
    _gpsState = gpsState;
    switch (gpsState) {
        case CNLocationGPSStateGood:{
            self.currentGPSImgView.image = [UIImage imageNamed:@"signal-good"];
            self.currentGPSLab.hidden = YES;
            [self.GPSBtn setImage:[UIImage imageNamed:@"signal-good"] forState:UIControlStateNormal];
            self.tipGPSBtn.hidden = YES;
        }
            break;
        case CNLocationGPSStateMedium:{
            self.currentGPSImgView.image = [UIImage imageNamed:@"signal-mid"];
            self.currentGPSLab.hidden = YES;
            [self.GPSBtn setImage:[UIImage imageNamed:@"signal-mid"] forState:UIControlStateNormal];
            self.tipGPSBtn.hidden = YES;
        }
            break;
        case CNLocationGPSStatePoor:{
            self.currentGPSImgView.image = [UIImage imageNamed:@"signal-low"];
            self.currentGPSLab.hidden = NO;
            self.currentGPSLab.text = @"信号糟糕，数据准确度低";
            [self.GPSBtn setImage:[UIImage imageNamed:@"signal-low"] forState:UIControlStateNormal];
            self.tipGPSBtn.hidden = NO;
            [self.tipGPSBtn setTitle:@"信号糟糕，数据准确度低" forState:UIControlStateNormal];
        }
            break;
        case CNLocationGPSStateNull:{
            self.currentGPSImgView.image = [UIImage imageNamed:@"signal-none"];
            self.currentGPSLab.hidden = NO;
            self.currentGPSLab.text = @"无信号，无法进行数据记录";
            [self.GPSBtn setImage:[UIImage imageNamed:@"signal-none"] forState:UIControlStateNormal];
            self.tipGPSBtn.hidden = NO;
            [self.tipGPSBtn setTitle:@"无信号，无法进行数据记录" forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (void)backBtnAction:(id)sender{
    if (_isEndRunning) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TrackServiceOperationResultNotification object:nil];
        if (_endTimer) {
            [_endTimer invalidate];
            _endTimer = nil;
        }
        if (_startRunningTimer) {
            [_startRunningTimer invalidate];
            _startRunningTimer = nil;
        }
        if ([self.delegate respondsToSelector:@selector(backToFrontVC)]) {
            [self.delegate backToFrontVC];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        self.mapView.hidden = YES;
        self.fristBgView.hidden = NO;
    }
}

- (void)resetBtnAction:(id)sender{
    [self.mapView setCenterCoordinate:self.userLocation.location.coordinate animated:YES];
}
#pragma mark -- private 本地地理围栏
//删除客户端地理围栏
- (void)deleteLocalFence{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 构建请求对象
        BTKDeleteLocalFenceRequest *request = [[BTKDeleteLocalFenceRequest alloc] initWithMonitoredObject:CNUserShareModelUid fenceIDs:nil tag:2];
        // 删除客户端地理围栏
        [[BTKFenceAction sharedInstance] deleteLocalFenceWith:request delegate:self];
    });
}
//删除本地地理围栏的回调
-(void)onDeleteLocalFence:(NSData *)response{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
        NSLog(@"Local Fence Delete格式转换出错");
    }
    if (0 != [dict[@"status"] intValue]) {
        NSLog(@"客户端地理围栏删除返回错误");
    }
    if (_isEndRunning) {
        return;
    }
    // 查询一次
    [self queryLocalFence];
}
- (void)queryLocalFence {
    // 查询所有以当前登录Entity为监控对象的客户端地理围栏
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BTKQueryLocalFenceRequest *request = [[BTKQueryLocalFenceRequest alloc] initWithMonitoredObject:CNUserShareModelUid fenceIDs:nil tag:1];
        [[BTKFenceAction sharedInstance] queryLocalFenceWith:request delegate:self];
    });
}

/**
 查询客户端围栏实体的回调方法
 @param response 符合条件的客户端地理围栏
 */
-(void)onQueryLocalFence:(NSData *)response {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (_isEndRunning) {
        //如果结束跑步，地理围栏相关的都不执行了
        return;
    }
    BOOL isError = false;
    if (nil == dict) {
        NSLog(@"Local Fence List查询格式转换出错");
        
    }
    if (0 != [dict[@"status"] intValue]) {
        NSLog(@"客户端本地地理围栏查询返回错误");
        isError = YES;
    }
    if (isError) {
        //上面出错就直接删除
        [self deleteLocalFence];
        return;
    }
    // 如果之前没有创建过客户端围栏的话，查出来的结果就是0个围栏。这时候弹窗提示用户，去新建一个客户端围栏
    NSInteger size = [dict[@"size"] intValue];
    if (size == 0) {
        NSLog(@"还没有创建过客户端围栏");
        //创建本地围栏
        [self createLocalFence];
        return;
    }
    //全部删除客户端地理围栏
    if ([dict[@"fences"] isKindOfClass:[NSArray class]] && ((NSArray *)dict[@"fences"]).count > 0) {
        //删除所有后再删除的回调里查询
        [self deleteLocalFence];
    }
}

//添加本地地理围栏（圆形）
- (void)createLocalFence{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BTKLocalCircleFence *fence = [[BTKLocalCircleFence alloc] initWithCenter:self.endAnnotation.coordinate radius:20 coordType:BTK_COORDTYPE_GCJ02 denoiseAccuracy:20 fenceName:@"localFence" monitoredObject:CNUserShareModelUid];
        BTKCreateLocalFenceRequest *request = [[BTKCreateLocalFenceRequest alloc] initWithLocalCircleFence:fence tag:1];
        [[BTKFenceAction sharedInstance] createLocalFenceWith:request delegate:self];
    });
}

//创建本地围栏的回调
- (void)onCreateLocalFence:(NSData *)response{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
        NSLog(@"Local Fence Create 格式转换出错");
        return;
    }
    if (0 != [dict[@"status"] intValue]) {
        NSLog(@"Local Fence Create 返回错误");
        //创建失败，重新创建
        return;
    }
    if (!dict[@"fence_id"]) {
        return;
    }
    localFenceId = [NSNumber numberWithFloat:[dict[@"fence_id"] floatValue]];
    //创建成功后查询一次本地围栏的实时状态，目的是使本地地理围栏生效
    if (localFenceId) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BTKQueryLocalFenceStatusRequest *request = [[BTKQueryLocalFenceStatusRequest alloc] initWithMonitoredObject:CNUserShareModelUid fenceIDs:@[self->localFenceId] tag:1];
            [[BTKFenceAction sharedInstance] queryLocalFenceStatusWith:request delegate:self];
            
//            #pragma mark -- TODO 把客户端地理围栏画出来
//            BMKPointAnnotation *centerAnnotation = [[BMKPointAnnotation alloc] init];
//            centerAnnotation.coordinate = self.endAnnotation.coordinate;
//            centerAnnotation.title = @"圆心";
//            BMKCircle *radiusCircle = [[BMKCircle alloc] init];
//            radiusCircle.coordinate = self.endAnnotation.coordinate;
////            double radius = [self.radiusTextField.text doubleValue];
////            if (fabs(radius) > DBL_EPSILON) {
////                radiusCircle.radius = radius;
////            } else {
//            radiusCircle.radius = 10.0;
//            [self.mapView addAnnotation:centerAnnotation];
//            [self.mapView addOverlay:radiusCircle];

//            }
        });
    }
}

/**
 查询监控对象和客户端地理围栏的位置关系的回调方法
 
 @param response 查询结果
 */
-(void)onQueryLocalFenceStatus:(NSData *)response{
    if (_isStopRun) {
        return;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
        NSLog(@"Local Fence Query格式转换出错");
        return;
    }
    if (0 != [dict[@"status"] intValue]) {
        NSLog(@"客户端地理围栏删除返回错误");
    }
    //不做成功和失败的处理，目的是使监控本地地理围栏生效
}

//查询本地围栏的警报历史记录，是否经过过终点
- (void)queryLocalHistoryAlarm{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BTKQueryLocalFenceHistoryAlarmRequest *request = [[BTKQueryLocalFenceHistoryAlarmRequest alloc] initWithMonitoredObject:CNUserShareModelUid fenceIDs:@[self->localFenceId] startTime:self->_startRunningDate endTime:self->_endRunningDate tag:1];
        // 发起查询请求
        [[BTKFenceAction sharedInstance] queryLocalFenceHistoryAlarmWith:request delegate:self];
    });
}

/**
 查询客户端地理围栏历史报警信息的回调方法
 
 @param response 查询结果
 */
-(void)onQueryLocalFenceHistoryAlarm:(NSData *)response{
    BOOL errorOrNoMessage = false;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
        errorOrNoMessage = YES;
    }
    if (dict && 0 != [dict[@"status"] intValue]) {
        NSLog(@"Query Local Fence History Alarm 返回错误");
        //历史报警查询失败
        errorOrNoMessage = YES;
    }
    if (dict && 0 == [dict[@"size"] intValue]) {
        //过去24小时内没有报警信息
        errorOrNoMessage = YES;
    }
    if (errorOrNoMessage) {//表示没有查询到或有错误，就不继续处理了，按照下面说明处理
        //使用当前位置查询距离终点的距离，如果距离在范围内，则认为经过了终点
        [self judgeSuccessTrack];
        return;
    }
    // 解析数据
//    NSMutableArray *alarmInfoText = [NSMutableArray arrayWithCapacity:[dict[@"size"] intValue]];
    BOOL isEnterLocal = false;
    for (NSDictionary *alarm in dict[@"alarms"]) {
//        NSString *fenceName = alarm[@"fence_name"];
//        NSString *monitoredObject = alarm[@"monitored_person"];
//        NSString *action = nil;
        if ([alarm[@"action"] isEqualToString:@"enter"]) {
//            action = @"进入";
            isEnterLocal = YES;//表示进入过本地地理围栏
            break;
        } else if ([alarm[@"action"] isEqualToString:@"exit"]) {
//            action = @"离开";
        }
    }
    if (!isEnterLocal) {//如果没有进入本地地理围栏的结果，则使用距离判断
        [self judgeSuccessTrack];
    }else{
        //经过了终点
        [self queryCurrentRunningEndPoint:^(NSArray *points) {
            __block int successCount = 0;
            __block NSMutableArray *mutArr = [NSMutableArray arrayWithArray:points];
            for (CNLiveSportsCoordinatesModel *pointNode in self.sportsDetailModel.latLongitude) {
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
            if (successCount*1.000/self.sportsDetailModel.latLongitude.count*1.000 > 0.70) {//大于60%则认为任务完成
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->_endStatus =  @"路线完成";
                    
                    self.successStateLab.text = self->_endStatus;
                    [self uploadData:YES img:nil];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->_endStatus =  @"路线未完成";
                    self.successStateLab.text = self->_endStatus;
                    [self uploadData:NO img:nil];
                });
            }
        }];
    }
}

#pragma mark -- private 服务端地理围栏 ： 超出或进入围栏警报
//服务端
-(void)serviceGetPushMessageHandler:(NSNotification *)notification {
    if (_isEndRunning || _isStopRun) {//暂停或结束都不接收通知
        return;
    }
    NSDictionary *info = notification.userInfo;
    NSDictionary *dict = info[@"message"];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [QMUITips showInfo:str inView:AppKeyWindow hideAfterDelay:2];
//    });
//    NSDictionary *dict = @{
//                           @"action":action,
//                           @"fenceType":fenceType,
//                           @"fenceID":fenceID
//                           };
    NSString *action = dict[@"action"];//进入/离开
    NSString *fenceType = dict[@"fenceType"];//围栏类型
    NSString *fenceID = dict[@"fenceID"];//围栏id

    if ([fenceType isEqualToString:@"服务端围栏"] && [fenceID isEqualToString:[NSString stringWithFormat:@"%@",self.sportsDetailModel.fenceId]]) {
        if ([action isEqualToString:@"离开"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *actionAlert = [UIAlertController alertControllerWithTitle:nil message:@"您已偏离路径轨迹\n请您及时回归路径" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                [actionAlert addAction:action];
                [self presentViewController:actionAlert animated:YES completion:nil];
            });
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                AVSpeechSynthesizer *voice= [[AVSpeechSynthesizer alloc]init];
                AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:@"您已偏离路径轨迹，请您及时回归路径"];
                AVSpeechSynthesisVoice *language = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
                utterance.voice= language;
                [voice speakUtterance:utterance];
            });
        }else{//进入
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *actionAlert = [UIAlertController alertControllerWithTitle:nil message:@"您已回归路径轨迹\n继续参与运动吧" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                [actionAlert addAction:action];
                [self presentViewController:actionAlert animated:YES completion:nil];
            });
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                AVSpeechSynthesizer *voice= [[AVSpeechSynthesizer alloc]init];
                AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:@"您已回归路径轨迹，继续参与运动吧"];
                AVSpeechSynthesisVoice *language = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
                utterance.voice= language;
                [voice speakUtterance:utterance];
            });
        }
    }else if ([fenceType isEqualToString:@"客户端围栏"] && [fenceID isEqualToString:[NSString stringWithFormat:@"%@",localFenceId?localFenceId:@""]] && [action isEqualToString:@"进入"]){//客户端
        CNRunExitModel *model = [[CNTrackLoaclDataManager shareManager]getExitModel:CNUserShareModelUid];
        if ([model.step isEqualToString:@"<null>"] || [model.step intValue] <= 100) {
            return;
        }
        BOOL b = [[NSUserDefaults standardUserDefaults] boolForKey:@"isShowOnce"];
        if (b) {
            return;
        }
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isShowOnce"];
        //已经到达目的地 弹窗
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *actionAlert = [UIAlertController alertControllerWithTitle:nil message:@"您已经到达终点附近\n可以结束运动了" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                self.fristBgView.hidden = NO;
                self.mapView.hidden = YES;
            }];
            [actionAlert addAction:action];
            [self presentViewController:actionAlert animated:YES completion:nil];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            AVSpeechSynthesizer *voice= [[AVSpeechSynthesizer alloc]init];
            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:@"您已经到达终点附近，可以结束运动了"];
            AVSpeechSynthesisVoice *language = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
            utterance.voice= language;
            [voice speakUtterance:utterance];
        });
        
    }
}

#pragma mark -- privat 地理围栏：围栏实时状态查询
- (void)queryRealtimeStatus{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BTKQueryServerFenceStatusRequest *request = [[BTKQueryServerFenceStatusRequest alloc] initWithMonitoredObject:CNUserShareModelUid fenceIDs:@[self.sportsDetailModel.fenceId] ServiceID:BDMapServiceID tag:1];
        // 发起查询请求
        [[BTKFenceAction sharedInstance] queryServerFenceStatusWith:request delegate:self];
    });
}
#pragma mark -- 围栏
//实时查询一次监控对象在服务端地理围栏内外的回调方法
-(void)onQueryServerFenceStatus:(NSData *)response{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
        NSLog(@"Server Fence List查询格式转换出错");
        return;
    }
    if ([dict[@"message"] isEqualToString:@"成功"]) {
//        NSArray *arrr = dict[@"monitored_statuses"];
//        NSDictionary *dictt = arrr[0];
//        NSString *ssttt = dictt[@"monitored_status"];
//        [QMUITips showWithText:[NSString stringWithFormat:@"%@___单次查询围栏内外的回调方法",ssttt] inView:self.mapView hideAfterDelay:1.5];
    }else{
//        [QMUITips showWithText:@"错误内外的回调方法" inView:self.mapView hideAfterDelay:1.5];
    }
    
    //查询一次本地地理围栏的状态
    //创建成功后查询一次本地围栏的实时状态，目的是使本地地理围栏生效
    if (localFenceId) {
        //本地地理围栏存在，查询一次本地地理围栏的实时状态
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BTKQueryLocalFenceStatusRequest *request = [[BTKQueryLocalFenceStatusRequest alloc] initWithMonitoredObject:CNUserShareModelUid fenceIDs:@[self->localFenceId] tag:1];
            [[BTKFenceAction sharedInstance] queryLocalFenceStatusWith:request delegate:self];
        });
    }
//    else{
//        //本地地理围栏不存在，先创建一个本地地理围栏，然后再查实时状态
//        [self queryLocalFence];
//    }
}
////查询监控对象的服务端围栏报警信息的回调方法
//-(void)onQueryServerFenceHistoryAlarm:(NSData *)response{
//    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
//    if (nil == dict) {
//        NSLog(@"Server Fence List查询格式转换出错");
//        return;
//    }
//    if (dict[@"message"]) {
//        //        [QMUITips showWithText:dict[@"message"] inView:self.mapView hideAfterDelay:5];
//    }else{
//        [QMUITips showWithText:@"错误报警信息的回调方法" inView:self.mapView hideAfterDelay:5];
//    }
//}

#pragma mark -- private
- (void)initData{
    [CNTrackServiceManager defaultManager].isStartRecord = YES;
    //禁止左滑返回
//    #pragma mark -- TODO 是否有必须禁止左滑
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serviceGetPushMessageHandler:) name:TrackServiceGetPushMessageNotification object:nil];//服务端地理围栏的警报通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runningFromBgToBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    //app进入后台
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runningToBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

    //gps信号状态初始化
    self.gpsState = CNLocationGPSStateNull;
    [CNTrackServiceManager defaultManager].isClickGoOn = NO;//处理暂停的逻辑
    //跑步已经用时
    if (self.exitModel.eventId.length > 0) {
        if (self.exitModel.step.length > 0 && ![self.exitModel.step isEqualToString:@"<null>"]) {
            _lastStepCount = [self.exitModel.step integerValue];
        }else{
            _lastStepCount = 0;
        }
        _startRunningDate = [self.exitModel.startTime integerValue];
        double km = _lastStepCount*60.0/100/1000;
        NSDictionary *attributesNum = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:70]};
        NSDictionary *attributesKM = @{NSFontAttributeName:[UIFont systemFontOfSize:15]};
        NSAttributedString *attributedString = [self attributedText:@[[NSString stringWithFormat:@"%.2f",floor((km)*100)/100],@" 公里"] attributeAttay:@[attributesNum,attributesKM]];
        self.currentKMLab.attributedText = attributedString;
        self.mapCurrentKMLab.text = [NSString stringWithFormat:@"%.2f",floor((km)*100)/100];
        self.currentStepLab.text = [NSString stringWithFormat:@"%ld",_lastStepCount];
        
        if ([self.exitModel.isStop isEqualToString:@"yes"]) {//重新进入后，处理出去前得暂停逻辑
            //现在的时间减去开始的时间，获取间隔的秒给_totalTime赋值
            _stopDate = [self.exitModel.stopTime integerValue];
            NSTimeInterval intervalS = [[NSDate dateWithTimeIntervalSince1970:_startRunningDate] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:_stopDate]];
            _totalTime = labs((NSInteger)intervalS);
            if (self.exitModel.reStartTime.length > 0 && ![self.exitModel.reStartTime isEqualToString:@"<null>"]){
                _reStartDate = [self.exitModel.reStartTime integerValue];
                NSTimeInterval reIntervalS = [[NSDate dateWithTimeIntervalSince1970:_reStartDate] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:[CNLiveTimeTools getNowTimestamp]]];
                _totalTime += labs((NSInteger)reIntervalS);
            }else{
                self.exitModel.reStartTime = [NSString stringWithFormat:@"%ld",(long)[CNLiveTimeTools getNowTimestamp]];
                _reStartDate = [self.exitModel.reStartTime integerValue];
                [[CNTrackLoaclDataManager shareManager]updateExitModel:self.exitModel];
            }
            self.mapCurrentSpeedLab.text = [self getPaceSpeed:_totalTime distance:km];

            self.currentSpeedLab.text = [self getPaceSpeed:_totalTime distance:km];
            //记录步数
            [[CNTrackServiceManager defaultManager] recordStep:[NSDate date] isUser:YES];
        }else{
            //现在的时间减去开始的时间，获取间隔的秒给_totalTime赋值
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[CNLiveTimeTools getNowTimestamp]];
            NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:[self.exitModel.startTime integerValue]];
            NSInteger intervalS = [startDate timeIntervalSinceDate:date2];
            _totalTime = labs((NSInteger)intervalS);
            self.mapCurrentSpeedLab.text = [self getPaceSpeed:_totalTime distance:km];

            self.currentSpeedLab.text = [self getPaceSpeed:_totalTime distance:km];
            //记录步数
            [[CNTrackServiceManager defaultManager] recordStep:[NSDate date] isUser:YES];
        }
    }else{
        _totalTime = 0;
        _lastStepCount = 0;
        //持久记录开始时间
        self.exitModel = [[CNRunExitModel alloc] init];
        self.exitModel.eventId = self.eventID;
        self.exitModel.userId = CNUserShareModelUid;
        _startRunningDate = [CNLiveTimeTools getNowTimestamp];
        self.exitModel.startTime = [NSString stringWithFormat:@"%ld",(long)_startRunningDate];
        [[CNTrackLoaclDataManager shareManager] insertExitModel:self.exitModel];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_startRunningDate];
        //记录步数
        [[CNTrackServiceManager defaultManager] recordStep:date isUser:YES];
    }
}

- (void)runningFromBgToBecomeActive{
//    //清空地图上自己的轨迹，清空array
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.mapView removeOverlay:self.stopBeforePolyLine];
//        [self.mapView removeOverlay:self.stopAfterPolyLine];
//        [self.mapView removeOverlay:self.frontStopAfterPolyLine];
//        [self.locationPoints removeAllObjects];
//    });
//    //查询历史轨迹
//    [self getHistoryPoints];
//
//    if (_isEndRunning) {
//        [[CNTrackServiceManager defaultManager] stopGather];
//    }else{
//        //控制鹰眼服务
//        if (![CNTrackServiceManager defaultManager].isServiceStarted) {
//            // 开启服务之间先配置轨迹服务的基础信息
//            BTKServiceOption *basicInfoOption = [[BTKServiceOption alloc] initWithAK:AK mcode:MCODE serviceID:serviceID keepAlive:YES];
//            [[BTKAction sharedInstance] initInfo:basicInfoOption];
//            // 开启服务
//            BTKStartServiceOption *startServiceOption = [[BTKStartServiceOption alloc] initWithEntityName:CNUserShareModelUid];
//            [[CNTrackServiceManager defaultManager] startServiceWithOption:startServiceOption];
//        }else{
//            if (![CNTrackServiceManager defaultManager].isGatherStarted) {
//                [[CNTrackServiceManager defaultManager] startGather];
//            }
//        }
//        //实时查询一次两个围栏
//        [self queryRealtimeStatus];
//        //创建成功后查询一次本地围栏的实时状态，目的是使本地地理围栏生效
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            if (self->localFenceId) {
//                BTKQueryLocalFenceStatusRequest *request = [[BTKQueryLocalFenceStatusRequest alloc] initWithMonitoredObject:CNUserShareModelUid fenceIDs:@[self->localFenceId] tag:1];
//                [[BTKFenceAction sharedInstance] queryLocalFenceStatusWith:request delegate:self];
//            }
//        });
//    }
    
}

//- (void)runningToBackground{
//    //app进入后台的时候记录一下数据
//
//}

//判断是否完成了规划的路线
- (void)judgeSuccessTrack{
    [self queryCurrentRunningEndPoint:^(NSArray *points) {
        __block int successCount = 0;
        __block NSMutableArray *mutArr = [NSMutableArray arrayWithArray:points];
        //逆序遍历自己的轨迹点和终点做比较，差值小于20说明经过了终点
        __block BOOL isPassEndADD = false;
        [mutArr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CNHistoryTrackPoint *minePoint = obj;
            CLLocation *minP = [[CLLocation alloc] initWithLatitude:minePoint.coordinate.latitude longitude:minePoint.coordinate.longitude];
            CLLocation *endP = [[CLLocation alloc] initWithLatitude:self.endAnnotation.coordinate.latitude longitude:self.endAnnotation.coordinate.longitude];
            CLLocationDistance distance = [minP distanceFromLocation:endP];
            if (distance < 20) {//完成了
                isPassEndADD = YES;
                *stop = YES;
            }
        }];
        if (!isPassEndADD) {
             //没经过终点说明没完成,直接请求服务器接口
            [self uploadData:NO img:nil];
        }else{
            for (CNLiveSportsCoordinatesModel *pointNode in self.sportsDetailModel.latLongitude) {
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
            if (successCount*1.000/self.sportsDetailModel.latLongitude.count*1.000 > 0.70) {//大于70%则认为任务完成
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->_endStatus = @"路线完成";
                    self.successStateLab.text = self->_endStatus;
                    [self uploadData:YES img:nil];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->_endStatus = @"路线未完成";
                    self.successStateLab.text = self->_endStatus;
                    [self uploadData:NO img:nil];
                });
            }
        }
    }];
}

- (void)alertEndSelect:(BOOL)isSuccessTrack img:(NSString *)imgUrlStr{
    //弹窗，无网络，是否暂存，是否重试
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *actionAlert = [UIAlertController alertControllerWithTitle:nil message:@"上传数据失败\n是否重试" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self uploadData:isSuccessTrack img:imgUrlStr];
        }];
        [actionAlert addAction:action];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"暂存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (self->_endTimer) {
                [self->_endTimer invalidate];
                self->_endTimer = nil;
            }
            if (self->_startRunningTimer) {
                [self->_startRunningTimer invalidate];
                self->_startRunningTimer = nil;
            }
            [CNTrackServiceManager defaultManager].isStartRecord = NO;
            //长按结束了，删除数据库中的逻辑辅助数据
            [[CNTrackLoaclDataManager shareManager] deleteExitModel:CNUserShareModelUid];
            //更新上一页的最底部的按钮状态：发通知
            [[NSNotificationCenter defaultCenter] postNotificationName:CNLiveSport_DetailUplaod object:nil];
            //跳转到失败列表
            CNReUploadViewController *vc = [[CNReUploadViewController alloc] init];
            vc.isNeedBack = YES;
            self->_isStopAnimation = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }];
        [actionAlert addAction:action1];
        [self presentViewController:actionAlert animated:YES completion:nil];
    });
}

- (void)uploadData:(BOOL)isSuccessTrack img:(NSString *)imgUrlStr{
    if (![CNLiveNetworking isNetworking]) {
        [self alertEndSelect:isSuccessTrack img:imgUrlStr];
        return;
    }
    self.exitModel = [[CNTrackLoaclDataManager shareManager] getExitModel:CNUserShareModelUid];
    NSString *strUrl = CNSportsChinaSaveRecordUrl;
    BOOL _isTempStop = NO;
    if (self.exitModel.isStop.length>0 && ![self.exitModel.isStop isEqualToString:@"<null>"]) {
        _isTempStop = YES;
    }
    NSString *_tempPace = [self.currentSpeedLab.text isEqualToString:@"--"]?@"0":self.currentSpeedLab.text;
    NSString *_tempStep = [self.currentStepLab.text isEqualToString:@"--"]?@"0":self.currentStepLab.text;

    NSDictionary *dict = @{
                           @"eventId":self.eventID,
                           @"sid":CNUserShareModelUid,
                           @"employTime":[NSString stringWithFormat:@"%ld",(long)_totalTime],
                           @"mileage":self.mapCurrentKMLab.text,
                           @"pace":_tempPace,
                           @"step":_tempStep,
                           //@"roadmap":imgUrlStr,
                           @"startTime":[NSString stringWithFormat:@"%ld",(long)_startRunningDate],
                           @"endTime":[NSString stringWithFormat:@"%ld",(long)_endRunningDate],
                           @"isPause":_isTempStop?@"1":@"0",
                           @"pauseTime":_isTempStop?self.exitModel.stopTime:@"",
                           @"continueTime":_isTempStop?self.exitModel.reStartTime:@"",
                           @"completeStatus":isSuccessTrack?@"1":@"0"
                           };

    [CNLiveNetworking requestNetworkWithMethod:CNLiveRequestMethodPOST URLString:strUrl Param:dict CacheType:CNLiveNetworkCacheTypeNetworkOnly CompletionBlock:^(NSURLSessionTask *requestTask, id responseObject, NSError *error) {
        if (error) {
            //弹窗，是否暂存，是否重试
            [self alertEndSelect:isSuccessTrack img:imgUrlStr];
        }else{
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSString *resultCode = [NSString stringWithFormat:@"%@", responseObject[@"errorCode"]];
                if ([resultCode isEqualToString:@"0"]) {
                    //长按结束了，删除数据库中的逻辑辅助数据
                    [[CNTrackLoaclDataManager shareManager] deleteExitModel:CNUserShareModelUid];
                    [[CNTrackLoaclDataManager shareManager] deleteFUploadModel:self->failModel];
                    //更新上一页的最底部的按钮状态：发通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:CNLiveSport_DetailUplaod object:nil];
                    [self afterLongPress];
                }else{
                    //弹窗，是否暂存，是否重试
                    [self alertEndSelect:isSuccessTrack img:imgUrlStr];
                }
            }else{
                [QMUITips showInfo:@"服务异常，请重试" inView:AppKeyWindow hideAfterDelay:1.5];
            }
        }
    }];
}

#pragma mark -- private 长按结束后的UI处理
- (void)afterLongPress{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backBtn.userInteractionEnabled = YES;
        [self.preSaveView removeAllSubviews];
        [self.preSaveView removeFromSuperview];
        self.saveBtn.hidden = NO;
        self->_isStopAnimation = YES;
    });
}

- (void)backFirstBtnAction{
    if (_endTimer) {
        [_endTimer invalidate];
        _endTimer = nil;
    }
    if (_startRunningTimer) {
        [_startRunningTimer invalidate];
        _startRunningTimer = nil;
    }
    if ([self.delegate respondsToSelector:@selector(backToFrontVC)]) {
        [self.delegate backToFrontVC];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)getPaceSpeed:(double)second distance:(double)distance{
    if (distance != 0) {
        //计算分
        int minute = (int) (second / distance / 60);
        //获取秒
        double miaoMin = ((double) (second / distance / 60)) - ((int) (second / distance / 60));
        int miao = (int) (miaoMin * 60);
        return [NSString stringWithFormat:@"%d′%d″",minute,miao];
    } else {
        return @"0";
    }
}

- (void)startRunningTime{
    
    self.startRunningTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(cumulativeTiming) userInfo:nil repeats:YES];
}

- (void)cumulativeTiming{
    _totalTime ++;
    self.currentTimeLab.text = [CNLiveTimeTools getMMSSFromSS:[NSString stringWithFormat:@"%ld",(long)_totalTime]];
    self.mapCurrentTimeLab.text = [CNLiveTimeTools getMMSSFromSS:[NSString stringWithFormat:@"%ld",(long)_totalTime]];
}

// 获取带有不同样式的文字内容
//stringArray 字符串数组
//attributeAttay 样式数组
- (NSAttributedString *)attributedText:(NSArray*)stringArray attributeAttay:(NSArray *)attributeAttay{
    // 定义要显示的文字内容
    NSString * string = [stringArray componentsJoinedByString:@""];//拼接传入的字符串数组
    // 通过要显示的文字内容来创建一个带属性样式的字符串对象
    NSMutableAttributedString * result = [[NSMutableAttributedString alloc] initWithString:string];
    for(NSInteger i = 0; i < stringArray.count; i++){
        // 将某一范围内的字符串设置样式
        [result setAttributes:attributeAttay[i] range:[string rangeOfString:stringArray[i]]];
    }
    // 返回已经设置好了的带有样式的文字
    return [[NSAttributedString alloc] initWithAttributedString:result];
}

- (void)addFirstView{
    [self.view addSubview:self.fristBgView];
    [self.fristBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    [self.fristBgView addSubview:self.backFirstBtn];
    [self.backFirstBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fristBgView).offset(kVerticalStatusHeight+10);
        make.left.equalTo(self.fristBgView).offset(5);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_back_white"]];
    [self.backFirstBtn addSubview:imageV];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backFirstBtn);
        make.right.equalTo(self.backFirstBtn).offset(-5);
        make.size.mas_equalTo(CGSizeMake(12, 20));
    }];
    [self.fristBgView addSubview:self.currentKMLab];
    [self.currentKMLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(130);
    }];
    
    NSDictionary *attributesNum = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:70]};
    NSDictionary *attributesKM = @{NSFontAttributeName:[UIFont systemFontOfSize:15]};
    NSAttributedString *attributedString = [self attributedText:@[self.mapCurrentKMLab.text,@" 公里"]
                                                   attributeAttay:@[attributesNum,attributesKM]];
    self.currentKMLab.attributedText = attributedString;
    

    [self.fristBgView addSubview:self.gpsLab];
    [self.gpsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(25);
        make.top.equalTo(self.currentKMLab.mas_bottom).offset(100);
    }];
    [self.fristBgView addSubview:self.currentGPSImgView];
    [self.currentGPSImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.gpsLab);
        make.left.equalTo(self.gpsLab.mas_right).offset(10);
    }];
    [self.fristBgView addSubview:self.currentGPSLab];
    [self.currentGPSLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.gpsLab);
        make.left.equalTo(self.currentGPSImgView.mas_right).offset(10);
    }];
    [self.fristBgView addSubview:self.detailMapBtn];
    [self.detailMapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.gpsLab);
        make.right.equalTo(self.view.mas_right).offset(-25);
        make.width.height.equalTo(@(52));
    }];
    self.detailMapBtn.layer.cornerRadius = 52/2;
    self.detailMapBtn.layer.masksToBounds = YES;
    [self.fristBgView addSubview:self.mapDesLab];
    [self.mapDesLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.detailMapBtn);
        make.top.equalTo(self.detailMapBtn.mas_bottom).offset(10);
    }];
    [self.fristBgView addSubview:self.speedImgView];
    [self.speedImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mapDesLab.mas_bottom).offset(25);
        make.left.equalTo(self.view).offset(45);
        make.size.mas_equalTo(CGSizeMake(26, 23));
    }];
    [self.fristBgView addSubview:self.currentSpeedLab];
    [self.currentSpeedLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.speedImgView);
        make.top.equalTo(self.speedImgView.mas_bottom).offset(20);
        make.width.equalTo(@(SCREEN_WIDTH/3-40));
    }];
    [self.fristBgView addSubview:self.speedDesLab];
    [self.speedDesLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.speedImgView);
        make.top.equalTo(self.currentSpeedLab.mas_bottom).offset(20);
    }];
    [self.fristBgView addSubview:self.timeImgView];
    [self.timeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.speedImgView);
        make.size.mas_equalTo(CGSizeMake(23, 25));
    }];
    [self.fristBgView addSubview:self.currentTimeLab];
    [self.currentTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.timeImgView);
        make.centerY.equalTo(self.currentSpeedLab);
    }];
    [self.fristBgView addSubview:self.timeDesLab];
    [self.timeDesLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.timeImgView);
        make.centerY.equalTo(self.speedDesLab);
    }];
    [self.fristBgView addSubview:self.stepImgView];
    [self.stepImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.speedImgView);
        make.right.equalTo(self.view.mas_right).offset(-45);
        make.size.mas_equalTo(CGSizeMake(26, 24));
    }];
    [self.fristBgView addSubview:self.currentStepLab];
    [self.currentStepLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.stepImgView);
        make.centerY.equalTo(self.currentSpeedLab);
    }];
    [self.fristBgView addSubview:self.stepDesLab];
    [self.stepDesLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.stepImgView);
        make.centerY.equalTo(self.speedDesLab);
    }];
    [self.fristBgView addSubview:self.stopRunningBtn];
    [self.stopRunningBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeDesLab.mas_bottom).offset(60);
        make.size.mas_equalTo(CGSizeMake(90, 90));
        make.centerX.equalTo(self.view).offset(-SCREEN_WIDTH/4+SCREEN_WIDTH/16);
    }];
    self.stopRunningBtn.layer.cornerRadius = 90/2;
    self.stopRunningBtn.layer.masksToBounds = YES;
    
    [self.fristBgView addSubview:self.goonRunningBtn];
    self.goonRunningBtn.hidden = YES;
    [self.goonRunningBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeDesLab.mas_bottom).offset(60);
        make.size.mas_equalTo(CGSizeMake(90, 90));
        make.centerX.equalTo(self.view).offset(-SCREEN_WIDTH/4+SCREEN_WIDTH/16);
    }];
    self.goonRunningBtn.layer.cornerRadius = 90/2;
    self.goonRunningBtn.layer.masksToBounds = YES;
    [self.fristBgView addSubview:self.endRunningBgView];
    [self.endRunningBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeDesLab.mas_bottom).offset(60);
        make.size.mas_equalTo(CGSizeMake(90, 90));
        make.centerX.equalTo(self.view).offset(SCREEN_WIDTH/4-SCREEN_WIDTH/16);
    }];
    self.endRunningBgView.layer.cornerRadius = 90/2;
    self.endRunningBgView.layer.masksToBounds = YES;
    [self.fristBgView addSubview:self.endRunningBtn];
    [self.endRunningBtn addGestureRecognizer:self.longPress];
    [self.endRunningBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeDesLab.mas_bottom).offset(60);
        make.size.mas_equalTo(CGSizeMake(90, 90));
        make.centerX.equalTo(self.view).offset(SCREEN_WIDTH/4-SCREEN_WIDTH/16);
    }];
    self.endRunningBtn.layer.cornerRadius = 90/2;
    self.endRunningBtn.layer.masksToBounds = YES;
    [self.fristBgView addSubview:self.endTipView];
    self.endTipView.hidden = YES;
    [self.endTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.endRunningBtn.mas_top);
        make.centerX.equalTo(self.endRunningBtn);
        make.size.mas_equalTo(CGSizeMake(72, 33));
    }];
    [self.endTipView addSubview:self.endTipLab];
    [self.endTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.endTipView);
        make.top.equalTo(self.endTipView).offset(6);
    }];
}
- (void)showMapView:(UIButton *)btn{
    self.fristBgView.hidden = YES;
    self.mapView.hidden = NO;
}
- (void)stopRunningBtnAction:(UIButton *)btn{
    if ([self.exitModel.stopCount integerValue] == 1) {
//        [QMUITips showInfo:@"当前无法暂停" inView:self.view hideAfterDelay:1.5];
        UIAlertController *actionAlert = [UIAlertController alertControllerWithTitle:nil message:@"当前无法暂停" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [actionAlert addAction:action];
        [self presentViewController:actionAlert animated:YES completion:nil];
        return;
    }
    
    UIAlertController *actionAlert = [UIAlertController alertControllerWithTitle:nil message:@"固定赛事只可暂停一次\n是否确定使用" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [actionAlert addAction:action];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [QMUITips showLoadingInView:AppKeyWindow];
        [CNTrackServiceManager defaultManager].isStartRecord = NO;
        self->_stopDate = [CNLiveTimeTools getNowTimestamp];
        self.exitModel.eventId = self.eventID;
        self.exitModel.startTime = [NSString stringWithFormat:@"%ld",self->_startRunningDate];
        self.exitModel.stopTime = [NSString stringWithFormat:@"%ld",self->_stopDate];
        self.exitModel.step = self.currentStepLab.text;
        self.exitModel.isStop = @"yes";
        self.exitModel.stopCount = @"1";
        [[CNTrackLoaclDataManager shareManager]updateExitModel:self.exitModel];
        self.stopRunningBtn.hidden = YES;
        self.goonRunningBtn.hidden = NO;
        //暂停时间和步数
        self.startRunningTimer.fireDate = [NSDate distantFuture];
        [CNTrackServiceManager defaultManager].isStartRecord = NO;
        //控制鹰眼服务
        [[CNTrackServiceManager defaultManager] stopGather];
        self->_isStopRun = YES;
        NSArray *arr = self.locationPoints;
        [self.locationPoints removeAllObjects];
        CLLocationCoordinate2D coors[arr.count];
        NSInteger count = 0;
        for (size_t i = 0; i < arr.count; i++) {
            CLLocation *location = [arr objectAtIndex:i];
            coors[i] = location.coordinate;
            count++;
        }
        self.noExitStopFrontPolyLine = [BMKPolyline polylineWithCoordinates:coors count:count];
        if (self.noExitStopFrontPolyLine) {// 防止重复绘制
            [self.mapView removeOverlay:self.noExitStopFrontPolyLine];
        }
        if (self.stopAfterPolyLine) {
            [self.mapView removeOverlay:self.stopAfterPolyLine];
        }
        [self.mapView addOverlay:self.noExitStopFrontPolyLine];
        [QMUITips hideAllTips];
    }];
    [actionAlert addAction:action1];
    [self presentViewController:actionAlert animated:YES completion:nil];
}

- (void)goonRunningBtnAction:(UIButton *)btn{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serviceResultHandler:) name:TrackServiceOperationResultNotification object:nil];//两个服务的通知
    //控制鹰眼服务
    if (![CNTrackServiceManager defaultManager].isServiceStarted) {
        // 开启服务之间先配置轨迹服务的基础信息
        BTKServiceOption *basicInfoOption = [[BTKServiceOption alloc] initWithAK:BDMapAK mcode:BDMapMCODE serviceID:BDMapServiceID keepAlive:YES];
        [[BTKAction sharedInstance] initInfo:basicInfoOption];
        // 开启服务
        BTKStartServiceOption *startServiceOption = [[BTKStartServiceOption alloc] initWithEntityName:CNUserShareModelUid];
        [[CNTrackServiceManager defaultManager] startServiceWithOption:startServiceOption];
    }else{
        if (![CNTrackServiceManager defaultManager].isGatherStarted) {
            [[CNTrackServiceManager defaultManager] startGather];
        }else{
            [CNTrackServiceManager defaultManager].isStartRecord = YES;
            [self.startRunningTimer setFireDate:[NSDate date]];
//            [self startRunningTime];
            _isStopRun = NO;
            [CNTrackServiceManager defaultManager].isClickGoOn = YES;
            
            //实时查询一次两个围栏
            [self queryRealtimeStatus];
            if ([self.exitModel.isStop isEqualToString:@"yes"]) {
                if (self.exitModel.reStartTime.length > 0 && ![self.exitModel.reStartTime isEqualToString:@"<null>"]) {
                    _reStartDate = [self.exitModel.reStartTime integerValue];
                    self.exitModel.reStartTime = [NSString stringWithFormat:@"%ld",_reStartDate];
                    [[CNTrackLoaclDataManager shareManager] updateExitModel:self.exitModel];
                }else{
                    _reStartDate = [CNLiveTimeTools getNowTimestamp];
                    self.exitModel.reStartTime = [NSString stringWithFormat:@"%ld",_reStartDate];
                    [[CNTrackLoaclDataManager shareManager] updateExitModel:self.exitModel];
                }
            }
            self.stopRunningBtn.hidden = NO;
            self.goonRunningBtn.hidden = YES;
            //    self.startRunningTimer.fireDate = [NSDate distantPast];
            //记录步数
            [[CNTrackServiceManager defaultManager] recordStep:[NSDate date] isUser:YES];
        }
    }
}

- (void)serviceResultHandler:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *info = notification.userInfo;
        ServiceOperationType type = (ServiceOperationType)[info[@"type"] unsignedIntValue];
        NSString *title = info[@"title"];
        NSString *message = info[@"message"];
        switch (type) {
            case TRACK_SERVICE_OPERATION_TYPE_START_SERVICE:
            {
                if ([title isEqualToString:@"轨迹服务开启失败"]) {
                    UIAlertController *actionAlert = [UIAlertController alertControllerWithTitle:nil message:@"服务异常,请重试。" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [actionAlert addAction:action];
                    [self presentViewController:actionAlert animated:YES completion:nil];
                }else{
                    //开始服务成功，开启采集服务
                    if (![CNTrackServiceManager defaultManager].isGatherStarted) {
                        [[CNTrackServiceManager defaultManager] startGather];
                    }
                }
            }
                break;
            case TRACK_SERVICE_OPERATION_TYPE_STOP_SERVICE:
            {
                //服务停止失败
                if ([title isEqualToString:@"轨迹服务停止失败"]) {
                    NSLog(@"轨迹服务停止失败");
                    if ([CNTrackServiceManager defaultManager].isServiceStarted) {
                        [[CNTrackServiceManager defaultManager] stopService];//停止服务
                    }
                }else{
                    NSLog(@"轨迹服务停止成功");
                    //停止更新位置
                    if (self->_isEndRunning) {
                        @try {
                            [self.locationManager stopUpdatingLocation];
                            [self.locationManager stopUpdatingHeading];
                        } @catch (NSException *exception) {
                            NSLog(@"CNStartRunningViewController.m 崩溃了");
                        }
                    }
                }
            }
                break;
            case TRACK_SERVICE_OPERATION_TYPE_START_GATHER:
            {
                if ([title isEqualToString:@"开始采集失败"]) {
                    if ([message isEqualToString:@"没有开启后台定位权限"] || [message isEqualToString:@"没有开启系统定位服务"]){
                        UIAlertController *actionAlert = [UIAlertController alertControllerWithTitle:@"无法获取你的位置信息" message:@"请到手机系统的[隐私]->[定位服务]->[网家家]中打开定位服务，并勾选\"始终\"选项" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        }];
                        [actionAlert addAction:action];
                        [self presentViewController:actionAlert animated:YES completion:nil];
                    }else if([message isEqualToString:@"已经在采集轨迹，请勿重复开始"]){
                        [CNTrackServiceManager defaultManager].isStartRecord = YES;
                        [self.startRunningTimer setFireDate:[NSDate date]];
//                        [self startRunningTime];
                        self->_isStopRun = NO;
                        [CNTrackServiceManager defaultManager].isClickGoOn = YES;
                        
                        //实时查询一次两个围栏
                        [self queryRealtimeStatus];
                        if ([self.exitModel.isStop isEqualToString:@"yes"]) {
                            if (self.exitModel.reStartTime.length > 0 && ![self.exitModel.reStartTime isEqualToString:@"<null>"]) {
                                self->_reStartDate = [self.exitModel.reStartTime integerValue];
                                self.exitModel.reStartTime = [NSString stringWithFormat:@"%ld",self->_reStartDate];
                                [[CNTrackLoaclDataManager shareManager] updateExitModel:self.exitModel];
                            }else{
                                self->_reStartDate = [CNLiveTimeTools getNowTimestamp];
                                self.exitModel.reStartTime = [NSString stringWithFormat:@"%ld",self->_reStartDate];
                                [[CNTrackLoaclDataManager shareManager] updateExitModel:self.exitModel];
                            }
                        }
                        self.stopRunningBtn.hidden = NO;
                        self.goonRunningBtn.hidden = YES;
                        //    self.startRunningTimer.fireDate = [NSDate distantPast];
                        //记录步数
                        [[CNTrackServiceManager defaultManager] recordStep:[NSDate date] isUser:YES];
                    }else{
                        UIAlertController *actionAlert = [UIAlertController alertControllerWithTitle:nil message:@"服务异常,请重试。" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        }];
                        [actionAlert addAction:action];
                        [self presentViewController:actionAlert animated:YES completion:nil];
                    }
                }else{
                    [CNTrackServiceManager defaultManager].isStartRecord = YES;
                    [self.startRunningTimer setFireDate:[NSDate date]];
//                    [self startRunningTime];
                    self->_isStopRun = NO;
                    [CNTrackServiceManager defaultManager].isClickGoOn = YES;
                    
                    //实时查询一次两个围栏
                    [self queryRealtimeStatus];
                    if ([self.exitModel.isStop isEqualToString:@"yes"]) {
                        if (self.exitModel.reStartTime.length > 0 && ![self.exitModel.reStartTime isEqualToString:@"<null>"]) {
                            self->_reStartDate = [self.exitModel.reStartTime integerValue];
                            self.exitModel.reStartTime = [NSString stringWithFormat:@"%ld",self->_reStartDate];
                            [[CNTrackLoaclDataManager shareManager] updateExitModel:self.exitModel];
                        }else{
                            self->_reStartDate = [CNLiveTimeTools getNowTimestamp];
                            self.exitModel.reStartTime = [NSString stringWithFormat:@"%ld",self->_reStartDate];
                            [[CNTrackLoaclDataManager shareManager] updateExitModel:self.exitModel];
                        }
                    }
                    self.stopRunningBtn.hidden = NO;
                    self.goonRunningBtn.hidden = YES;
                    //    self.startRunningTimer.fireDate = [NSDate distantPast];
                    //记录步数
                    [[CNTrackServiceManager defaultManager] recordStep:[NSDate date] isUser:YES];
                }
            }
                break;
            case TRACK_SERVICE_OPERATION_TYPE_STOP_GATHER:
            {
                //采集停止失败
                if ([title isEqualToString:@"停止采集失败"]) {
                    NSLog(@"停止采集失败");
                    if ([CNTrackServiceManager defaultManager].isGatherStarted) {
                        [[CNTrackServiceManager defaultManager] stopGather];//重新停止采集
                    }else{
                        if ([CNTrackServiceManager defaultManager].isServiceStarted) {
                            [[CNTrackServiceManager defaultManager] stopService];//停止服务
                        }
                    }
                }else{//采集停止成功后，停止服务
                    NSLog(@"停止采集成功");
                    if ([CNTrackServiceManager defaultManager].isServiceStarted) {
                        [[CNTrackServiceManager defaultManager] stopService];//停止服务
                    }
                }
            }
                break;
            default:{
                UIAlertController *actionAlert = [UIAlertController alertControllerWithTitle:nil message:@"服务异常,请重试。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                [actionAlert addAction:action];
                [self presentViewController:actionAlert animated:YES completion:nil];
            }
                break;
        }
    });
}


- (void)endRunningBtnAction:(UIButton *)btn{
    self.endTipView.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.endTipView.hidden = YES;
    });
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        self.endRunningBgView.transform = CGAffineTransformScale(self.endRunningBtn.transform, 1.2,1.2);
        _isStopEnd = NO;
        [self addProgressViewByAutoLayout];
        //开始计时
        _pressEndBtnCurrentTime = 0;//计时器归零
        self.endTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(cycleProgressRecord) userInfo:nil repeats:YES];
    }else if (longPress.state == UIGestureRecognizerStateCancelled || longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateFailed){
        _isStopEnd = YES;
    }
}
//添加cycle
- (void)addProgressViewByAutoLayout {
    self.progressView = [[CNRunEndCircleProgress alloc] initWithFrame:CGRectZero pathBackColor:[UIColor grayColor] pathFillColor:[UIColor whiteColor] startAngle:0 strokeWidth:20];
    self.progressView.backgroundColor = [UIColor clearColor];
    [self.endRunningBtn addSubview:self.progressView];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.endRunningBtn);
        make.size.mas_equalTo(CGSizeMake(90, 90));
    }];
    self.progressView.startAngle = 270;
    self.progressView.reduceAngle = 0;
    self.progressView.strokeWidth = 2;
    self.progressView.duration = 2;
    self.progressView.showPoint = NO;
    self.progressView.showProgressText = NO;
    self.progressView.increaseFromLast = YES;
}
- (void)cycleProgressRecord{
    if (_isStopEnd || _pressEndBtnCurrentTime >= 1.5) {
        if (_pressEndBtnCurrentTime >= 1.5) {
            self.endTipView.hidden = YES;
            _isEndRunning = YES;
            //持久记录结束时间
            _endRunningDate = [CNLiveTimeTools getNowTimestamp];
            self.backBtn.userInteractionEnabled = NO;
            [self afterLongPressDealAction];//长按结束后的处理
        }else{
            self.endTipView.hidden = NO;
        }
        self.endRunningBgView.transform = CGAffineTransformIdentity;
        _pressEndBtnCurrentTime = 0;
        _isStopEnd = YES;
        [self.progressView removeAllSubviews];
        [self.progressView removeFromSuperview];
        if ([self.endTimer isValid]){//停止计时器
            [self.endTimer invalidate];
            self.endTimer = nil;
            return;
        }
    }
    _pressEndBtnCurrentTime += 0.15;
    self.progressView.progress = _pressEndBtnCurrentTime/1.5;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.endTipView.hidden = YES;
    });
}

#pragma mark -- private 长按结束后的事件处理
- (void)afterLongPressDealAction{
   [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isShowOnce"];
    //(删除本地地理围栏；待定)停止服务端地理围栏；停止服务；
    //停止轨迹服务；停止定位、画线；停止计步器，暂停时间
    //停止服务端采集服务，去回调中停止另一个服务
    [self deleteLocalFence];//删除地理围栏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serviceResultHandler:) name:TrackServiceOperationResultNotification object:nil];//两个服务的通知
    [[CNTrackServiceManager defaultManager] stopGather];//停止鹰眼服务
    
    self.startRunningTimer.fireDate = [NSDate distantFuture];
    [CNTrackServiceManager defaultManager].isStartRecord = NO;
    //把自己从地图中移除
    self.mapView.showsUserLocation = NO;
    //下面是UI
    self.fristBgView.hidden = YES;//隐藏主页面
    self.mapView.hidden = NO;//展示主界面
    [self.GPSBtn removeFromSuperview];//移除map上的gps
    [self.tipGPSBtn removeFromSuperview];//移除map上的gps提示
    [self.mapBottomView removeFromSuperview];//移除地图底部的view
    [self.resetBtn removeFromSuperview];//移除重新定位按钮
    
    //先往失败列表存一下，上传成功后再删除
    failModel = [[CNTrackUploadFailModel alloc] init];
    failModel.userId =  CNUserShareModelUid;
    failModel.eventId = self.eventID;
    failModel.eventName = self.sportsDetailModel.title;
    failModel.startTime = self.exitModel.startTime;
    failModel.endTime = [NSString stringWithFormat:@"%ld",(long)_endRunningDate];
    if ([self.exitModel.isStop isEqualToString:@"yes"]) {
        failModel.isStop = @"yes";
        failModel.stopTime = self.exitModel.stopTime;
        failModel.reStartTime = self.exitModel.reStartTime;
    }
    failModel.totalKM = self.mapCurrentKMLab.text;
    failModel.totalTime = [NSString stringWithFormat:@"%ld",(long)_totalTime];
    failModel.speed = self.currentSpeedLab.text;
    failModel.totalStep = self.currentStepLab.text;
    NSDictionary *dict = @{@"lat":[NSNumber numberWithDouble:_endAnnotation.coordinate.latitude],@"long":[NSNumber numberWithDouble:_endAnnotation.coordinate.longitude]};
    failModel.endCoordsDictStr = [dict mj_JSONString];
    
    failModel.pointsArrStr = self.pointsStr;
    failModel.startLoaction = self.sportsDetailModel.startLocation;
    failModel.endLocation = self.sportsDetailModel.endLocation;
    [[CNTrackLoaclDataManager shareManager] insertFUploadModel:failModel];

    [self.mapView addSubview:self.preSaveView];
    [self.preSaveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.mapView);
        make.height.equalTo(@(49+kVerticalBottomSafeHeight));
    }];
    [self.preSaveView addSubview:self.loadingSaveView];
    [self.loadingSaveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(24));
        make.centerY.equalTo(self.preSaveView).offset(-kVerticalBottomSafeHeight/2);
        make.centerX.equalTo(self.preSaveView).offset(-28);
    }];
    
    UILabel *lab = [[UILabel alloc] init];
    lab.text = @"保存中";
    lab.textAlignment = NSTextAlignmentLeft;
    lab.textColor = kWhiteColor;
    lab.font = [UIFont systemFontOfSize:18];
    [self.preSaveView addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.preSaveView).offset(-kVerticalBottomSafeHeight/2);
        make.left.equalTo(self.loadingSaveView.mas_right).offset(2);
    }];
    [self startAnimation];//转圈
    [self.mapView addSubview:self.saveBtn];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.mapView);
        make.height.equalTo(@(49+kVerticalBottomSafeHeight));
    }];
    self.saveBtn.titleEdgeInsets = UIEdgeInsetsMake(-kVerticalBottomSafeHeight, 0, 0, 0);
    self.saveBtn.hidden = YES;
    [self.mapView addSubview:self.tableView];
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor clearColor];
    headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 345);
    self.tableView.tableHeaderView = headerView;
    [headerView addSubview:self.backBtn];
    self.tableView.view = self.backBtn;
    [self.backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(headerView).offset(10);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.mapView);
        make.bottom.equalTo(self.mapView.mas_bottom).offset(-49-kVerticalBottomSafeHeight);
        make.top.equalTo(self.mapView);
    }];
    if (localFenceId) {
        //判断是否经过了终点
        [self queryLocalHistoryAlarm];
    }else{
        [self judgeSuccessTrack];
    }
    
}

#pragma mark -- 自己的历史轨迹
- (void)queryCurrentRunningEndPoint:(void(^)(NSArray *))handle{
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
    if ([self.exitModel.isStop isEqualToString:@"yes"]) {
        CNHistoryTrackParam * paramInfo =[[CNHistoryTrackParam alloc]init];
        [paramInfo setStartTime:[self.exitModel.startTime integerValue]];
        [paramInfo setEndTime:[self.exitModel.stopTime integerValue]];
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
            if (self.exitModel.reStartTime.length > 0 && ![self.exitModel.reStartTime isEqualToString:@"<null>"]) {
                CNHistoryTrackParam * paramInfo2 =[[CNHistoryTrackParam alloc]init];
                [paramInfo2 setStartTime:[self.exitModel.reStartTime integerValue]];
                [paramInfo2 setEndTime:self->_endRunningDate];
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
        [paramInfo setStartTime:[self.exitModel.startTime integerValue]];
        [paramInfo setEndTime:_endRunningDate];
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

//保存中转圈
- (void)startAnimation{
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
         weakSelf.loadingSaveView.transform = endAngle;
        } completion:^(BOOL finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            self->angle += 2;
            if (!self->_isStopAnimation) {
                [strongSelf startAnimation];
            }
    }];
}

- (void)saveBtnAction:(id)sender{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TrackServiceOperationResultNotification object:nil];

    if (_endTimer) {
        [_endTimer invalidate];
        _endTimer = nil;
    }
    if (_startRunningTimer) {
        [_startRunningTimer invalidate];
        _startRunningTimer = nil;
    }
    [CNTrackServiceManager defaultManager].isStartRecord = NO;
    if ([self.delegate respondsToSelector:@selector(backToFrontVC)]) {
        [self.delegate backToFrontVC];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)startCountdown:(void(^)(void))handle{
    [self.view addSubview:self.startCountdownView];
    [self.startCountdownView addSubview:self.startCountdownLab];
    self.startCountdownLab.center = self.startCountdownView.center;
    __block int  startIndex = 3;
    [UIView animateWithDuration:0.4 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.startCountdownLab.text = [NSString stringWithFormat:@"%d",startIndex];
        self.startCountdownLab.transform = CGAffineTransformScale(self.startCountdownLab.transform, 2,2);
    } completion:^(BOOL finished) {
        self.startCountdownLab.hidden = YES;
        self.startCountdownLab.transform = CGAffineTransformIdentity;
        startIndex --;//2
        [UIView animateWithDuration:0.4 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.startCountdownLab.hidden = NO;
            self.startCountdownLab.text = [NSString stringWithFormat:@"%d",startIndex];
            self.startCountdownLab.transform =CGAffineTransformScale(self.startCountdownLab.transform, 2,2);
        } completion:^(BOOL finished) {
            self.startCountdownLab.hidden = YES;
            self.startCountdownLab.transform =CGAffineTransformIdentity;
            startIndex --;//1
            [UIView animateWithDuration:0.4 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.startCountdownLab.hidden = NO;
                self.startCountdownLab.text = [NSString stringWithFormat:@"%d",startIndex];
                self.startCountdownLab.transform =CGAffineTransformScale(self.startCountdownLab.transform, 2,2);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.4 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [self.startCountdownView removeAllSubviews];
                    [self.startCountdownView removeFromSuperview];
                } completion:^(BOOL finished) {
                    if (handle) {
                        handle();
                    }
                }];
            }];
        }];
    }];
}
#pragma mark -- tableviewdelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_isEndRunning) {
        CGRect rect = [_headImg convertRect:_headImg.bounds toView:AppKeyWindow];
        self.tableView.receiverHeight = rect.origin.y;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellid = @"cellid";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jl-bg"]];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.backgroundColor = [UIColor clearColor];
        [cell addSubview:bgView];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    switch (indexPath.row) {
        case 0:
        {
            [self first:bgView cell:cell];
        }
            break;
        case 1:
        {
            [self second:bgView cell:cell];
        }
            break;
        case 2:
        {
            [self third:bgView cell:cell];
        }
            break;
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    switch (indexPath.row) {
        case 0:
            height = 250;
            break;
        case 1:
            height = 130;
            break;
        case 2:
            height = 260;
            break;
        default:
            break;
    }
    return height;
}

- (void)first:(UIImageView *)bgView cell:(UITableViewCell *)cell{
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(cell);
        make.top.equalTo(cell).offset(20);
    }];
    _headImg = [[UIImageView alloc] init];
    [_headImg sd_setImageWithURL:[NSURL URLWithString:CNUserShareModel.faceUrl] placeholderImage:[UIImage imageNamed:@"TOUXIANG"]];
    [cell addSubview:_headImg];
    [_headImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cell).offset(3);
        make.left.equalTo(bgView.mas_left).offset(25);
        make.width.height.equalTo(@(50));
    }];
    _headImg.layer.cornerRadius = 25;
    _headImg.layer.masksToBounds = YES;
    _headImg.layer.borderWidth = 2;
    _headImg.layer.borderColor = [UIColor whiteColor].CGColor;
    
    UILabel *headLab = [[UILabel alloc]init];
    headLab.text = CNUserShareModel.nickname;
    headLab.font = [UIFont systemFontOfSize:13];
    headLab.textAlignment = NSTextAlignmentLeft;
    headLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    [cell addSubview:headLab];
    [headLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_headImg.mas_right).offset(10);
        make.right.equalTo(bgView.mas_right).offset(-18);
        make.bottom.equalTo(self->_headImg.mas_bottom);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = KGrayLineColor;
    [bgView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_headImg.mas_left);
        make.right.equalTo(bgView.mas_right).offset(-25);
        make.centerY.equalTo(bgView).offset(7);
        make.height.equalTo(@(0.5));
    }];
    
    UILabel *timeLab = [[UILabel alloc] init];
    NSDate *date               = [NSDate dateWithTimeIntervalSince1970:_endRunningDate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSString *dateString       = [formatter stringFromDate: date];
    timeLab.text = dateString;
    timeLab.font = [UIFont systemFontOfSize:10];
    timeLab.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    timeLab.textAlignment = NSTextAlignmentLeft;
    [bgView addSubview:timeLab];
    [timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lineView);
        make.bottom.equalTo(lineView.mas_top).offset(-13);
    }];
    
    UILabel *addressLab = [[UILabel alloc] init];
    addressLab.text = self.sportsDetailModel.title;
    addressLab.font = [UIFont systemFontOfSize:15];
    addressLab.numberOfLines = 0;
    addressLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    addressLab.textAlignment = NSTextAlignmentLeft;
    [addressLab sizeToFit];
    [bgView addSubview:addressLab];
    [addressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lineView);
        make.bottom.equalTo(timeLab.mas_top).offset(-10);
        make.width.equalTo(@(SCREEN_WIDTH/2));
    }];
    
    UIView *tempView = [UIView new];
    [bgView addSubview:tempView];
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(addressLab.mas_top);
        make.bottom.equalTo(timeLab.mas_bottom);
        make.left.right.equalTo(bgView);
    }];
    
    UILabel *totalKMLab = [[UILabel alloc] init];
    NSDictionary *attributesNum = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:45]};
    NSDictionary *attributesKM = @{NSFontAttributeName:[UIFont systemFontOfSize:10]};
    NSAttributedString *attributedString = [self attributedText:@[self.mapCurrentKMLab.text,@" 公里"] attributeAttay:@[attributesNum,attributesKM]];
    totalKMLab.attributedText = attributedString;
    totalKMLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    totalKMLab.textAlignment = NSTextAlignmentRight;
    [bgView addSubview:totalKMLab];
    [totalKMLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tempView);
        make.right.equalTo(lineView.mas_right);
    }];
    UILabel *endSpeedLab = [[UILabel alloc] init];
    endSpeedLab.text = self.currentSpeedLab.text;
    endSpeedLab.font = [UIFont boldSystemFontOfSize:24];
    endSpeedLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    endSpeedLab.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:endSpeedLab];
    [endSpeedLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bgView).offset(-SCREEN_WIDTH/2/2);
        make.top.equalTo(lineView.mas_bottom).offset(12);
    }];
    
    
    UILabel *endSpeedNameLab = [[UILabel alloc] init];
    endSpeedNameLab.text = @"配速";
    endSpeedNameLab.font = [UIFont systemFontOfSize:15];
    endSpeedNameLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    endSpeedNameLab.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:endSpeedNameLab];
    [endSpeedNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(endSpeedLab);
        make.top.equalTo(endSpeedLab.mas_bottom).offset(12);
    }];
    
    UILabel *endTotalTimeLab = [[UILabel alloc] init];
    endTotalTimeLab.text = self.currentTimeLab.text;
    endTotalTimeLab.font = [UIFont boldSystemFontOfSize:24];
    endTotalTimeLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    endTotalTimeLab.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:endTotalTimeLab];
    [endTotalTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(endSpeedLab);
        make.centerX.equalTo(bgView).offset(SCREEN_WIDTH/2/2);
    }];
    
    UILabel *endTimeNameLab = [[UILabel alloc] init];
    endTimeNameLab.text = @"用时";
    endTimeNameLab.font = [UIFont systemFontOfSize:15];
    endTimeNameLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    endTimeNameLab.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:endTimeNameLab];
    [endTimeNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(endSpeedNameLab);
        make.centerX.equalTo(endTotalTimeLab);
    }];
}
- (void)second:(UIImageView *)bgView cell:(UITableViewCell *)cell{
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(cell);
    }];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sport-step record"]];
    [bgView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bgView).offset(25);
        make.top.equalTo(bgView).offset(15);
        make.size.mas_equalTo(CGSizeMake(16, 17));
    }];
    UILabel *stepNameLab = [[UILabel alloc] init];
    stepNameLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    stepNameLab.font = [UIFont systemFontOfSize:12];
    stepNameLab.text = @"总步数";
    stepNameLab.textAlignment = NSTextAlignmentLeft;
    [bgView addSubview:stepNameLab];
    [stepNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(10);
        make.bottom.equalTo(imgView.mas_bottom);
    }];
    
    UILabel *totalStepLab = [[UILabel alloc] init];
    NSDictionary *attributesNum = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:28],NSForegroundColorAttributeName:[UIColor colorWithRed:35/255.0 green:212/255.0 blue:30/255.0 alpha:1.0]};
    NSDictionary *attributesKM = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]};
    NSAttributedString *attributedString = [self attributedText:@[self.currentStepLab.text,@" 步"] attributeAttay:@[attributesNum,attributesKM]];
    totalStepLab.attributedText = attributedString;
    totalStepLab.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:totalStepLab];
    [totalStepLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(bgView);
    }];
}

- (void)third:(UIImageView *)bgView cell:(UITableViewCell *)cell{
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(cell);
    }];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sport-route"]];
    [bgView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bgView).offset(25);
        make.top.equalTo(bgView).offset(25);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    UILabel *stepNameLab = [[UILabel alloc] init];
    stepNameLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    stepNameLab.font = [UIFont systemFontOfSize:12];
    stepNameLab.text = @"跑步路线";
    stepNameLab.textAlignment = NSTextAlignmentLeft;
    [bgView addSubview:stepNameLab];
    [stepNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(10);
        make.bottom.equalTo(imgView.mas_bottom);
    }];
    
    UIView *green = [[UIView alloc] init];
    green.backgroundColor = [UIColor greenColor];
    [bgView addSubview:green];
    [green mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView);
        make.top.equalTo(imgView.mas_bottom).offset(19);
        make.width.height.equalTo(@(6));
    }];
    green.layer.cornerRadius = 3;
    green.layer.masksToBounds = YES;
    
    UILabel *qiLab = [[UILabel alloc] init];
    qiLab.text = @"(起)";
    qiLab.textAlignment = NSTextAlignmentCenter;
    qiLab.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    qiLab.font = [UIFont systemFontOfSize:12];
    [bgView addSubview:qiLab];
    [qiLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(green);
        make.left.equalTo(green.mas_right).offset(9);
    }];
    UILabel *qiADDLab = [[UILabel alloc] init];
    qiADDLab.text = self.sportsDetailModel.startLocation;
    qiADDLab.textAlignment = NSTextAlignmentLeft;
    qiADDLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    qiADDLab.font = [UIFont systemFontOfSize:14];
    [bgView addSubview:qiADDLab];
    [qiADDLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(green);
        make.left.equalTo(qiLab.mas_right).offset(9);
    }];
    UIView *line1 = [[UIView alloc] init];
    line1.backgroundColor = [UIColor colorWithRed:196/255.0 green:196/255.0 blue:196/255.0 alpha:1.0];
    [bgView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(green);
        make.top.equalTo(green.mas_bottom).offset(3);
        make.height.equalTo(@(25));
        make.width.equalTo(@(1));
    }];
    
    UIView *red = [[UIView alloc] init];
    red.backgroundColor = [UIColor colorWithRed:250/255.0 green:82/255.0 blue:52/255.0 alpha:1.0];
    [bgView addSubview:red];
    [red mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(green);
        make.top.equalTo(line1.mas_bottom).offset(3);
        make.width.height.equalTo(@(6));
    }];
    red.layer.cornerRadius = 3;
    red.layer.masksToBounds = YES;
    UILabel *zhiLab = [[UILabel alloc] init];
    zhiLab.text = @"(止)";
    zhiLab.textAlignment = NSTextAlignmentCenter;
    zhiLab.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    zhiLab.font = [UIFont systemFontOfSize:12];
    [bgView addSubview:zhiLab];
    [zhiLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(red);
        make.centerX.equalTo(qiLab);
    }];
    UILabel *zhiADDLab = [[UILabel alloc] init];
    zhiADDLab.text = self.sportsDetailModel.endLocation;
    zhiADDLab.textAlignment = NSTextAlignmentLeft;
    zhiADDLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    zhiADDLab.font = [UIFont systemFontOfSize:14];
    [bgView addSubview:zhiADDLab];
    [zhiADDLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(red);
        make.left.equalTo(qiADDLab);
    }];
    UIView *line2 = [[UIView alloc] init];
    line2.backgroundColor = [UIColor colorWithRed:196/255.0 green:196/255.0 blue:196/255.0 alpha:1.0];
    [bgView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(green);
        make.top.equalTo(red.mas_bottom).offset(3);
        make.height.equalTo(@(25));
        make.width.equalTo(@(1));
    }];
    
    UIView *gray1 = [[UIView alloc] init];
    gray1.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    [bgView addSubview:gray1];
    [gray1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(green);
        make.top.equalTo(line2.mas_bottom).offset(3);
        make.width.height.equalTo(@(4));
    }];
    gray1.layer.cornerRadius = 2;
    gray1.layer.masksToBounds = YES;
    UILabel *timeLab = [[UILabel alloc] init];
    timeLab.text = self.currentTimeLab.text;
    timeLab.textAlignment = NSTextAlignmentLeft;
    timeLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    timeLab.font = [UIFont boldSystemFontOfSize:18];
    [bgView addSubview:timeLab];
    [timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(gray1);
        make.left.equalTo(qiLab);
    }];
    UILabel *timeNameLab = [[UILabel alloc] init];
    timeNameLab.text = @"跑步记录时长";
    timeNameLab.textAlignment = NSTextAlignmentLeft;
    timeNameLab.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    timeNameLab.font = [UIFont systemFontOfSize:11];
    [bgView addSubview:timeNameLab];
    [timeNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(qiLab);
        make.top.equalTo(timeLab.mas_bottom).offset(6);
    }];
    UIView *line3 = [[UIView alloc] init];
    line3.backgroundColor = [UIColor colorWithRed:196/255.0 green:196/255.0 blue:196/255.0 alpha:1.0];
    [bgView addSubview:line3];
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(green);
        make.top.equalTo(gray1.mas_bottom).offset(3);
        make.height.equalTo(@(55));
        make.width.equalTo(@(1));
    }];
    UIView *gray2 = [[UIView alloc] init];
    gray2.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    [bgView addSubview:gray2];
    [gray2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(green);
        make.top.equalTo(line3.mas_bottom).offset(3);
        make.width.height.equalTo(@(4));
    }];
    gray2.layer.cornerRadius = 2;
    gray2.layer.masksToBounds = YES;
    self.successStateLab = [[UILabel alloc] init];
    self.successStateLab.text = _endStatus.length>0?_endStatus:@"路线未完成";
    self.successStateLab.textAlignment = NSTextAlignmentLeft;
    self.successStateLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    self.successStateLab.font = [UIFont systemFontOfSize:11];
    [bgView addSubview:self.successStateLab];
    [self.successStateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(gray2);
        make.left.equalTo(qiLab);
    }];
}
#pragma mark -- lazy
-(UIView *)startCountdownView{
    if (!_startCountdownView) {
        _startCountdownView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _startCountdownView.backgroundColor = [UIColor colorWithRed:91/255.0 green:196/255.0 blue:164/255.0 alpha:1.0];
    }
    return _startCountdownView;
}

- (UILabel *)startCountdownLab{
    if (!_startCountdownLab) {
        _startCountdownLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 150)];
        _startCountdownLab.textColor = [UIColor whiteColor];
        _startCountdownLab.font = [UIFont boldSystemFontOfSize:110];
        _startCountdownLab.textAlignment = NSTextAlignmentCenter;
    }
    return _startCountdownLab;
}

-(QMUIButton *)backFirstBtn{
    if(!_backFirstBtn){
        _backFirstBtn = [[QMUIButton alloc] init];
//        [_backFirstBtn setBackgroundImage:[UIImage imageNamed:@"top_back_white"] forState:UIControlStateNormal];
//        [_backFirstBtn setImage:[UIImage imageNamed:@"top_back"] forState:UIControlStateNormal];
//        _backFirstBtn.imageEdgeInsets = UIEdgeInsetsMake(-5, -3, 0, 0);
        [_backFirstBtn addTarget:self action:@selector(backFirstBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backFirstBtn;
}

-(UILabel *)currentKMLab{
    if (!_currentKMLab) {
        _currentKMLab = [[UILabel alloc] init];
        _currentKMLab.font = [UIFont boldSystemFontOfSize:70];
        _currentKMLab.textColor = kWhiteColor;
        _currentKMLab.text = @"0.00";
        _currentKMLab.textAlignment = NSTextAlignmentCenter;
    }
    return _currentKMLab;
}

-(UILabel *)gpsLab{
    if (!_gpsLab) {
        _gpsLab = [[UILabel alloc] init];
        _gpsLab.font = [UIFont boldSystemFontOfSize:18];
        _gpsLab.text = @"GPS";
        _gpsLab.textColor = kWhiteColor;
        _gpsLab.textAlignment = NSTextAlignmentCenter;
    }
    return _gpsLab;
}
-(UIImageView *)currentGPSImgView{
    if (!_currentGPSImgView) {
        _currentGPSImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signal-low"]];
    }
    return _currentGPSImgView;
}
-(UILabel *)currentGPSLab{
    if (!_currentGPSLab) {
        _currentGPSLab = [[UILabel alloc] init];
        _currentGPSLab.font = [UIFont systemFontOfSize:10];
        _currentGPSLab.text = @"信号槽糕，数据准确度低";
        _currentGPSLab.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        _currentGPSLab.textAlignment = NSTextAlignmentLeft;

    }
    return _currentGPSLab;
}
-(UIButton *)detailMapBtn{
    if (!_detailMapBtn) {
        _detailMapBtn = [[UIButton alloc] init];
        [_detailMapBtn setImage:[UIImage imageNamed:@"startRunning_map"] forState:UIControlStateNormal];
        [_detailMapBtn addTarget:self action:@selector(showMapView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _detailMapBtn;
}
-(UILabel *)mapDesLab{
    if (!_mapDesLab) {
        _mapDesLab = [[UILabel alloc] init];
        _mapDesLab.font = [UIFont systemFontOfSize:10];
        _mapDesLab.text = @"点击查看轨迹";
        _mapDesLab.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        _mapDesLab.textAlignment = NSTextAlignmentCenter;
    }
    return _mapDesLab;
}
-(UIImageView *)speedImgView{
    if (!_speedImgView) {
        _speedImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sport-speed"]];
    }
    return _speedImgView;
}
-(UILabel *)currentSpeedLab{
    if (!_currentSpeedLab) {
        _currentSpeedLab = [[UILabel alloc] init];
        _currentSpeedLab.font = [UIFont systemFontOfSize:24];
        _currentSpeedLab.textColor = kWhiteColor;
        _currentSpeedLab.text = @"--";
        _currentSpeedLab.textAlignment = NSTextAlignmentCenter;
    }
    return _currentSpeedLab;
}
-(UILabel *)speedDesLab{
    if (!_speedDesLab) {
        _speedDesLab = [[UILabel alloc] init];
        _speedDesLab.font = [UIFont systemFontOfSize:15];
        _speedDesLab.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        _speedDesLab.text = @"配速";
        _speedDesLab.textAlignment = NSTextAlignmentCenter;
    }
    return _speedDesLab;
}
-(UIImageView *)timeImgView{
    if (!_timeImgView) {
        _timeImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sport-time cost"]];
    }
    return _timeImgView;
}
-(UILabel *)currentTimeLab{
    if (!_currentTimeLab) {
        _currentTimeLab = [[UILabel alloc] init];
        _currentTimeLab.font = [UIFont systemFontOfSize:24];
        _currentTimeLab.textColor = kWhiteColor;
        _currentTimeLab.text = @"00:00:00";
        _currentTimeLab.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLab;
}
-(UILabel *)timeDesLab{
    if (!_timeDesLab) {
        _timeDesLab = [[UILabel alloc] init];
        _timeDesLab.font = [UIFont systemFontOfSize:15];
        _timeDesLab.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        _timeDesLab.text = @"用时";
        _timeDesLab.textAlignment = NSTextAlignmentCenter;
    }
    return _timeDesLab;
}
-(UIImageView *)stepImgView{
    if (!_stepImgView) {
        _stepImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sport-step"]];
    }
    return _stepImgView;
}
-(UILabel *)currentStepLab{
    if (!_currentStepLab) {
        _currentStepLab = [[UILabel alloc] init];
        _currentStepLab.font = [UIFont systemFontOfSize:24];
        _currentStepLab.textColor = kWhiteColor;
        _currentStepLab.text = @"--";
        _currentStepLab.textAlignment = NSTextAlignmentCenter;
    }
    return _currentStepLab;
}
-(UILabel *)stepDesLab{
    if (!_stepDesLab) {
        _stepDesLab = [[UILabel alloc] init];
        _stepDesLab.font = [UIFont systemFontOfSize:15];
        _stepDesLab.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        _stepDesLab.text = @"步";
        _stepDesLab.textAlignment = NSTextAlignmentCenter;
    }
    return _stepDesLab;
}
-(QMUIButton *)stopRunningBtn{
    if (!_stopRunningBtn) {
        _stopRunningBtn = [[QMUIButton alloc] init];
        _stopRunningBtn.imagePosition = QMUIButtonImagePositionTop;
        _stopRunningBtn.spacingBetweenImageAndTitle = 8;
        [_stopRunningBtn setBackgroundImage:[UIImage imageWithColor:kWhiteColor] forState:UIControlStateNormal];
        [_stopRunningBtn setImage:[UIImage imageNamed:@"pbjs-time out"] forState:UIControlStateNormal];
        [_stopRunningBtn setTitle:@"暂停" forState:UIControlStateNormal];
        [_stopRunningBtn setTitleColor:kBlackColor forState:UIControlStateNormal];
        _stopRunningBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_stopRunningBtn addTarget:self action:@selector(stopRunningBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopRunningBtn;
}

-(QMUIButton *)goonRunningBtn{
    if (!_goonRunningBtn) {
        _goonRunningBtn = [[QMUIButton alloc] init];
        _goonRunningBtn.imagePosition = QMUIButtonImagePositionTop;
        _goonRunningBtn.spacingBetweenImageAndTitle = 8;
        [_goonRunningBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:91/255.0 green:196/255.0 blue:164/255.0 alpha:1.0]] forState:UIControlStateNormal];
        [_goonRunningBtn setImage:[UIImage imageNamed:@"pbjs-play"] forState:UIControlStateNormal];
        [_goonRunningBtn setTitle:@"继续" forState:UIControlStateNormal];
        [_goonRunningBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
        _goonRunningBtn.titleLabel.font = [UIFont systemFontOfSize:13];

        [_goonRunningBtn addTarget:self action:@selector(goonRunningBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goonRunningBtn;
}

-(UIView *)endRunningBgView{
    if (!_endRunningBgView) {
        _endRunningBgView = [[UIView alloc] init];
        _endRunningBgView.backgroundColor = [UIColor colorWithRed:250/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
    }
    return _endRunningBgView;
}

-(QMUIButton *)endRunningBtn{
    if (!_endRunningBtn) {
        _endRunningBtn = [[QMUIButton alloc] init];
        _endRunningBtn.imagePosition = QMUIButtonImagePositionTop;
        _endRunningBtn.spacingBetweenImageAndTitle = 8;
        [_endRunningBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:250/255.0 green:112/255.0 blue:112/255.0 alpha:1.0]] forState:UIControlStateNormal];
        [_endRunningBtn setImage:[UIImage imageNamed:@"pbjs-finish"] forState:UIControlStateNormal];
        [_endRunningBtn setTitle:@"结束" forState:UIControlStateNormal];
        _endRunningBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_endRunningBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
        [_endRunningBtn addTarget:self action:@selector(endRunningBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _endRunningBtn;
}

-(UILongPressGestureRecognizer *)longPress{
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    }
    return _longPress;
}

- (UIImageView *)endTipView{
    if (!_endTipView) {
        _endTipView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"press finish"]];
    }
    return _endTipView;
}

-(UILabel *)endTipLab{
    if (!_endTipLab) {
        _endTipLab = [[UILabel alloc] init];
        _endTipLab.text = @"长按结束";
        _endTipLab.textAlignment = NSTextAlignmentCenter;
        _endTipLab.textColor = kBlackColor;
        _endTipLab.font = [UIFont systemFontOfSize:12];
    }
    return _endTipLab;
}

-(BMKMapView *)mapView{
    if (!_mapView) {
        _mapView = [[BMKMapView alloc] init];
        _mapView.frame =CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _mapView.delegate = self;
        _mapView.zoomLevel = 19;//缩放等级4-21
        _mapView.showMapScaleBar = NO;//显示比例尺
        _mapView.showsUserLocation = YES;//显示定位图层
        //        //显示我的位置，我的位置图标和地图都不会旋转
        _mapView.userTrackingMode = BMKUserTrackingModeHeading;
        //        //更换我的位置图标
        //        // self.mapView是BMKMapView对象
        BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
        //        //定位图标名称，需要将该图片放到 mapapi.bundle/images 目录下
        //        //        param.locationViewImgName = @"icon_nav_bus";
        //        //用户自定义定位图标，V4.2.1以后支持
        param.locationViewImage = [UIImage imageNamed:@"map_dw"];
        //根据配置参数更新定位图层样式
        //设置显示精度圈，默认YES
        param.isAccuracyCircleShow = NO;
        //精度圈 边框颜色
//        param.accuracyCircleStrokeColor = kWhiteColor;
//        //精度圈 填充颜色
//        param.accuracyCircleFillColor = kWhiteColor;
        [_mapView updateLocationViewWithParam:param];
    }
    return _mapView;
}

-(QMUIButton *)backBtn{
    if(!_backBtn){
        _backBtn = [[QMUIButton alloc] init];
        [_backBtn setBackgroundImage:[UIImage imageNamed:@"back-bg"] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"top_back"] forState:UIControlStateNormal];
        _backBtn.imageEdgeInsets = UIEdgeInsetsMake(-5, -3, 0, 0);
        [_backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (QMUIButton *)GPSBtn{
    if(!_GPSBtn){
        _GPSBtn = [[QMUIButton alloc] init];
        [_GPSBtn setBackgroundImage:[UIImage imageNamed:@"gps-bg"] forState:UIControlStateNormal];
        [_GPSBtn setTitle:@"GPS  " forState:UIControlStateNormal];
        [_GPSBtn setTitleColor:kBlackColor forState:UIControlStateNormal];
        _GPSBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [_GPSBtn setImage:[UIImage imageNamed:@"signal-low"] forState:UIControlStateNormal];
        _GPSBtn.imagePosition = QMUIButtonImagePositionRight;
        _GPSBtn.imageEdgeInsets = UIEdgeInsetsMake(-3, 0, 0, 0);
        _GPSBtn.titleEdgeInsets = UIEdgeInsetsMake(-3, 0, 0, 0);
    }
    return _GPSBtn;
}

- (QMUIButton *)tipGPSBtn{
    if(!_tipGPSBtn){
        _tipGPSBtn = [[QMUIButton alloc] init];
        [_tipGPSBtn setBackgroundImage:[UIImage imageNamed:@"map-signal-tx"] forState:UIControlStateNormal];
        [_tipGPSBtn setTitle:@"信号糟糕，数据准确度低" forState:UIControlStateNormal];
        [_tipGPSBtn setTitleColor:kBlackColor forState:UIControlStateNormal];
        _tipGPSBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        _tipGPSBtn.titleEdgeInsets = UIEdgeInsetsMake(-1, 0, 0, 0);
    }
    return _tipGPSBtn;
}
-(BMKLocationManager *)locationManager{
    if (!_locationManager) {
        //初始化实例
        _locationManager = [[BMKLocationManager alloc] init];
        //设置delegate
        _locationManager.delegate = self;
        //设置返回位置的坐标系类型
        _locationManager.coordinateType = BMKLocationCoordinateTypeGCJ02;
        //设置距离过滤参数：10米
        _locationManager.distanceFilter = 1.0f;
        //设置预期精度参数：10米
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设置应用位置类型：步行、骑行等
        _locationManager.activityType = CLActivityTypeFitness;
        //设置是否自动停止位置更新
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        //设置是否允许后台定位
        _locationManager.allowsBackgroundLocationUpdates = YES;
        //设置位置获取超时时间
//        _locationManager.locationTimeout = 10;
        //设置获取地址信息超时时间
        //        _locationManager.reGeocodeTimeout = 3;
    }
    return _locationManager;
}

- (BMKUserLocation *)userLocation{
    if (!_userLocation) {
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}

-(QMUIButton *)resetBtn{
    if(!_resetBtn){
        _resetBtn = [[QMUIButton alloc] init];
        [_resetBtn setBackgroundImage:[UIImage imageNamed:@"back-bg"] forState:UIControlStateNormal];
        [_resetBtn setImage:[UIImage imageNamed:@"map_location"] forState:UIControlStateNormal];
        _resetBtn.imageEdgeInsets = UIEdgeInsetsMake(-4.5, -0.5, 0, 0);
        [_resetBtn addTarget:self action:@selector(resetBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}

-(UIImageView *)mapBottomView{
    if (!_mapBottomView) {
        _mapBottomView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jl-bg"]];
    }
    return _mapBottomView;
}
-(UILabel *)mapCurrentSpeedLab{
    if (!_mapCurrentSpeedLab) {
        _mapCurrentSpeedLab = [[UILabel alloc] init];
        _mapCurrentSpeedLab.text = @"--";
        _mapCurrentSpeedLab.font = [UIFont boldSystemFontOfSize:24];
        _mapCurrentSpeedLab.textColor = kBlackColor;
        _mapCurrentSpeedLab.textAlignment = NSTextAlignmentCenter;
    }
    return _mapCurrentSpeedLab;
}
-(UILabel *)mapSpeedLab{
    if (!_mapSpeedLab) {
        _mapSpeedLab = [[UILabel alloc] init];
        _mapSpeedLab.text = @"配速";
        _mapSpeedLab.font = [UIFont systemFontOfSize:15];
        _mapSpeedLab.textColor = kBlackColor;
        _mapSpeedLab.textAlignment = NSTextAlignmentCenter;
    }
    return _mapSpeedLab;
}
-(UILabel *)mapCurrentTimeLab{
    if (!_mapCurrentTimeLab) {
        _mapCurrentTimeLab = [[UILabel alloc] init];
        _mapCurrentTimeLab.text = @"00:00:00";
        _mapCurrentTimeLab.font = [UIFont boldSystemFontOfSize:24];
        _mapCurrentTimeLab.textColor = kBlackColor;
        _mapCurrentTimeLab.textAlignment = NSTextAlignmentCenter;
    }
    return _mapCurrentTimeLab;
}
-(UILabel *)mapTimeLab{
    if (!_mapTimeLab) {
        _mapTimeLab = [[UILabel alloc] init];
        _mapTimeLab.text = @"用时";
        _mapTimeLab.font = [UIFont systemFontOfSize:15];
        _mapTimeLab.textColor = kBlackColor;
        _mapTimeLab.textAlignment = NSTextAlignmentCenter;
    }
    return _mapTimeLab;
}

-(UIView *)fristBgView{
    if (!_fristBgView) {
        _fristBgView = [[UIView alloc] init];
        _fristBgView.backgroundColor = kBlackColor;
    }
    return _fristBgView;
}
-(UILabel *)mapCurrentKMLab{
    if (!_mapCurrentKMLab) {
        _mapCurrentKMLab = [[UILabel alloc] init];
        _mapCurrentKMLab.text = @"0.00";
        _mapCurrentKMLab.font = [UIFont boldSystemFontOfSize:24];
        _mapCurrentKMLab.textColor = kBlackColor;
        _mapCurrentKMLab.textAlignment = NSTextAlignmentCenter;
    }
    return _mapCurrentKMLab;
}
-(UILabel *)mapKMLab{
    if (!_mapKMLab) {
        _mapKMLab = [[UILabel alloc] init];
        _mapKMLab.text = @"距离(km)";
        _mapKMLab.font = [UIFont systemFontOfSize:15];
        _mapKMLab.textColor = kBlackColor;
        _mapKMLab.textAlignment = NSTextAlignmentCenter;
    }
    return _mapKMLab;
}

-(CNTrackTableView *)tableView{
    if (!_tableView) {
        _tableView = [[CNTrackTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.receiverHeight = 345;
//        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableView.separatorColor = [UIColor clearColor];
        _tableView.showsVerticalScrollIndicator = NO;

    }
    return _tableView;
}
-(UIView *)preSaveView{
    if (!_preSaveView) {
        _preSaveView = [[UIView alloc] init];
        _preSaveView.backgroundColor = RGBOF(0x5BC4A4);
    }
    return _preSaveView;
}
-(UIImageView *)loadingSaveView{
    if (!_loadingSaveView) {
        _loadingSaveView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"track_loading"]];
    }
    return _loadingSaveView;
}
-(UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = [[UIButton alloc] init];
        [_saveBtn setTitle:@"完成" forState:UIControlStateNormal];
        _saveBtn.backgroundColor = RGBOF(0x5BC4A4);
        _saveBtn.userInteractionEnabled = YES;
        _saveBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_saveBtn addTarget:self action:@selector(saveBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}
-(NSMutableArray *)locationPoints{
    if (!_locationPoints) {
        _locationPoints = [NSMutableArray arrayWithCapacity:0];
    }
    return _locationPoints;
}
@end
