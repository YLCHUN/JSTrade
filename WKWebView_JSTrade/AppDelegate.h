//
//  AppDelegate.h
//  WKWebView_JSTrade
//
//  Created by YLCHUN on 2017/5/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <UIKit/UIKit.h>
#define JSImportVar(Type,Property )\
Type Property##__JS_IMPORT_VAR__##Property NS_UNAVAILABLE;  Type Property

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

JSImportVar(
         @property (strong, nonatomic) NSString *, var
);

@end

