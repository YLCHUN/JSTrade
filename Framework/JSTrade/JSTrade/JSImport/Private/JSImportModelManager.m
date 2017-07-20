//
//  JSImportModelManager.m
//  JSTrade
//
//  Created by YLCHUN on 2017/7/20.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSImportModelManager.h"
#import "JSImportProtocol.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "JSImportMethod.h"
#import "NSMethodSignature+JSTrade.h"
#import "WKWebView+JSTrade.h"
#import "NSJSONSerialization+JSTrade.h"

#pragma mark - GET SET
static const char *k_webView = "jsTrade_webView";
static const char *k_spaceName = "jsTrade_spaceName";
static const char *k_methodDict = "jsTrade_methodDict";

static WKWebView *getWebView(JSImportObject self) {
    return objc_getAssociatedObject(self, sel_registerName(k_webView));
}
static void setWebView(JSImportObject self, WKWebView *webView) {
    objc_setAssociatedObject(self, sel_registerName(k_webView), webView, OBJC_ASSOCIATION_ASSIGN);
}

NSString *getSpaceName(JSImportObject self) {
    return objc_getAssociatedObject(self, sel_registerName(k_spaceName));
}
static void setSpaceName(JSImportObject self, NSString *spaceName) {
    objc_setAssociatedObject(self, sel_registerName(k_spaceName), spaceName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
NSDictionary<NSString *,JSImportMethod *> *getMethodDict(id self) {
    return objc_getAssociatedObject(self, sel_registerName(k_methodDict));
}
static void setMethodDict(JSImportObject self, NSDictionary<NSString *,JSImportMethod *> *methodDict) {
    objc_setAssociatedObject(self, sel_registerName(k_methodDict), methodDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark -
static const char* name_forwardFunction = "jsTrade_forwardFunction";
static const char* name_forwardInvocation = "jsTrade_forwardInvocation:";

static void forwardInvocation(JSImportObject self, NSInvocation *anInvocation) {
    NSString *selName = NSStringFromSelector(anInvocation.selector);
    JSImportMethod *method = [getMethodDict(self) objectForKey:selName];
    if (method) {
        if (!anInvocation.argumentsRetained) {
            [anInvocation retainArguments];
        }
        NSMethodSignature *signature = anInvocation.methodSignature;
        NSString *spaceName = getSpaceName(self);
        NSString *jsFuncName = spaceName.length>0 ? [NSString stringWithFormat:@"%@.%@", spaceName, method.jsFuncName] : method.jsFuncName;
        WKWebView *webView = getWebView(self);
        id returnValue;
        if (method.isVar) {
            if (method.isSet) {
                id param = [signature getInvocationValue:anInvocation atIndex:2];
                if (!param) {
                    param = [[NSNull alloc] init];
                }
                [webView jsSetVar:jsFuncName value:param];
            }else{
                returnValue = [webView jsGetVar:jsFuncName];
            }
        }else{
            NSInteger paramsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
            NSMutableArray * params = [NSMutableArray array];
            for (NSInteger i = 0; i < paramsCount; i++) {
                id argument = [signature getInvocationValue:anInvocation atIndex:i + 2];
                if (!argument) {
                    argument = [[NSNull alloc] init];
                }
                [params addObject:argument];
            }
            returnValue = [webView jsFunc:jsFuncName arguments:params];
        }
        anInvocation.selector = sel_registerName(name_forwardFunction);
        [anInvocation invoke];
        
        if (signature.methodReturnLength>0) {
            [signature setInvocation:anInvocation value:returnValue atIndex:-1];
        }
    }else {
        if ([selName isEqualToString:@"webView"]||[selName isEqualToString:@"setWebView:"]||[selName isEqualToString:@"spaceName"]) {//JSImportBase 函数未实现，不做处理
            return;
        }
        ((void( *)(id, SEL, NSInvocation *))objc_msgSend)(self, sel_registerName(name_forwardInvocation), anInvocation);
    }
}

static void jsTrade_addFunction(Class subClass) {
    IMP imp_forwardFunction = imp_implementationWithBlock(^(id self) {
    });
    class_addMethod(subClass, sel_registerName(name_forwardFunction), imp_forwardFunction, "v@:");
    
    //JSImportProtocol function
    IMP imp_webView = imp_implementationWithBlock(^WKWebView*(id self) {
        return getWebView(self);
    });
    class_addMethod(subClass, sel_registerName("webView"), imp_webView, "@@:");
    IMP imp_setWebView = imp_implementationWithBlock(^(id self,WKWebView* webView) {
        setWebView(self, webView);
        //
    });
    class_addMethod(subClass, sel_registerName("setWebView:"), imp_setWebView, "v@:@");
    
    IMP imp_spaceName = imp_implementationWithBlock(^NSString*(id self) {
        return getSpaceName(self);
    });
    class_addMethod(subClass, sel_registerName("spaceName"), imp_spaceName, "@@:");
//    IMP imp_setSpaceName = imp_implementationWithBlock(^(id self,NSString* spaceName) {
//        setSpaceName(self, spaceName);
//    });
//    class_addMethod(subClass, sel_registerName("setSpaceName:"), imp_setSpaceName, "v@:@");
}

static void jsTrade_forwardInvocation(id self) {
    NSCParameterAssert(self);
    Class selfClass = object_getClass(self);
    char buffer[100] = "";
    const char *selfclass = object_getClassName(self);
    strcpy(buffer,selfclass);
    strcat(buffer,"_miSub");
    char *subclass = buffer;
    Class subClass = objc_getClass(subclass);
    if (subClass == nil) {
        subClass = objc_allocateClassPair(selfClass, subclass, 0);
        Method method_forwardInvocation = class_getInstanceMethod(subClass, @selector(forwardInvocation:));
        const char *encode_forwardInvocation = method_getTypeEncoding(method_forwardInvocation);
        IMP imp_forwardInvocation = imp_implementationWithBlock(^(id self, NSInvocation *anInvocation ) {
            forwardInvocation(self, anInvocation);
        });
        BOOL b = class_addMethod(subClass, @selector(forwardInvocation:), imp_forwardInvocation, encode_forwardInvocation);
        if (b) {
            class_replaceMethod(subClass, sel_registerName(name_forwardInvocation), method_getImplementation(method_forwardInvocation), encode_forwardInvocation);
        }else{
            //添加失败
        }
        
        Method method_class = class_getInstanceMethod(subClass, @selector(class));
        IMP imp_class = imp_implementationWithBlock(^Class(id self) {
            return selfClass;
        });
        const char *encode_class = method_getTypeEncoding(method_class);
        class_replaceMethod(subClass, @selector(class), imp_class, encode_class);
        objc_registerClassPair(subClass);
        jsTrade_addFunction(subClass);
    }
    object_setClass(self, subClass);
}


#pragma mark - JSImportProtocol analysize
static void jsImportMethods(JSImportObject model) {
    Protocol *jsProtocol = @protocol(JSImportProtocol);
    Class cls = [model class];
    if (class_conformsToProtocol(cls,jsProtocol)){
        unsigned int listCount = 0;
        Protocol * __unsafe_unretained *protocolList =  class_copyProtocolList(cls, &listCount);
        for (int i = 0; i < listCount; i++) {
            Protocol *protocol = protocolList[i];
            if(protocol_conformsToProtocol(protocol, jsProtocol)) {
                jsProtocol = protocol;
                break;
            }
        }
        free(protocolList);
        struct objc_method_description * methodList = protocol_copyMethodDescriptionList(jsProtocol, NO, YES, &listCount);
        NSMutableDictionary *methodDict = [NSMutableDictionary dictionary];
        NSMutableArray *varNameArray = [NSMutableArray array];
        for(int i=0;i<listCount;i++) {
            SEL sel = methodList[i].name;
            NSString *selName = NSStringFromSelector(sel);
            NSString *jsFuncName;
            JSImportMethod *method;
            
            if (![selName containsString:@"__JS_IMPORT_AS_"]) {
                method = methodDict[selName];
                if (!method) {
                    method = [[JSImportMethod alloc] init];
                    methodDict[selName] = method;
                }
                method.sel = sel;
                method.selName  = selName;
                char *type = methodList[i].types;
                NSString *selTypes = [NSString stringWithUTF8String:type];
                
                if ([selTypes containsString:@":"]) {
                    NSArray *arr = [selName componentsSeparatedByString:@":"];
                    if ((arr.count>2 && method.isAs) || (method.isVar && method.isAs)) {
                        continue;
                    }else{
                        jsFuncName = arr[0];
                    }
                }else{
                    jsFuncName = selName;
                }
                method.jsFuncName = jsFuncName;
            }else{
                if ([selName containsString:@"__JS_IMPORT_AS__"]) {
                    NSArray *keys = [selName componentsSeparatedByString:@"__JS_IMPORT_AS__"];
                    selName = keys[0];
                    NSString *selNameAs = keys[1];
                    jsFuncName = [selNameAs stringByReplacingOccurrencesOfString:@":" withString:@""];
                    method = methodDict[selName];
                    if (!method) {
                        method = [[JSImportMethod alloc] init];
                        methodDict[selName] = method;
                    }
                    method.isAs = YES;
                    method.jsFuncName = jsFuncName;
                } else {//__JS_IMPORT_AS_VAR_
                    [varNameArray addObject:selName];
                    BOOL isSet = NO;
                    NSString *getName = selName;
                    if ([selName hasPrefix:@"set"]) {
                        NSString *tmp =  [selName substringWithRange:NSMakeRange(3, selName.length-4)];
                        if ([varNameArray containsObject:tmp]) {
                            getName = tmp;
                            isSet = YES;
                        }else{
                            tmp = [tmp stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[tmp substringToIndex:1] lowercaseString]];
                            if ([varNameArray containsObject:tmp]) {
                                getName = tmp;
                                isSet = YES;
                            }
                        }
                    }
                    if ([selName containsString:@"__JS_IMPORT_AS_VAR_AS__"]) {
                        jsFuncName = [getName componentsSeparatedByString:@"__JS_IMPORT_AS_VAR_AS__"][1];
                        selName = [selName componentsSeparatedByString:@"__JS_IMPORT_AS_VAR_AS__"][0];
                        if (isSet) {
                            selName = [selName stringByAppendingString:@":"];
                        }
                    }else {
                        jsFuncName = [getName stringByReplacingOccurrencesOfString:@"__JS_IMPORT_AS_VAR__" withString:@""];
                        selName = [selName stringByReplacingOccurrencesOfString:@"__JS_IMPORT_AS_VAR__" withString:@""];
                    }
                    method = methodDict[selName];
                    if (!method) {
                        method = [[JSImportMethod alloc] init];
                        methodDict[selName] = method;
                    }
                    method.isSet = isSet;
                    method.isVar = YES;
                    method.jsFuncName = jsFuncName;
                    method.isAs = YES;
                }
            }
        }
        free(methodList);
        setMethodDict(model, methodDict);
    }
}

#pragma mark - 

void JSTradeImportSpaceNameSet(JSImportObject self, NSString*spaceName) {
    if (spaceName.length == 0) {
        return;
    }
    NSString*_spaceName = getSpaceName(self);
    if (!_spaceName) {
        jsTrade_forwardInvocation(self);
        jsImportMethods(self);
    }
    setSpaceName(self, spaceName);    
}
