#import "JSNativeMethod.h"
#import "RxWebViewController.h"
#import "RxWebViewNavigationViewController.h"

@implementation JSNativeMethod

- (NSString *)imgCallBack:(NSString *)url {
  NSLog(@"touch image %@",url);
  return @"iOS To H5";
}
- (void)callWithDict:(NSDictionary *)params {
  
  NSLog(@"%@",params);
  JSValue *jsFunc = self.jsContext[@"uploadimage"];
  [jsFunc callWithArguments:@[@{@"image":@"image upload success"}]];
}

// js调用系统扫一扫二维码
- (void)callSystemQRScan {
  [self scan];
}
- (void)callSystemCamera {
  [self selectImageFromAlbum];
}
- (void)jsCallObjcAndObjcCallJsWithDict:(NSDictionary *)params {
  
  [self fetchLocation];
  NSLog(@"调用location");
}

// JS调用支付
- (void)jsCallPayment:(NSDictionary *)price {
    Product *product = [[Product alloc] init];
    product.subject = @"1";
    product.body = @"我是测试数据";
    product.price = [price[@"price"] floatValue];

  /*
   *商户的唯一的parnter和seller。
   *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
   */
  
  /*============================================================================*/
  /*=======================需要填写商户app申请的===================================*/
  /*============================================================================*/
  NSString *partner = @"2088711165110430";
  NSString *seller = @"zfb@huizuche.com";
  NSString *privateKey = @"MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAK6ASh5ikiMzEBhF+OjEmvQho3Bw2VSeUtKl6jqlIq2wYkkurB0rlgfrV1fqnqLjydupwBCnv0NDvlWSmH/PCLvkpYF5QtPga8oiqh9up0lTGgvA5Oab1dpdeyH0VvdIvaJtjGpHeSAWtYrgqlbCTj7oXw9DsR6ZdsbquO5ryPEzAgMBAAECgYEAhOnWirpN0V3Nfo+dfb5ywEz27mgmQZuuPiB9/llVxrI4ysEv+6/9QN7y0lY0qqGSWSw8zPLYbeWljgxw97i8Tw4ZoOpy34g+McnBfqxiyoP3Z6Af2nW6TwkRudpU32cOmqmmYHdEiC9il7CmdVjwT1+bhIy7Bpdw7jMNJFlu0cECQQDnTGoBvhtVIVeWPyWOTE6Dd5Ln1KFq7O2I8ymzKKjZD+SINsOu55fD/C2iW5huwJMJza7AwYwKH5k7Gy+YJ/qDAkEAwSMQU+XIAXNnHMare+8AZav+E3/UqmXhS2IeClq9hJpBWJCLeo/qLHOvI0J0r3yvOUuO2bsxw4964QGUAGIvkQJBAKSl5KAw78v93Bd8BAPzlcBIEi8tUWqIFd7zGbALNYaupYPBWDLdcU916BY3FZ9hPkowPEHChSl/rNhCVfL+InkCQQCI2vbL7GvwEz1Cl8iV1kKayOgOGyuv3udpCkqtHaVjXAbn4ezj2SyfeQ3mV0Xlv91OJStBP7NAluAEpqCgMPLxAkB8KR3Mrt4zlKvkSPWV/3EYQIXyLtuOPvDMBOk844QNBTHiYZqkt6sktM2wJy1chF1MxYtyIMpDhpvDaOMvaOju";
  /*============================================================================*/
  /*============================================================================*/
  /*============================================================================*/
  
  //partner和seller获取失败,提示
  if ([partner length] == 0 ||
      [seller length] == 0 ||
      [privateKey length] == 0)
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"缺少partner或者seller或者私钥。"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];

    return;
  }
  
  
  /*
   *生成订单信息及签名
   */
  //将商品信息赋予AlixPayOrder的成员变量
  Order *order = [[Order alloc] init];
  order.partner = partner;
  order.sellerID = seller;
  order.outTradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
  order.subject = product.subject; //商品标题
  order.body = product.body; //商品描述
  order.totalFee = [NSString stringWithFormat:@"%.2f",product.price]; //商品价格
  order.notifyURL =  @"http://www.xxx.com"; //回调URL
  
  order.service = @"mobile.securitypay.pay";
  order.paymentType = @"1";
  order.inputCharset = @"utf-8";
  order.itBPay = @"30m";
  order.showURL = @"m.alipay.com";
  
  //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
  NSString *appScheme = @"alisdkdemo";
  
  //将商品信息拼接成字符串
  NSString *orderSpec = [order description];
  NSLog(@"orderSpec = %@",orderSpec);
  
  //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
  id<DataSigner> signer = CreateRSADataSigner(privateKey);
  NSString *signedString = [signer signString:orderSpec];
  
  //将签名成功字符串格式化为订单字符串,请严格按照该格式
  NSString *orderString = nil;
  if (signedString != nil) {
    orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                   orderSpec, signedString, @"RSA"];
    
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {

      dispatch_async(dispatch_get_main_queue(), ^{
        JSValue *jsFunc = self.jsContext[@"paysuccess"];
        [jsFunc callWithArguments:@[@{@"paysuccess":resultDic}]];
      });
    }];
  }
  
}

