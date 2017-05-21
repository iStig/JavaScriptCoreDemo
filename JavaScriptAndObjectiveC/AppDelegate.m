//
//  AppDelegate.m
//  JavaScriptAndObjectiveC


#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>
#import "OpenShareHeader.h"

@interface AppDelegate ()
@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [OpenShare connectQQWithAppId:@"1105488636"];//1103194207 openshare  //1105488636 test  //1105057857 hzc
  [OpenShare connectWeixinWithAppId:@"wx57c7b928e9b013ba"];//wxd930ea5d5a258f4f openshare wx57c7b928e9b013ba test //wxe3ede52918691e61 hzc
  return YES;
}


// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
  if ([url.host isEqualToString:@"safepay"]) {
    //跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
      NSLog(@"result = %@",resultDic);
    }];
  }
  return YES;
}

@end
