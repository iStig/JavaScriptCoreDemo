//
//  Product.h
//  JavaScriptAndObjectiveC
//
//  Created by iStig on 16/6/6.
//  Copyright © 2016年 huangyibiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject{
@private
  float     _price;
  NSString *_subject;
  NSString *_body;
  NSString *_orderId;
}

@property (nonatomic, assign) float price;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *orderId;

@end