- (void)shareSDK:(NSDictionary *)params{

  NSLog(@"%@",params);
  
  
  NSInteger index =  [params[@"ios"] integerValue];
  
 
  
  if (index == 0) {//好友
    
    OSMessage *msg=[[OSMessage alloc]init];
    msg.title=@"hello  testJs";
    //link
    msg.link=@"http://www.bshare.com/";
    msg.image=[UIImage imageNamed:@"logo"];//新闻类型的职能传缩略图就够了。
    
    
    NSLog(@"%@__%@",msg,msg.title);
    [OpenShare shareToWeixinSession:msg Success:^(OSMessage *message) {
      NSLog(@"微信分享到会话成功：\n%@",message);
    } Fail:^(OSMessage *message, NSError *error) {
      NSLog(@"微信分享到会话失败：\n%@\n%@",error,message);
    }];
  }
  if (index == 1) {//朋友圈
    
    OSMessage *msg=[[OSMessage alloc]init];
    msg.title=@"hello  testJs";
    //link
    msg.link=@"http://www.bshare.com/";
    msg.image=[UIImage imageNamed:@"logo"];//新闻类型的职能传缩略图就够了。
      [OpenShare shareToWeixinTimeline:msg Success:^(OSMessage *message) {
        NSLog(@"微信分享到朋友圈成功：\n%@",message);
      } Fail:^(OSMessage *message, NSError *error) {
        NSLog(@"微信分享到朋友圈失败：\n%@\n%@",error,message);
      }];
  }
  
  if (index == 2) {//好友
    
    OSMessage *msg=[[OSMessage alloc]init];
    msg.title=@"hello  testJs";
    //link
//    msg.link=@"http://www.bshare.com/";
//    msg.image=[UIImage imageNamed:@"logo"];//新闻类型的职能传缩略图就够了。
    
        NSLog(@"%ld",(long)index);
    [OpenShare shareToQQFriends:msg Success:^(OSMessage *message) {
      NSLog(@"分享到QQ好友成功:%@",msg);
    } Fail:^(OSMessage *message, NSError *error) {
      NSLog(@"分享到QQ好友失败:%@\n%@",msg,error);
    }];
  }
  
  if (index == 3) {//好友
    
    OSMessage *msg=[[OSMessage alloc]init];
    msg.title=@"hello  testJs";
    //link
//    msg.link=@"http://www.bshare.com/";
//    msg.image=[UIImage imageNamed:@"logo"];//新闻类型的职能传缩略图就够了。
    NSLog(@"%ld",(long)index);
    [OpenShare shareToQQZone:msg Success:^(OSMessage *message) {
      NSLog(@"分享到QQ空间成功:%@",msg);
    } Fail:^(OSMessage *message, NSError *error) {
      NSLog(@"分享到QQ空间失败:%@\n%@",msg,error);
    }];
    

  }
  if (index == 4) {//好友
    
    OSMessage *msg=[[OSMessage alloc]init];
    msg.title=@"hello  testJs";
    //link
    msg.link=@"http://www.bshare.com/";
    msg.image=[UIImage imageNamed:@"logo"];//新闻类型的职能传缩略图就够了。

    // 首先判断新浪分享是否可用
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeTencentWeibo]) {
      NSLog(@"tencent weibo  share fail");
      return;
    }
    // 创建控制器，并设置ServiceType
    SLComposeViewController *composeVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTencentWeibo];
    // 添加要分享的图片
    [composeVC addImage:msg.image];
    // 添加要分享的文字
    [composeVC setInitialText:msg.title];
    // 添加要分享的url
    [composeVC addURL:[NSURL URLWithString:msg.link]];
    // 弹出分享控制器
    [self.viewController presentViewController:composeVC animated:YES completion:nil];
    // 监听用户点击事件
    composeVC.completionHandler = ^(SLComposeViewControllerResult result){
      if (result == SLComposeViewControllerResultDone) {
        NSLog(@"点击了发送");
      }
      else if (result == SLComposeViewControllerResultCancelled)
      {
        NSLog(@"点击了取消");
      }
    };
    
  }
  


  


  
}

