#import "JSNativeMethod.h"
@implementation JSNativeMethod

- (NSString *)imgCallBack:(NSString *)url {
  NSLog(@"touch image %@",url);
  return @"iOS To H5";
}
- (void)callWithDict:(NSDictionary *)params {
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
}

- (void)shareSDK {

  //1、创建分享参数
  NSArray* imageArray = @[@"http://mob.com/Assets/images/logo.png?v=20150320"];

  if (imageArray) {
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:@"分享内容"
                                     images:imageArray
                                        url:[NSURL URLWithString:@"http://mob.com"]
                                      title:@"分享标题"
                                       type:SSDKContentTypeAuto];
    //2、分享（可以弹出我们的分享菜单和编辑界面）
    [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                             items:nil
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                 
                 switch (state) {
                   case SSDKResponseStateSuccess:
                   {
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                         message:nil
                                                                        delegate:nil
                                                               cancelButtonTitle:@"确定"
                                                               otherButtonTitles:nil];
                     [alertView show];
                     break;
                   }
                   case SSDKResponseStateFail:
                   {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                     message:[NSString stringWithFormat:@"%@",error]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil, nil];
                     [alert show];
                     break;
                   }
                   default:
                     break;
                 }
               }
     ];}
}

- (void)showAlert:(NSString *)title msg:(NSString *)msg {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [a show];
  });
}

#pragma mark scan
- (void)scan {
  
  NSLog(@"scan56");
  
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
  self.imagePickerController = [[UIImagePickerController alloc] init];
  self.imagePickerController.delegate = self;
  self.imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
  self.imagePickerController.allowsEditing = YES;
  self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  [self.viewController presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
  NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
  
  if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
  }else{
  }
  [self.viewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - QRCodeReader Delegate Methods
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
  [self.viewController dismissViewControllerAnimated:YES completion:^{
  }];
  // JS调用后OC后，又通过OC调用JS，但是这个是没有传参数的
  JSValue *jsFunc = self.jsContext[@"jsFunc"];
  [jsFunc callWithArguments:@[@{@"scan":result}]];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
  [self.viewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
