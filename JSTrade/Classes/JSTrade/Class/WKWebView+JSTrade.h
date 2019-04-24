//
//  WKWebView+JSTrade.h
//  JSTrade
//
//  Created by YLCHUN on 2017/5/30.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <WebKit/WKWebView.h>

@interface WKWebView (JSTrade)

/**
 调用js函数
 
 @param func js函数名 model.function() 或者 function()
 @param arguments 参数
 @return 执行结果
 */
-(id _Nullable)jsFunc:(NSString* _Nonnull)func arguments:(NSArray* _Nonnull)arguments;

/**
 js属性值获取

 @param var 属性名
 @return 值
 */
-(id _Nullable)jsGetVar:(NSString* _Nonnull)var;

/**
 js属性值设置

 @param var 属性名
 @param value 值,nil 时候采用 NSNull
 */
-(void)jsSetVar:(NSString* _Nonnull)var value:(id _Nonnull)value;
@end

void import_WKWebView_JSTrade(void);