- (void)showAlert:(NSString *)title msg:(NSString *)msg {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [a show];
  });
}

#pragma mark scan
- (void)scan {
  if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
    static QRCodeReaderViewController *vc = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
      QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
      vc                   = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
      vc.modalPresentationStyle = UIModalPresentationFormSheet;
    });
    vc.delegate = self;
    
    [vc setCompletionWithBlock:^(NSString *resultAsString) {
      NSLog(@"Completion with result: %@", resultAsString);
    }];
    
    [self.viewController presentViewController:vc animated:YES completion:NULL];
  }
  else {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Reader not supported by the current device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
  }
}

#pragma mark  打开定位 然后得到数据
- (void)fetchLocation {
  __block  BOOL isOnece = YES;
  [GpsManager getGps:^(double lat, double lng) {
    isOnece = NO;
    //只打印一次经纬度
    NSLog(@"lat lng (%f, %f)", lat, lng);
        dispatch_async(dispatch_get_main_queue(), ^{
          JSValue *jsParamFunc = self.jsContext[@"jsParamFunc"];
          [jsParamFunc callWithArguments:@[@{@"latitude":@(lat), @"longitude": @(lng) }]];
        });
    if (!isOnece) {
      [GpsManager stop];
    }
  }];
}

#pragma mark 从相册获取图片或视频
- (void)selectImageFromAlbum {
  UIActionSheet *actionSheet = nil;
  if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
    actionSheet  = [[UIActionSheet alloc] initWithTitle:nil
                                               delegate:(id<UIActionSheetDelegate>)self
                                      cancelButtonTitle:@"取消"
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:@"从相册选择", @"拍照上传", nil];
  } else {
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:(id<UIActionSheetDelegate>)self
                                     cancelButtonTitle:@"取消"
                                destructiveButtonTitle:nil
                                     otherButtonTitles:@"从相册选择", nil];
  }
  
  [actionSheet showInView:self.viewController.view];
  
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) { // 从相册选择
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
      UIImagePickerController *picker = [[UIImagePickerController alloc] init];
      picker.delegate = self;
      picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
      picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
      

      [self.viewController presentViewController:picker animated:YES completion:nil];
    }
  } else if (buttonIndex == 1) { // 拍照
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
      UIImagePickerController *picker = [[UIImagePickerController alloc] init];
      picker.delegate = self;
      picker.sourceType = UIImagePickerControllerSourceTypeCamera;
      picker.delegate = self;

      [self.viewController presentViewController:picker animated:YES completion:nil];
    }
  }
  return;
}


#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
  NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
  
  if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
//     NSURL *theImage = [info objectForKey:UIImagePickerControllerReferenceURL];
//    [self postImageToSever:theImage];
    
//    UIImage *theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
//    [self POSTIMAGE:theImage];
    
//    NSURL *theImage = [info objectForKey:UIImagePickerControllerReferenceURL];
//    [self post:theImage];
    
    UIImage *theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
//   NSData *imgeData = UIImageJPEGRepresentation(theImage,1);
    
