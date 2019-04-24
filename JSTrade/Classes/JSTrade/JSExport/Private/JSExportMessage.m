//
//  JSExportMessage.m
//  JSTrade
//
//  Created by YLCHUN on 2017/7/18.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSExportMessage.h"

@interface JSExportMessage ()

@property (nonatomic, strong) id webView;
@property (nonatomic, strong) NSDictionary *body;

@end

@implementation JSExportMessage

-(instancetype)initWithWebView:(id)webView message:(id)body {
    self = [super init];
    if (self) {
        self.webView = webView;
        self.body = body;
    }
    return self;
}
@end
