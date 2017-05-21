//
//  ViewController.m
//  JavaScriptAndObjectiveC

#import "ViewController.h"
#import "JSNativeMethod.h"


@interface ViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) JSContext *jsContext;

@end

@implementation ViewController
- (void)login:(UIButton *)sender {
    NSInteger index = sender.tag;
    
    if (index == 1) {//weixin
        //        __block NSString *code = nil;
        //        [OpenShare WeixinAuth:@"snsapi_userinfo" Success:^(NSDictionary *message) {
        //            if (message) {
        //                code = message[@"code"];
        //            }
        //        } Fail:^(NSDictionary *message, NSError *error) {
        //            nil;
        //        }];
        
        //login scope: @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";//,post_timeline,sns
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [OpenShare WeixinAuth:@"snsapi_userinfo" Success:^(NSDictionary *message) {
                NSLog(@"微信登录成功:\n%@",message);
            } Fail:^(NSDictionary *message, NSError *error) {
                NSLog(@"微信登录失败:\n%@\n%@",message,error);
            }];
        });
        
        
        
    }else if (index == 2){//qq
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [OpenShare QQAuth:@"get_user_info" Success:^(NSDictionary *message) {
                NSLog(@"QQ登录成功\n%@",message);
            } Fail:^(NSDictionary *message, NSError *error) {
                NSLog(@"QQ登录失败\n%@\n%@",error,message);
            }];
        });
        
    }

    
}

- (void)viewDidLoad {
  [super viewDidLoad];
    
    
    
    
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake(100, 50, 200, 80);
//    [button setTitle:@"weixin" forState:UIControlStateNormal];
//    button.backgroundColor = [UIColor redColor];
//    button.tag = 1;
//    [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
//    
//    
//    
//    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
//    button2.frame = CGRectMake(100, 150, 200, 80);
//    [button2 setTitle:@"qq" forState:UIControlStateNormal];
//     button2.backgroundColor = [UIColor greenColor];
//    button2.tag = 2;
//    [button2 addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button2];
    



    
    
  [self.view addSubview:self.webView];
  
  // 一个JSContext对象，就类似于JS中的Window，只需要创建一次即可
  self.jsContext = [[JSContext alloc] init];
}


- (UIWebView *)webView {
  if (_webView == nil) {
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.scalesPageToFit = YES;
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"IOSTest" withExtension:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    _webView.delegate = self;
  }
  
  return _webView;
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
  // 获取当前JS运行环境
  self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
  
  // 将block被赋给JSContext里的一个标识符,JavaScriptCore 会自动的把block封装在JavaScript函数里。这使得在JavaScript中可以简单的使用Foundation和Cocoa类,本例中将韩语参数传入通过CFStringTransform()转义
  self.jsContext[@"simplifyString"] = ^(NSString *input) {
    NSMutableString *mutableString = [input mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)mutableString, NULL, kCFStringTransformStripCombiningMarks, NO);
    return mutableString;
  };
  
  //调用JS代码并且返回参数
  NSLog(@"%@", [self.jsContext evaluateScript:@"simplifyString('안녕하새요!')"]);

  JSNativeMethod *call = [[JSNativeMethod alloc] init];
  //将JSNativeMethod封装到JavaScript函数MobilePhoneCall()中
  self.jsContext[@"MobilePhoneCall"] = call;
  call.jsContext = self.jsContext;
  call.viewController = self;
  
  //JSContext 还有另外一个有用的招数：通过设置上下文的 exceptionHandler 属性，你可以观察和记录语法，类型以及运行时错误。 exceptionHandler 是一个接收一个 JSContext 引用和异常本身的回调处理
  self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
    context.exception = exceptionValue;
    NSLog(@"异常信息：%@", exceptionValue);
  };
}

@end
