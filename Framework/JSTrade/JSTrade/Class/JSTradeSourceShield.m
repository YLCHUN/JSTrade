//
//  JSTradeSourceShield.m
//  JSTrade
//
//  Created by YLCHUN on 2017/6/1.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSTradeSourceShield.h"
#import <Foundation/Foundation.h>
#import "JSTradeRuntime.h"
#import <WebKit/WebKit.h>
#import "JSTradeCommon.h"


@implementation WKUserScript(private)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jsTrade_replaceMethod(self, @selector(source), @selector(shield_source));
    });
}

-(NSString *)shield_source {
    NSString *source = [self shield_source];
    if ([source containsString:kJSExport_registerKey]) {
        return nil;
    } else {
        return source;
    }
}

@end

void import_JSTradeSourceShield() {
    
}
