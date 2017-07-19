//
//  JSExportModel.h
//  JSTrade
//
//  Created by YLCHUN on 2017/3/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSImport.h"

#define JSExportAs(PropertyName, Selector) \
@optional Selector __JS_EXPORT_AS__##PropertyName:(id)argument NS_UNAVAILABLE; @required Selector

/**
 JSExportProtocol 
 多个JSExportProtocol协议只支持第一个
 函数最多 一个callBack返回值，且为最后一个参数
 */
@protocol JSExportProtocol <NSObject>
//-(void)func0;                                 //window.<#spaceName#>.func0();
//-(void)func1:(id)p;                           //window.<#spaceName#>.func1(<#param#>);
//-(void)func2:(JSExportCallBack)cb;            //window.<#spaceName#>.func2(function(param){});
//-(void)func3:(id)p cb:(JSExportCallBack)cb;   //window.<#spaceName#>.func3(<#param#>, function(param){});

//      JSExportAs(doFoo,
//           - (void)doFoo:(id)foo withBar:(id)bar
//           );//window.<#spaceName#>.doFoo(foo,bar);

//若直接return函数方法体内需要调用js函数，需要在子线程执行或者采用[JSExportManager asyncCallJSAfterReturn:^{<#callJSCode#>}]
//-(id)func0;                                 //var res = window.<#spaceName#>.func0();
@end

@class WKWebView;

typedef void(^JSExportCallBack) (id object);

@interface JSExportModel : NSObject

/**
 webView 弱引用，当JSExportProtocol函数被响应时候才会有值
 */
@property (nonatomic, weak, readonly) WKWebView *webView;

- (id)unserializeJSON:(NSString *)jsonString toStringValue:(BOOL)toStringValue;

/**
 由子类实现，不需要执行super方法，不建议直接调用

 @return jsImportModels
 */
-(NSArray <JSImportModel<JSImportProtocol> *> *)jsImportModels;


@end
