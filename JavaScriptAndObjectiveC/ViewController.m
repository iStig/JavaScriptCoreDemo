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
 
  // 一个JSContext对象，就类似于Js中的window，只需要创建一次即可。
  self.jsContext = [[JSContext alloc] init];

  // jscontext可以直接执行JS代码。
  [self.jsContext evaluateScript:@"var num = 10"];
  [self.jsContext evaluateScript:@"var squareFunc = function(value) { return value * 2 }"];
  // 计算正方形的面积
  JSValue *square = [self.jsContext evaluateScript:@"squareFunc(num)"];
  
  // 也可以通过下标的方式获取到方法
  JSValue *squareFunc = self.jsContext[@"squareFunc"];
  JSValue *value = [squareFunc callWithArguments:@[@"20"]];
  NSLog(@"%@", square.toNumber);
  NSLog(@"%@", value.toNumber);
}

- (UIWebView *)webView {
  if (_webView == nil) {
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.scalesPageToFit = YES;
    
    
#warning using IOSTest.html
     NSURL *url = [[NSBundle mainBundle] URLForResource:@"IOSTest" withExtension:@"html"];
    
#warning using test.html
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
    
    
    
//    NSURL *url = [NSURL URLWithString:@"http://172.16.101.203:8080/IOSTest"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    _webView.delegate = self;
  }
  
  return _webView;
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
  self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];

#warning using test.html
//   HYBJsObjCModel *model  = [[HYBJsObjCModel alloc] init];
//  self.jsContext[@"OCModel"] = model;
//  model.jsContext = self.jsContext;
//  model.webView = self.webView;
  
#warning using IOSTest.html
  JSNativeMethod *call = [[JSNativeMethod alloc] init];
  self.jsContext[@"AndroidCall"] = call;
  call.jsContext = self.jsContext;
  
  

  self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
    context.exception = exceptionValue;
    NSLog(@"异常信息：%@", exceptionValue);
  };
}

@end
