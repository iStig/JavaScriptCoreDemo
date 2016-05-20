//
//  GpsManager.h
//  JavaScriptAndObjectiveC
//
//  Created by iStig on 16/5/20.
//  Copyright © 2016年 huangyibiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface GpsManager : NSObject<CLLocationManagerDelegate> {
  CLLocationManager *manager;
  
  // block的申明 定义
  void (^saveGpsCallback) (double lat, double lng);
}
// 申明一个 cb的对象
+ (void) getGps:(  void (^)(double lat, double lng) )cb;
+ (void) stop;

@end
