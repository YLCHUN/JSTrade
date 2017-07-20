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

void setWebView(JSExportObject self, WKWebView *webView);
WKWebView* getWebView(JSExportObject self);

WKUserScript* getScriptWithKey(JSExportObject self, NSString*aKey) ;

JSExportMethod* getMethodWithFuncName(JSExportObject self, NSString *name);

