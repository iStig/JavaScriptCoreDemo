


#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GpsManager.h"
#import "QRCodeReaderDelegate.h"
#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"


#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Product.h"
#import "AFNetworking.h"
#import "OpenShareHeader.h"
#import <Social/Social.h>

//首先创建一个实现了JSExport协议的协议
@protocol TestJSObjectProtocol <JSExport>

//此处我们测试几种参数的情况
- (NSString *)imgCallBack:(NSString *)url;

// 通过JSON传过来
- (void)callWithDict:(NSDictionary *)params;

// 第三方分享
- (void)shareSDK:(NSDictionary *)params;

// JS调用此方法来调用OC的系统相册方法
- (void)callSystemCamera;

// js调用系统扫一扫二维码
- (void)callSystemQRScan;

// JS调用支付
- (void)jsCallPayment:(NSDictionary *)price;

// JS调用OC,然后在OC中通过调用JS方法来传值给JS。
- (void)jsCallObjcAndObjcCallJsWithDict:(NSDictionary *)params;

// 在JS中调用时，函数名应该为showAlertMsg(arg1, arg2)
// 这里是只两个参数的。
- (void)showAlert:(NSString *)title msg:(NSString *)msg;

@end

@interface JSNativeMethod : NSObject<TestJSObjectProtocol,QRCodeReaderDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate,NSURLSessionDelegate,UIActionSheetDelegate>
@property (nonatomic, weak) JSContext *jsContext;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) CLLocationManager *manager;
@end
