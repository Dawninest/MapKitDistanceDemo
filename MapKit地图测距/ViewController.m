//
//  ViewController.m
//  MapKit地图测距
//
//  Created by 蒋一博 on 16/3/31.
//  Copyright © 2016年 JiangYibo. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "locationGPS.h"
#import "Myanotation.h"
#import "LocationManager.h"

@interface ViewController ()<MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *setHomeButton;
@property (assign, nonatomic) CLLocationCoordinate2D homeCoordinate;

@property (strong, nonatomic) UIView  *messageView;
@property (strong, nonatomic) UILabel *longitudeLabel;//经度
@property (strong, nonatomic) UILabel *latitudeLabel;//纬度
@property (strong, nonatomic) UILabel *distanceLabel;





@end

//注意 info.plist中添加 NSLocationAlwaysUsageDescription
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    UIImageView *mapUnderBG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"BG"]];
    mapUnderBG.frame = self.view.frame;
    [self.view addSubview:mapUnderBG];
    
    //地图
    _mapView = [[MKMapView alloc]initWithFrame:CGRectMake(20, 100, 335, 425)];
    _mapView.mapType = MKMapTypeStandard;
    _mapView.scrollEnabled = NO;
    _mapView.zoomEnabled = NO;
    [self.view addSubview:_mapView];
    
    //初始化信息栏
    _messageView = [[UIView alloc]initWithFrame:CGRectMake(28, 440, 317, 85)];
    _messageView.backgroundColor = [UIColor colorWithRed:0.39 green:0.39 blue:0.39 alpha:0.6];
    [self.view addSubview:_messageView];
    
    UIImageView *mapBG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mapBG"]];
    mapBG.frame = CGRectMake(10, 90, 355, 445);
    [self.view addSubview:mapBG];
    
    
    
    _backButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    _backButton.frame = CGRectMake(20, 550, 30, 30);
    [_backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    _setHomeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _setHomeButton.frame = CGRectMake(100, 550, 175, 30);
    _setHomeButton.titleLabel.font = [UIFont systemFontOfSize: 15];
    _setHomeButton.layer.cornerRadius = 10;
    _setHomeButton.clipsToBounds = YES;
    [_setHomeButton.layer setBorderWidth:2.0]; //边框宽度
    [_setHomeButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_setHomeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_setHomeButton setTitle:@"将当前位置设置为Home" forState:UIControlStateNormal];
    [_setHomeButton addTarget:self action:@selector(setHome) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_setHomeButton];
    
    
    
    _distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(-10, 10, 375, 75)];
    _distanceLabel.textColor = [UIColor whiteColor];
    _distanceLabel.textAlignment = NSTextAlignmentCenter;
    _distanceLabel.font = [UIFont fontWithName:@"DBLCDTempBlack" size:70];
    [_messageView addSubview:_distanceLabel];
    
    locationGPS *loc = [locationGPS sharedlocationGPS];
    [loc getAuthorization];//授权
    [loc startLocation];//开始定位
    
    //跟踪用户位置
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    self.mapView.delegate = self;
    
    //初始位置
    [self initHome];
    
}

/**
 * 当用户位置更新，就会调用
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D center = userLocation.location.coordinate;
    userLocation.title = [NSString stringWithFormat:@"%f",center.longitude];
    userLocation.subtitle = [NSString stringWithFormat:@"%f",center.latitude];
    
    self.longitudeLabel.text = [NSString stringWithFormat:@"%f",center.longitude];
    self.latitudeLabel.text = [NSString stringWithFormat:@"%f",center.latitude];
    
    //反地理编码
    LocationManager *locManager = [[LocationManager alloc] init];
    //距离
    double distance = [locManager countLineDistanceDest:_homeCoordinate.longitude dest_Lat:_homeCoordinate.latitude self_Lon:center.longitude self_Lat:center.latitude];
    self.distanceLabel.text = [NSString stringWithFormat:@"%d",(int)distance];
    
    //设置地图的中心点，（以home所在的位置为中心点）
    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    
    //设置地图的显示范围
    MKCoordinateSpan span = MKCoordinateSpanMake(0.023666, 0.016093);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [mapView setRegion:region animated:YES];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //自定义大头针
    if (![annotation isKindOfClass:[Myanotation class]]) {
        return nil;
    }
    static NSString *ID = @"anno";
    MKAnnotationView *annoView = [mapView dequeueReusableAnnotationViewWithIdentifier:ID];
    if (annoView == nil) {
        annoView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ID];
    }
    
    Myanotation *anno = annotation;
    annoView.image = [UIImage imageNamed:@"map_locate_blue"];
    annoView.annotation = anno;
    annoView.userInteractionEnabled = NO;
    return annoView;
}


- (void)backClick{
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (void)initHome{
    
    NSString *plistPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    plistPath = [plistPath stringByAppendingString:@"/homeSit.plist"];
    NSArray *getHomeSit = [NSArray arrayWithContentsOfFile:plistPath];
    if (getHomeSit.count == 0) {
        
        [self setHome];
        
    }else{
        
        NSString *getLongitudeStr = getHomeSit[0];
        NSString *getLatitudeStr = getHomeSit[1];
        NSLog(@"%f-%f",[getLatitudeStr doubleValue],[getLongitudeStr doubleValue]);
        //typedef double CLLocationDegrees;
        _homeCoordinate =  (CLLocationCoordinate2D){[getLatitudeStr doubleValue],[getLongitudeStr doubleValue]};
        
        Myanotation *anno = [[Myanotation alloc] init];
        anno.coordinate = _homeCoordinate;
        
        [self.mapView addAnnotation:anno];
        [self.mapView setCenterCoordinate:_homeCoordinate animated:YES];
        
    }
}

- (void)setHome{
    
    
    _homeCoordinate = self.mapView.userLocation.coordinate;
    //经度
    NSString *nowHomeLongitude = [NSString stringWithFormat:@"%f",_homeCoordinate.longitude];
    //纬度
    NSString *nowHomeLatitude = [NSString stringWithFormat:@"%f",_homeCoordinate.latitude];
    
    NSLog(@"%@-%@",nowHomeLongitude,nowHomeLatitude);
    
    NSArray *nowHomeSit = @[nowHomeLongitude,nowHomeLatitude];
    
    //数据存储
    NSString *plistPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    plistPath = [plistPath stringByAppendingString:@"/homeSit.plist"];
    
    BOOL success = [nowHomeSit writeToFile:plistPath atomically:YES];
    NSLog(@"是否保存成功:%d",success);
    
    
    
    
    NSMutableArray *array = [NSMutableArray array];
    NSUInteger count = self.mapView.annotations.count;
    if (count > 1) {
        for (id obj in self.mapView.annotations) {
            if (![obj isKindOfClass:[MKUserLocation class]]) {
                [array addObject:obj];
            }
        }
        [self.mapView removeAnnotations:array];
    }
    
    Myanotation *anno = [[Myanotation alloc] init];
    anno.coordinate = _homeCoordinate;
    
    [self.mapView addAnnotation:anno];
    
    [self.mapView setCenterCoordinate:_homeCoordinate animated:YES];
    
    
    
    
}


@end
