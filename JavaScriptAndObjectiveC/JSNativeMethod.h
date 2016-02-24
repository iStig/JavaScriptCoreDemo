//
//  AndroidCall.h
//  JavaScriptAndObjectiveC


#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>

//首先创建一个实现了JSExport协议的协议
@protocol TestJSObjectProtocol <JSExport>

//此处我们测试几种参数的情况
- (NSString *)imgCallBack:(NSString *)url;

// 通过JSON传过来
- (void)callWithDict:(NSDictionary *)params;

// JS调用此方法来调用OC的系统相册方法
- (void)callSystemCamera;

// JS调用Oc，然后在OC中通过调用JS方法来传值给JS。
- (void)jsCallObjcAndObjcCallJsWithDict:(NSDictionary *)params;

// 在JS中调用时，函数名应该为showAlertMsg(arg1, arg2)
// 这里是只两个参数的。
- (void)showAlert:(NSString *)title msg:(NSString *)msg;
@end

@interface JSNativeMethod : NSObject<TestJSObjectProtocol>
@property (nonatomic, weak) JSContext *jsContext;
@end
