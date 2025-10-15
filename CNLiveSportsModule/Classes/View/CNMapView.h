//
//  CNMapView.h
//  CNLiveNetAdd
//
//  Created by open on 2019/6/4.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BMKLocationkit/BMKLocationComponent.h>//定位功能

@protocol CNMapViewDelegate <NSObject>

- (void)quiteVC;

@end
NS_ASSUME_NONNULL_BEGIN

@interface CNMapView : UIView

@property (nonatomic, weak) id<CNMapViewDelegate> delegate;
@property (nonatomic, strong) BMKMapView *mapView; //当前界面的mapView
@property (nonatomic, assign) BOOL  noNeedLocation;
@property (nonatomic, assign) BOOL  hiddenSubView;
@property (nonatomic, assign) float  tempHeight;
@property (nonatomic, copy) NSArray    *dataJsonARR;
@property (nonatomic, strong) BMKUserLocation           *userLocation; //当前位置对象

//定位
@property (nonatomic, strong) BMKLocationManager        *locationManager;//定位管理

@property (nonatomic, assign) float originH;
- (void)drawLine:(BOOL)isStop fArr:(NSArray *)arr1 lArr:(NSArray *)arr2;
@end

NS_ASSUME_NONNULL_END
