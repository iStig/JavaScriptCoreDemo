#import "JSNativeMethod.h"
@implementation JSNativeMethod

- (NSString *)imgCallBack:(NSString *)url {
  NSLog(@"touch image %@",url);
  return @"iOS To H5";
}

- (void)callWithDict:(NSDictionary *)params {

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

  NSLog(@"scan1234 %@",result);
  
  // JS调用后OC后，又通过OC调用JS，但是这个是没有传参数的
  JSValue *jsFunc = self.jsContext[@"jsFunc"];
  [jsFunc callWithArguments:@[@{@"scan":result}]];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
  [self.viewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