//    UIImage *a = [self resizeImage:theImage withWidth:80 withHeight:142];
//    NSData *imgeData = UIImageJPEGRepresentation(a,1);
   
    NSData *imgeData = [self imageWithImage:theImage scaledToSize:CGSizeMake(160, 284)];
    [self  postdata:imgeData];
  }
  [self.viewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - QRCodeReader Delegate Methods
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
  [self.viewController dismissViewControllerAnimated:YES completion:^{
    
    
    if ([result containsString:@"http"]) {
      RxWebViewController* webViewController = [[RxWebViewController alloc] initWithUrl:[NSURL URLWithString:result]];
      [self.viewController.navigationController pushViewController:webViewController animated:YES];
    }
    
  }];
  // JS调用后OC后，又通过OC调用JS，但是这个是没有传参数的
  JSValue *jsFunc = self.jsContext[@"jsFunc"];
  [jsFunc callWithArguments:@[@{@"scan":result}]];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
  [self.viewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark --payment 
#pragma mark -
#pragma mark   ==============产生随机订单号==============
- (NSString *)generateTradeNO
{
  static int kNumber = 15;
  
  NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  NSMutableString *resultStr = [[NSMutableString alloc] init];
  srand((unsigned)time(0));
  for (int i = 0; i < kNumber; i++)
  {
    unsigned index = rand() % [sourceStr length];
    NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
    [resultStr appendString:oneStr];
  }
  return resultStr;
}

#pragma mark - post上传头像
- (void)postImageToSever:(NSURL *)image {
  
  //获取地址
  
  NSString *path = @"http://pic.jumaquan.com:4869/upload";//下载管理类的对象
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];//默认传输的数据类型是二进制
  
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  
  //第三个参数：进行上传数据的保存操作
  
  [manager POST:path parameters:nil constructingBodyWithBlock:^(id formData) {
    
    //找到要上传的图片
    
  NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"spec.png" ofType:nil];
    
    /*
     
     第一个参数：将要上传的数据的原始路径
     
     第二个参数：要上传的路径的key
     
     第三个参数：上传后文件的别名
     
     第四个参数：原始图片的格式
     
     */
    
     [formData appendPartWithFileURL:[NSURL URLWithString:imagePath] name:@"file" fileName:@"2345.png" mimeType:@"image.jpg" error:nil];
    
//    [formData appendPartWithFileURL:image name:@"file" fileName:@"2345.png" mimeType:@"image.jpg" error:nil];
    
  } success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
    NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",str);
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
    NSLog(@"%@",error.description);
    
  }];
  
}


