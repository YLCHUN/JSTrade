//
//  JSTrade.h
//  JSTrade
//
//  Created by YLCHUN on 2017/5/29.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#define FOUNDATION_IMPORT_JSTRADE void import_JSTrade(void);\
__attribute__((used)) static void importJSTrade (void) {\
    import_JSTrade();\
}

#import "JSExport.h"
#import "JSImport.h"

FOUNDATION_IMPORT_JSTRADE

//! Project version number for JSTrade.
FOUNDATION_EXPORT double JSTradeVersionNumber;

//! Project version string for JSTrade.
FOUNDATION_EXPORT const unsigned char JSTradeVersionString[];

