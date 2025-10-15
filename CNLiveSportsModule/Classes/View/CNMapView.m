//
//  CNMapView.m
//  CNLiveNetAdd
//
//  Created by open on 2019/6/4.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import "CNMapView.h"
#import "CNHistoryTrackPoint.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

@interface BMKSportNode : NSObject
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) CGFloat speed;
@end
@implementation BMKSportNode

@end

@interface CNMapView()
<
BMKMapViewDelegate,
BMKLocationManagerDelegate
>
@property (nonatomic, strong) NSMutableArray            *sportNodes;
@property (nonatomic, assign) NSUInteger                sportNodeNum;
@property (nonatomic, strong) BMKPolyline               *pathPolyLine; //当前界面的多边形（运动轨迹）

@property (nonatomic, strong) BMKPointAnnotation        *startAnnotation; //当前界面的标注
@property (nonatomic, strong) BMKPointAnnotation        *endAnnotation; //当前界面的标注

@property (nonatomic, assign) CLLocationCoordinate2D    mineLocationCoordinate;
@property (nonatomic, assign) BOOL                      isLocation;//定位是否成功

@property (nonatomic, strong) UIButton                  *resetBtn; //重新定位按钮
@property (nonatomic, strong) NSMutableArray            *minePoints;
@property (nonatomic, strong) BMKPolyline               *fminePolyLine;
@property (nonatomic, strong) BMKPolyline               *lminePolyLine;

@end
@implementation CNMapView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _sportNodes = [NSMutableArray array];
        _minePoints = [NSMutableArray array];
        [self addSubview:self.mapView];
        CGPoint p = self.mapView.compassPosition;
        p.y += 100;
        self.mapView.compassPosition = p;
        [self.mapView addSubview:self.resetBtn];
        [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mapView.mas_left).offset(15);
            make.bottom.equalTo(self.mapView.mas_bottom).offset(-50);
        }];
    }
    return self;
}

-(void)setDataJsonARR:(NSArray *)dataJsonARR{
    _dataJsonARR = dataJsonARR;
    [_sportNodes removeAllObjects];
    for (CNHistoryTrackPoint *point in dataJsonARR) {
        BMKSportNode *sportNode = [[BMKSportNode alloc] init];
        sportNode.coordinate  = point.coordinate;//CLLocationCoordinate2DMake([dictionary[@"lat"] doubleValue], [dictionary[@"lon"] doubleValue]);
        [_sportNodes addObject:sportNode];
    }
    _sportNodeNum = _sportNodes.count;
    [self start];//添加路线
}

-(void)drawLine:(BOOL)isStop fArr:(NSArray *)arr1 lArr:(NSArray *)arr2{
//    for (CNHistoryTrackPoint *point in points) {
    [_minePoints addObjectsFromArray:arr1];
    [_minePoints addObjectsFromArray:arr2];
    if (isStop) {
        CLLocationCoordinate2D paths1[arr1.count];
        for (NSUInteger i = 0; i < arr1.count; i ++) {
            CNHistoryTrackPoint *point = arr1[i];
            paths1[i] = point.coordinate;
        }
        _fminePolyLine = [BMKPolyline polylineWithCoordinates:paths1 count:arr1.count];
        //初始化标注类BMKPointAnnotation的实例
        _startAnnotation = [[BMKPointAnnotation alloc] init];
        //设置标注的经纬度坐标
        _startAnnotation.coordinate = paths1[0];
        //    [self.mapView setCenterCoordinate:paths[0] animated:YES];
        //设置标注的标题
        _startAnnotation.title = @"起点";
        //初始化标注类BMKPointAnnotation的实例
        _endAnnotation = [[BMKPointAnnotation alloc] init];
        if (arr2.count > 0) {
            CLLocationCoordinate2D paths2[arr2.count];
            for (NSUInteger i = 0; i < arr2.count; i ++) {
                CNHistoryTrackPoint *point = arr2[i];
                paths2[i] = point.coordinate;
            }
            _lminePolyLine = [BMKPolyline polylineWithCoordinates:paths2 count:arr2.count];
            //设置标注的经纬度坐标
            _endAnnotation.coordinate = paths2[arr2.count-1];
            //设置标注的标题
            _endAnnotation.title = @"终点";
            
        }else{
            //设置标注的经纬度坐标
            _endAnnotation.coordinate = paths1[arr1.count-1];
            //设置标注的标题
            _endAnnotation.title = @"终点";
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            [self->_mapView addOverlay:self->_fminePolyLine];
            [self->_mapView addOverlay:self->_lminePolyLine];
            //将标注添加到当前地图View中
            [self->_mapView addAnnotation:self->_startAnnotation];
            //将标注添加到当前地图View中
            [self->_mapView addAnnotation:self->_endAnnotation];
            [self mapViewFitPoints:self.minePoints];
        });
    }
}

