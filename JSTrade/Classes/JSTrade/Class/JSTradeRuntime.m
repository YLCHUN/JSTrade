//
//  JSTradeRuntime.m
//  JSTrade
//
//  Created by YLCHUN on 2017/7/19.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSTradeRuntime.h"
#import <objc/runtime.h>

void jsTrade_replaceMethod(Class cls, SEL originSelector, SEL newSelector) {
    Method oriMethod = class_getInstanceMethod(cls, originSelector);
    Method newMethod = class_getInstanceMethod(cls, newSelector);
    BOOL isAddedMethod = class_addMethod(cls, originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(cls, newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}
