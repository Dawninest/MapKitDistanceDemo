//
//  Myanotation.h
//  MapKit地图测距
//
//  Created by 蒋一博 on 16/3/31.
//  Copyright © 2016年 JiangYibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface Myanotation : NSObject <MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *icon;
@end
