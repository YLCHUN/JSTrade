//
//  JSExportModelManager.m
//  JSTrade
//
//  Created by YLCHUN on 2017/7/20.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSExportModelManager.h"
#import <objc/runtime.h>
#import "NSMethodSignature+JSTrade.h"
#import "WKWebView+JSTrade.h"
#import "NSJSONSerialization+JSTrade.h"
#import <WebKit/WebKit.h>
#import "JSTradeCommon.h"
#import "JSExportMethod.h"


#pragma mark - JSExportProtocol analysize

NSDictionary<NSString *,JSExportMethod *>* jsExportMethods(id<JSExportProtocol> model) {
    Protocol *jsProtocol = @protocol(JSExportProtocol);
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
        struct objc_method_description * methodList = protocol_copyMethodDescriptionList(jsProtocol, YES, YES, &listCount);
        NSMutableArray *methodArray = [NSMutableArray arrayWithCapacity:listCount];
        NSMutableDictionary *methodDict = [NSMutableDictionary dictionary];
        NSMutableDictionary *modelMethodDict = [NSMutableDictionary dictionary];
        
        for(int i=0;i<listCount;i++) {
            SEL sel = methodList[i].name;
            NSString *selName = NSStringFromSelector(sel);
            JSExportMethod *method = [JSExportMethod methWithTarget:model sel:sel];
            NSString *jsFuncName;
            if (method.callBack) {
                jsFuncName = [selName componentsSeparatedByString:@":"][0];
            }else{
                jsFuncName = [selName stringByReplacingOccurrencesOfString:@":" withString:@""];
            }
            method.jsFuncName = jsFuncName;
            methodArray[i] = method;
            methodDict[selName] = method;
            modelMethodDict[jsFuncName] = method;
        }
        free(methodList);
        struct objc_method_description * methodListAs = protocol_copyMethodDescriptionList(jsProtocol, NO, YES, &listCount);
        for(int i=0;i<listCount;i++) {
            SEL sel = methodListAs[i].name;
            NSString *selName = NSStringFromSelector(sel);
            if ([selName containsString:@"__JS_EXPORT_AS__"]) {
                NSArray *keys = [selName componentsSeparatedByString:@"__JS_EXPORT_AS__"];
                NSString *selName = keys[0];
                JSExportMethod *method = methodDict[selName];
                [modelMethodDict removeObjectForKey:method.jsFuncName];
                NSString *selNameAs = keys[1];
                NSString *jsFuncName = [selNameAs stringByReplacingOccurrencesOfString:@":" withString:@""];
                method.jsFuncName = jsFuncName;
                modelMethodDict[jsFuncName] = method;
            }
        }
        free(methodListAs);
        return modelMethodDict;
    }else{
        return nil;
    }
}

#pragma mark - GET SET

static const char *k_webView = "jsTrade_webView";
static const char *k_jsImportModelArray = "jsTrade_jsImportModelArray";
static const char *k_methodDict = "jsTrade_methodDict";

NSArray<JSImportObject> * getJsImportModelArray(JSExportObject self) {
    return objc_getAssociatedObject(self, sel_registerName(k_jsImportModelArray));
}

void setJsImportModelArray(JSExportObject self, NSArray<JSImportObject> *jsImportModelArray) {
    objc_setAssociatedObject(self, sel_registerName(k_jsImportModelArray), jsImportModelArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

WKWebView *getWebView(JSExportObject self) {
    return objc_getAssociatedObject(self, sel_registerName(k_webView));
}

void setWebView(JSExportObject self, WKWebView *webView) {
    if (getWebView(self) == webView) {
        return;
    }
    objc_setAssociatedObject(self, sel_registerName(k_webView), webView, OBJC_ASSOCIATION_ASSIGN);
    NSArray<JSImportObject> *jsImportModels = getJsImportModelArray(self);
    if (!jsImportModels && [self respondsToSelector:@selector(jsImportModels)]) {
        jsImportModels = [self jsImportModels];
        setJsImportModelArray(self, jsImportModels);
    }
    for (JSImportObject jsImportModel in jsImportModels) {
        jsImportModel.webView = getWebView(self);
    }
}


void setMethodDict(JSExportObject self, NSDictionary<NSString *,JSExportMethod *> * methodDict) {
    objc_setAssociatedObject(self, sel_registerName(k_methodDict), methodDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

NSDictionary<NSString *,JSExportMethod *> * getMethodDict(JSExportObject self) {
    NSDictionary <NSString*,JSExportMethod*> *methodDict = objc_getAssociatedObject(self,sel_registerName(k_methodDict));
    if (!methodDict) {
        methodDict = jsExportMethods(self);
        setMethodDict(self, methodDict);
    }
    return methodDict;
}


#pragma mark - WKUserScript

NSString* getJsExportCodeWithKey(JSExportObject self, NSString *aKey) {
    NSArray *methods = [getMethodDict(self) allValues];
    NSMutableString *jsExportModelString = [NSMutableString string];
    [jsExportModelString appendFormat:@"window.%@ = {\n", aKey];
    [jsExportModelString appendFormat:@"spaceName: '%@',\n", aKey];
    NSMutableArray *funcArray = [NSMutableArray array];
    for (JSExportMethod *method in methods) {
        [funcArray addObject:[method scriptCode]];
    }
    [jsExportModelString appendString:[funcArray componentsJoinedByString:@",\n"]];
    [jsExportModelString appendString:@"}\n"];
    return jsExportModelString;
}

WKUserScript* getScriptWithKey(id self, NSString*aKey) {
    NSString *jsCode = getJsExportCodeWithKey(self, aKey);
    WKUserScript *script = [[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    return script;
}

#pragma mark -

JSExportMethod* getMethodWithFuncName(JSExportObject self, NSString *name) {
    return getMethodDict(self)[name];
}

