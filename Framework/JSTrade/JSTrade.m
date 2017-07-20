//
//  JSTrade.c
//  JSTrade
//
//  Created by YLCHUN on 2017/6/2.
//  Copyright © 2017年 ylchun. All rights reserved.
//
//  编译器识别分类代码

#import "JSTrade.h"
#import "JSExportManager_Import.h"

#import "JSTradeSourceShield.h"
#import "NSMethodSignature+JSTrade.h"
#import "NSJSONSerialization+JSTrade.h"
#import "WKWebView+JSTrade.h"


void import_JSTrade() {
    import_JSExportManager();

    import_JSTradeSourceShield();
    import_NSMethodSignature_JSTrade();
    import_NSJSONSerialization_JSTrade();
    import_WKWebView_JSTrade();
}
