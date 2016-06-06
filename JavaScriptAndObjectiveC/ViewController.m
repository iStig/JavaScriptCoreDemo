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

- (void)viewDidLoad {
  [super viewDidLoad];
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
