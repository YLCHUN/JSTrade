//
//  JSModel_Document.m
//  WKWebView_JSTrade
//
//  Created by YLCHUN on 2017/5/31.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSModel_Document.h"

@implementation JSModel_Document

-(instancetype)init {
    self = [super init];
    if (self) {
        JSTradeImportSpaceNameSet(self, @"document");
    }
    return self;
}

@end
