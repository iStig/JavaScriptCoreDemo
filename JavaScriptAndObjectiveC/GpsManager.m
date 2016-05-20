//
//  GpsManager.m
//  JavaScriptAndObjectiveC
//
//  Created by iStig on 16/5/20.
//  Copyright © 2016年 huangyibiao. All rights reserved.
//

#import "GpsManager.h"


@implementation GpsManager

+ (id) sharedGpsManager {
  static id s;
  if (s == nil) {
    s = [[GpsManager alloc] init];
  }
  return s;
}
- (id)init {
  self = [super init];
  if (self) {
    // 打开定位 然后得到数据
    manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // 兼容iOS8.0版本
    /* Info.plist里面加上2项
     NSLocationAlwaysUsageDescription      Boolean YES
     NSLocationWhenInUseUsageDescription   Boolean YES
     */
    
    // 请求授权 requestWhenInUseAuthorization用在>=iOS8.0上
    // respondsToSelector: 前面manager是否有后面requestWhenInUseAuthorization方法
    // 1. 适配 动态适配
    if ([manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
      [manager requestWhenInUseAuthorization];
      [manager requestAlwaysAuthorization];
    }

  }
  return self;
}
- (void) getGps:(  void (^)(double lat, double lng) )cb {
  if ([CLLocationManager locationServicesEnabled] == FALSE) {
    return;
  }
  // block一般赋值需要copy
  saveGpsCallback = [cb copy];
  
  // 停止上一次的
  [manager stopUpdatingLocation];
  // 开始新的数据定位
  [manager startUpdatingLocation];
}

+ (void) getGps:(  void (^)(double lat, double lng) )cb {
  [[GpsManager sharedGpsManager] getGps:cb];
}

- (void) stop {
  [manager stopUpdatingLocation];
}
+ (void) stop {
  [[GpsManager sharedGpsManager] stop];
}

// 每隔一段时间就会调用
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  for (CLLocation *loc in locations) {
    CLLocationCoordinate2D l = loc.coordinate;
    double lat = l.latitude;
    double lnt = l.longitude;
    
    // 使用blocks 调用blocks
    if (saveGpsCallback) {
      saveGpsCallback(lat, lnt);
    }
  }
}
@end
