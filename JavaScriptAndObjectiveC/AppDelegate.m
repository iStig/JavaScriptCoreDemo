//
//  AppDelegate.m
//  JavaScriptAndObjectiveC


#import "AppDelegate.h"
//＝＝＝＝＝＝＝＝＝＝ShareSDK头文件＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
//以下是ShareSDK必须添加的依赖库：
//1、libicucore.dylib
//2、libz.dylib
//3、libstdc++.dylib
//4、JavaScriptCore.framework

//＝＝＝＝＝＝＝＝＝＝以下是各个平台SDK的头文件，根据需要继承的平台添加＝＝＝
//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//以下是腾讯SDK的依赖库：
//libsqlite3.dylib

//微信SDK头文件
#import "WXApi.h"
//以下是微信SDK的依赖库：
//libsqlite3.dylib

//新浪微博SDK头文件
#import "WeiboSDK.h"
//新浪微博SDK需要在项目Build Settings中的Other Linker Flags添加"-ObjC"
//以下是新浪微博SDK的依赖库：
//ImageIO.framework
//libsqlite3.dylib
//AdSupport.framework

#import <AlipaySDK/AlipaySDK.h>


@interface AppDelegate ()
@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  
  [ShareSDK registerApp:@"1314c9fb0cebc"
        activePlatforms:@[@(SSDKPlatformTypeSinaWeibo),
                          @(SSDKPlatformTypeTencentWeibo),
                          @(SSDKPlatformTypeWechat),
                          @(SSDKPlatformTypeQQ)]
               onImport:^(SSDKPlatformType platformType) {
                 
                 switch (platformType)
                 {
                   case SSDKPlatformTypeWechat:
                     [ShareSDKConnector connectWeChat:[WXApi class] delegate:self];
                     break;
                   case SSDKPlatformTypeQQ:
                     [ShareSDKConnector connectQQ:[QQApiInterface class]
                                tencentOAuthClass:[TencentOAuth class]];
                     break;
                   case SSDKPlatformTypeSinaWeibo:
                     [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                     break;
                   default:
                     break;
                 }
               }
        onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
          
          switch (platformType)
          {
            case SSDKPlatformTypeSinaWeibo:
              //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
              [appInfo SSDKSetupSinaWeiboByAppKey:@"568898243"
                                        appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
                                      redirectUri:@"http://www.sharesdk.cn"
                                         authType:SSDKAuthTypeBoth];
              break;
            case SSDKPlatformTypeTencentWeibo:
              //设置腾讯微博应用信息，其中authType设置为只用Web形式授权
              [appInfo SSDKSetupTencentWeiboByAppKey:@"801307650"
                                           appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
                                         redirectUri:@"http://www.sharesdk.cn"];
              break;
            case SSDKPlatformTypeWechat:
              [appInfo SSDKSetupWeChatByAppId:@"wx4868b35061f87885"
                                    appSecret:@"64020361b8ec4c99936c0e3999a9f249"];
              break;
            case SSDKPlatformTypeQQ:
              [appInfo SSDKSetupQQByAppId:@"100371282"
                                   appKey:@"aed9b0303e3ed1e27bae87c33761161d"
                                 authType:SSDKAuthTypeBoth];
              break;
              default:
              break;
          }
        }];
  
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