#pragma mark - private
- (void)start{
    CLLocationCoordinate2D paths[_sportNodeNum];
    for (NSUInteger i = 0; i < _sportNodeNum; i ++) {
        BMKSportNode *node = _sportNodes[i];
        paths[i] = node.coordinate;
    }
    _pathPolyLine = [BMKPolyline polylineWithCoordinates:paths count:_sportNodeNum];
    //初始化标注类BMKPointAnnotation的实例
    _startAnnotation = [[BMKPointAnnotation alloc] init];
    //设置标注的经纬度坐标
    _startAnnotation.coordinate = paths[0];
//    [self.mapView setCenterCoordinate:paths[0] animated:YES];
    //设置标注的标题
    _startAnnotation.title = @"起点";
        //初始化标注类BMKPointAnnotation的实例
    _endAnnotation = [[BMKPointAnnotation alloc] init];
    //设置标注的经纬度坐标
    _endAnnotation.coordinate = paths[_sportNodeNum-1];
    //设置标注的标题
    _endAnnotation.title = @"终点";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        /**
         向地图View添加Overlay，需要实现BMKMapViewDelegate的-mapView:viewForOverlay:
         方法来生成标注对应的View
         
         @param overlay 要添加的overlay
         */
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self->_mapView addOverlay:self->_pathPolyLine];
        //将标注添加到当前地图View中
        [self->_mapView addAnnotation:self->_startAnnotation];
        //将标注添加到当前地图View中
        [self->_mapView addAnnotation:self->_endAnnotation];
        [self mapViewFitPolyLine:self->_pathPolyLine];
    });
}

- (void)mapViewFitPoints:(NSArray *) points {
    CGFloat leftTopX, leftTopY, rightBottomX, rightBottomY;
    if (points.count < 1) {
        return;
    }
    CNHistoryTrackPoint *p = points[0];
    CLLocationCoordinate2D coor = p.coordinate;
    BMKMapPoint pt = BMKMapPointForCoordinate(coor);
    //    BMKMapPoint pt = polyLine.points[0];
    // 左上角顶点
    leftTopX = pt.x;
    leftTopY = pt.y;
    // 右下角顶点
    rightBottomX = pt.x;
    rightBottomY = pt.y;
    for (int i = 1; i < points.count; i++) {
        CNHistoryTrackPoint *p = points[i];
        CLLocationCoordinate2D coor = p.coordinate;
        BMKMapPoint pt = BMKMapPointForCoordinate(coor);
        //        BMKMapPoint pt = polyLine.points[i];
        leftTopX = pt.x < leftTopX ? pt.x : leftTopX;
        leftTopY = pt.y < leftTopY ? pt.y : leftTopY;
        rightBottomX = pt.x > rightBottomX ? pt.x : rightBottomX;
        rightBottomY = pt.y > rightBottomY ? pt.y : rightBottomY;
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(leftTopX, leftTopY);
    rect.size = BMKMapSizeMake(rightBottomX - leftTopX, rightBottomY - leftTopY);
    UIEdgeInsets padding = UIEdgeInsetsMake(100 , 50, 200, 50);
    [_mapView fitVisibleMapRect:rect edgePadding:padding withAnimated:YES];
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
    UIEdgeInsets padding = UIEdgeInsetsMake(kNavigationBarHeight+50 , 50, self.originH+50, 50);
    [_mapView fitVisibleMapRect:rect edgePadding:padding withAnimated:YES];

}

-(void)setTempHeight:(float)tempHeight{
    _tempHeight = tempHeight;
    if (self.pathPolyLine) {
//        [self mapViewFitPolyLine:self.pathPolyLine];
        [self mapViewFitPolyLine:self.pathPolyLine height:tempHeight];
    }
}

-(void)setHiddenSubView:(BOOL)hiddenSubView{
    _hiddenSubView = hiddenSubView;
    if (hiddenSubView) {
        self.resetBtn.hidden = YES;
    }
}

//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine height:(float)height{
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
    rect.size = BMKMapSizeMake(rightBottomX - leftTopX,rightBottomY - leftTopY);
    UIEdgeInsets padding = UIEdgeInsetsMake(kNavigationBarHeight+20, 50, SCREEN_HEIGHT-height+20, 50);
    [_mapView fitVisibleMapRect:rect edgePadding:padding withAnimated:YES];
}

-(void)setNoNeedLocation:(BOOL)noNeedLocation{
    _noNeedLocation = noNeedLocation;
    @try {
        [self.locationManager stopUpdatingHeading];
        [self.locationManager stopUpdatingLocation];
    } @catch (NSException *exception) {
        NSLog(@"CNMapView.m 1111111111崩溃了");
    }
}
#pragma mark -- 定位delegate
//权限改变
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusDenied) {
        MJWeakSelf
        QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            if ([weakSelf.delegate respondsToSelector:@selector(quiteVC)]) {
                [weakSelf.delegate quiteVC];
            }
        }];
        QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"" message:@"无法获取你的位置信息。\n 请到手机系统的[隐私]->[定位服务]中打开定位服务，并允许网家家使用定位服务" preferredStyle:QMUIAlertControllerStyleAlert];
        [alertController addAction:action1];
        [alertController showWithAnimated:YES];
    }
}

- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager doRequestAlwaysAuthorization:(CLLocationManager * _Nonnull)locationManager{
    [locationManager requestAlwaysAuthorization];
}

- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    NSLog(@"定位失败");
    self.isLocation = NO;
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
        self.isLocation = NO;
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
        //        [QMUITips showInfo:@"位置更新失败" inView:self.view hideAfterDelay:0.5];
    }else{
        self.mineLocationCoordinate = location.location.coordinate;
        self.isLocation = YES;
    }
    if (!location) {
        return;
    }
    //    [QMUITips showInfo:@"位置更新" inView:self.view hideAfterDelay:0.5];
    if (self.noNeedLocation) {
        return;
    }
    self.userLocation.location = location.location;
    [self.mapView updateLocationData:self.userLocation];//动态更新我的位置数据
}

#pragma mark - 地图Delegate
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
//    [self start];//添加路线
    if (self.noNeedLocation) {
        return;
    }
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
}
/**
 根据overlay生成对应的BMKOverlayView
 
 @param mapView 地图View
 @param overlay 指定的overlay
 @return 生成的覆盖物View
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithPolyline:overlay];
        polylineView.lineWidth = 2;
        polylineView.strokeColor = [RGBOF(0x5BC4A4) colorWithAlphaComponent:1];
        return polylineView;
    }
    return nil;
}
/**
 根据anntation生成对应的annotationView
 
 @param mapView 地图View
 @param annotation 指定的标注
 @return 生成的标注View
 */

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        
        NSString *AnnotationViewID = @"baiduAnnotation";
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
    }
    return nil;
}

#pragma mark - lazy
-(BMKMapView *)mapView{
    if (!_mapView) {
        _mapView = [[BMKMapView alloc] initWithFrame:self.frame];
        _mapView.delegate = self;
        //设置地图比例尺级别
        _mapView.zoomLevel = 17;
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
        //        //根据配置参数更新定位图层样式
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
-(BMKLocationManager *)locationManager{
    if (!_locationManager) {
        //初始化实例
        _locationManager = [[BMKLocationManager alloc] init];
        //设置delegate
        _locationManager.delegate = self;
        //设置返回位置的坐标系类型
        _locationManager.coordinateType = BMKLocationCoordinateTypeGCJ02;
        //设置距离过滤参数
        _locationManager.distanceFilter = 1.0f;
        //设置预期精度参数
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设置应用位置类型
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

-(BMKUserLocation *)userLocation{
    if (!_userLocation) {
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}

-(UIButton *)resetBtn{
    if (!_resetBtn) {
        _resetBtn = [[UIButton alloc] init];
        [_resetBtn setImage:[UIImage imageNamed:@"where_select"] forState:UIControlStateNormal];
        [_resetBtn addTarget:self action:@selector(clickRestBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}

- (void)clickRestBtn{
    [self resetPosition];
}
- (void)resetPosition{
    if (self.isLocation) {
        [self.mapView setCenterCoordinate:self.userLocation.location.coordinate animated:YES];
    }else{//没自动定位到位置，需要手动定位
        @try {
            [self.locationManager stopUpdatingLocation];
        } @catch (NSException *exception) {
            NSLog(@"CNMapView.m 崩溃了");
        }
        
        [QMUITips showLoadingInView:self];
        MJWeakSelf
        [self.locationManager requestLocationWithReGeocode:NO withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
            [QMUITips hideAllTips];
            BOOL isError = false;
            if (error)
            {
                isError = YES;
                //                NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            }
            if (location) {//得到定位信息，添加annotation
                if (location.location) {
                    NSLog(@"LOC = %@",location.location);
                    //把地图放到位置中心点
                    weakSelf.mineLocationCoordinate = location.location.coordinate;
                    [weakSelf.mapView setCenterCoordinate:weakSelf.mineLocationCoordinate animated:YES];
                    //实现该方法，否则定位图标不出现
                    weakSelf.userLocation.location = location.location;
                    [weakSelf.mapView updateLocationData:weakSelf.userLocation];
                }
            }else{
                isError = YES;
            }
            if ([error.localizedDescription containsString:@"网络"] && [error.localizedDescription containsString:@"失败"]) {
                [QMUITips showInfo:@"网络错误，请检查网络。" inView:self.mapView hideAfterDelay:1.5];
            }else{
                if (isError) {
                    [QMUITips showInfo:@"无法获取您的位置信息。" inView:self.mapView hideAfterDelay:1.5];
                }
            }
            if (self.noNeedLocation) {
                return;
            }
            [self.locationManager startUpdatingLocation];
            [self.locationManager startUpdatingHeading];
        }];
        
    }
}
@end
