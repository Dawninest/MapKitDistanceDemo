//
//  locationGPS.h
//  MapKit地图测距
//
//  Created by 蒋一博 on 16/3/31.
//  Copyright © 2016年 JiangYibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface locationGPS : NSObject<CLLocationManagerDelegate>
+ (instancetype)sharedlocationGPS;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic,assign) double longitude;//经度
@property (nonatomic,assign) double latitude;//纬度
//定位结束的回调
@property (nonatomic,strong) void(^locationCompleteBlock)(double longitude,double latitude);
- (void)getAuthorization;//授权
//- (void)alertOpenLocationSwitch;//提示用户打开定位开关
- (void)startLocation;//点击某个按钮开始定位
@end

