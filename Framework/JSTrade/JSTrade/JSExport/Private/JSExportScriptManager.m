//
//  JSExportScriptManager.m
//  JSTrade
//
//  Created by YLCHUN on 2017/7/4.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSExportScriptManager.h"
#import "JSExportModel.h"
#import "JSExportMethod.h"
#import <WebKit/WebKit.h>
#import "WKWebView+JSTrade.h"
#import "JSTradeCommon.h"
#import "JSExportMessage.h"

@interface JSExportModel ()
@property (nonatomic, weak) WKWebView *webView;
-(JSExportMethod*)methodWithFuncName:(NSString*)name;
-(WKUserScript *)scriptWithKey:(NSString*)aKey;
@end

static Class kNSBlock_class() {
    static Class cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cls = NSClassFromString(@"NSBlock");
    });
    return cls;
}


@interface JSExportScriptManager ()
@property (nonatomic, copy) NSString* key;
@property (nonatomic, strong) WKUserScript *script;

@property (nonatomic, strong) JSExportModel *jsExportModel;
@property (nonatomic, strong) JSExportMethod *jsExportMethod;

@end

@implementation JSExportScriptManager

+(instancetype)methWithJSExportObject:(id)anObject andKey:(NSString*)aKey {
    if ([anObject isKindOfClass:[JSExportModel class]] && [anObject conformsToProtocol:@protocol(JSExportProtocol)]) {
        JSExportScriptManager *jsExportScriptManager = [[self alloc] init];
        jsExportScriptManager.jsExportModel = anObject;
        jsExportScriptManager.key = aKey;
        return jsExportScriptManager;
    }else
        if ([anObject isKindOfClass:kNSBlock_class()]) {
            JSExportMethod * method =[JSExportMethod methWithTarget:anObject];
            method.jsFuncName = aKey;
            JSExportScriptManager *jsExportScriptManager = [[self alloc] init];
            jsExportScriptManager.jsExportMethod = method;
            jsExportScriptManager.key = method.jsFuncName;
            return jsExportScriptManager;
        }else {
            NSString *error = [NSString stringWithFormat:@"handler类型错误，请检查%@", anObject];
            [[NSException exceptionWithName:@"JSExport Error" reason:error userInfo:nil] raise];
            return nil;
        }
}

#pragma mark - GET SET

-(WKUserScript *)script {
    if (!_script) {
        if (self.jsExportModel) {
            _script = [self.jsExportModel scriptWithKey:self.key];
        }
        if (self.jsExportMethod) {
            _script = [[WKUserScript alloc] initWithSource:[self.jsExportMethod scriptCode] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        }
    }
    return _script;
}

#pragma mark - jsHandlerCall

-(id)jsHandlerCallWithMessage:(JSExportMessage*)message {
    NSDictionary *dict = message.body;
    NSArray *params = dict[@"params"];
    WKWebView *webView = message.webView;
    JSExportMethod *method;
    if (self.jsExportModel) {
        NSString* funcName = dict[@"funcName"];
        self.jsExportModel.webView = webView;
        method = [self.jsExportModel methodWithFuncName:funcName];
    }
    if (self.jsExportMethod) {
        method = self.jsExportMethod;
    }
    if (method) {
        JSExportCallBack callBack;
        if (method.callBack) {
            callBack = [self jsExportCallBackWithMessage:dict webView:webView];
        }
       id result = [method invokeWithParams:params callBack:callBack];
        return result;
    }
    return nil;
}

-(JSExportCallBack)jsExportCallBackWithMessage:(NSDictionary*)message webView:(WKWebView*)webView {
    NSString *spaceName = message[@"spaceName"];
    NSString* funcName = message[@"funcName"];
    JSExportCallBack callBack = ^(id param){
        NSDictionary *dict = @{@"spaceName":spaceName, @"funcName":funcName, @"param":param};
        NSString *jsCode = [NSString stringWithFormat:@"%@.callBack", kJSExport_registerKey];
        [webView jsFunc:jsCode arguments:@[dict]];
    };
    return callBack;
}


-(void)addToDict:(NSMutableDictionary*)dict {
    dict[self.key] = self;
}

@end