- (void)POSTIMAGE:(UIImage *)image {
  NSURLSession *session = [NSURLSession sharedSession];
  NSURL *url = [NSURL URLWithString:@"http://pic.jumaquan.com:4869/upload"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  // 设置请求头数据 。  boundary：边界
  [request setValue:@"multipart/form-data; boundary=----WebKitFormBoundaryftnnT7s3iF7wV5q6" forHTTPHeaderField:@"Content-Type"];
  
  // 给请求头加入固定格式数据
  NSMutableData *data = [NSMutableData data];
  /****************文件参数相关设置*********************/
  // 设置边界 注：必须和请求头数据设置的边界 一样， 前面多两个“-”；（字符串 转 data 数据）
  [data appendData:[@"------WebKitFormBoundaryftnnT7s3iF7wV5q6" dataUsingEncoding:NSUTF8StringEncoding]];
  [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  // 设置传入数据的基本属性， 包括有 传入方式 data ，传入的类型（名称） ，传入的文件名， 。
  [data appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"image.jpeg\"" dataUsingEncoding:NSUTF8StringEncoding]];
  [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  
  // 设置 内容的类型  “文件类型/扩展名” MIME中的
  [data appendData:[@"Content-Type: image/jpeg" dataUsingEncoding:NSUTF8StringEncoding]];
  [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  // 加入数据内容
  NSData *contentData = UIImageJPEGRepresentation(image, 1.0);
  
//  NSData *contentData = [NSData dataWithContentsOfFile:@"/Users/liujiaxin/Desktop/image.jpeg"];
  [data appendData:contentData];
  [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  // 设置边界
  [data appendData:[@"------WebKitFormBoundaryftnnT7s3iF7wV5q6" dataUsingEncoding:NSUTF8StringEncoding]];
  [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  /******************非文件参数相关设置**********************/
  //  设置传入的类型（名称）
  [data appendData:[@"Content-Disposition: form-data; name=\"username\"" dataUsingEncoding:NSUTF8StringEncoding]];
  [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  
  // 传入的名称username = lxl
  [data appendData:[@"lxl" dataUsingEncoding:NSUTF8StringEncoding]];
  [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  // 退出边界
  [data appendData:[@"------WebKitFormBoundaryftnnT7s3iF7wV5q6--" dataUsingEncoding:NSUTF8StringEncoding]];
  [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  
  
  request.HTTPBody = data;
  request.HTTPMethod = @"POST";
  NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
   
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",str);
    
  }];
  [task resume];
  NSLog(@"+++++++++++++");
}

- (void)post:(NSURL *)url {

  NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://pic.jumaquan.com:4869/upload" parameters:nil constructingBodyWithBlock:^(id formData) {
    
    [formData appendPartWithFileURL:url name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg" error:nil];
    
  } error:nil];
  
  AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
  
  NSProgress *progress = nil;
  
  NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    
    if (error) {
      
      NSLog(@"Error: %@", error);
      
    } else {
      
      NSLog(@"%@ %@", response, responseObject);
      
    }
    
  }];
  
  [uploadTask resume];
  
}

- (void)postdata:(NSData *)imageData {

  NSString *path = @"http://pic.jumaquan.com:4869/upload";
  NSString *Boundary = @"AaB03x";
  NSMutableData *bodyData =  [self generateRequestWithPhotoData:imageData FileName:@"fasdf.jpg"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
  
  NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",Boundary];
  [request setValue:content forHTTPHeaderField:@"Content-Type"];
  [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
  [request setHTTPMethod:@"POST"];
  
  NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
  NSURLSessionUploadTask * uploadtask = [session uploadTaskWithRequest:request fromData:bodyData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRange range = [str rangeOfString:@"href=\""];
    
    NSLog(@"rang:%@",NSStringFromRange(range));
    str = [str substringFromIndex:(range.location+6)];//截取范围类的字符串

    
    NSRange  ra = [str rangeOfString:@"\">http"];
    
    str = [str substringToIndex:ra.location];

    
    NSString *imageurl = [NSString stringWithFormat:@"http://pic.jumaquan.com:4869%@",str];
     NSLog(@"%@",imageurl);
    
    JSValue *jsFunc = self.jsContext[@"uploadimage"];
    [jsFunc callWithArguments:@[@{@"image":imageurl}]];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:imageurl
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
    
  }];
  
  [uploadtask resume];
}


- (NSString *)getStringElementForKey:(id)key fromDict:(NSDictionary *)dict
{
  if(![dict isKindOfClass:[NSDictionary class]])
    return @"";
  
  NSString *result = @"";
  id value = [dict objectForKey:key];
  if (value) {
    if ([value isKindOfClass:[NSString class]]) {
      result = value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
      result = [(NSNumber *)value stringValue];
    }
  }
  return result;
  
}

- (NSMutableData *)generateRequestWithPhotoData:(NSData *)photoData FileName:(NSString *)fileName{
  NSString *Boundary =@"AaB03x";
  NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",Boundary];
  NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
  NSData *data = photoData;
  NSMutableString *body=[[NSMutableString alloc]init];
  
  [body appendFormat:@"%@\r\n",MPboundary];
  [body appendFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"%@\"\r\n",fileName];
  [body appendFormat:@"Content-Type: image/jpeg\r\n\r\n"];
  
  NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
  NSMutableData *myRequestData=[NSMutableData data];
  [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
  [myRequestData appendData:data];
  [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
  return myRequestData;
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
  NSLog(@"%f",totalBytesSent/(float)totalBytesExpectedToSend);
}

- (UIImage*)resizeImage:(UIImage*)image withWidth:(CGFloat)width withHeight:(CGFloat)height
{
  CGSize newSize = CGSizeMake(width, height);
  CGFloat widthRatio = newSize.width/image.size.width;
  CGFloat heightRatio = newSize.height/image.size.height;
  
  if(widthRatio > heightRatio)
  {
    newSize=CGSizeMake(image.size.width*heightRatio,image.size.height*heightRatio);
  }
  else
  {
    newSize=CGSizeMake(image.size.width*widthRatio,image.size.height*widthRatio);
  }
  
  
  UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
  [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
  UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return newImage;
}


- (NSData *)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
  UIGraphicsBeginImageContext(newSize);
  [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
  UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return UIImageJPEGRepresentation(newImage, 0.8);
}

@end
