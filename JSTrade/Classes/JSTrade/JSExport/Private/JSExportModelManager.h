//
//  JSExportModelManager.h
//  JSTrade
//
//  Created by YLCHUN on 2017/7/20.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSExportProtocol.h"

@class WKWebView,JSExportMethod,WKUserScript;

OBJC_EXTERN void setWebView(JSExportObject self, WKWebView *webView);

OBJC_EXTERN WKWebView* getWebView(JSExportObject self);

OBJC_EXTERN WKUserScript* getScriptWithKey(JSExportObject self, NSString*aKey) ;

OBJC_EXTERN JSExportMethod* getMethodWithFuncName(JSExportObject self, NSString *name);

