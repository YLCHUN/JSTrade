//
//  JSTradeRuntime.m
//  JSTrade
//
//  Created by YLCHUN on 2017/7/19.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSTradeRuntime.h"
#import <objc/runtime.h>

void jsTrade_replaceMethod(Class class, SEL originSelector, SEL newSelector) {
    Method oriMethod = class_getInstanceMethod(class, originSelector);
    Method newMethod = class_getInstanceMethod(class, newSelector);
    BOOL isAddedMethod = class_addMethod(class, originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(class, newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}
