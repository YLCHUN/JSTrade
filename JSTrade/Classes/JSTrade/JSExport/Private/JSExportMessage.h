//
//  JSExportMessage.h
//  JSTrade
//
//  Created by YLCHUN on 2017/7/18.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSExportMessage : NSObject
@property (nonatomic, strong, readonly) id webView;
@property (nonatomic, strong, readonly) NSDictionary *body;
-(instancetype)initWithWebView:(id)webView message:(id)body;
@end
