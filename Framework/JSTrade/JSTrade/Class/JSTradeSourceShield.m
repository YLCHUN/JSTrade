//
//  JSTradeSourceShield.m
//  JSTrade
//
//  Created by YLCHUN on 2017/6/1.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSTradeSourceShield.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <WebKit/WebKit.h>
#import "JSTradeCommon.h"


@implementation WKUserScript(private)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(source);
        SEL swizzledSelector = @selector(shield_source);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
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
