//
//  JSExportManager.h
//  JSTrade
//
//  Created by YLCHUN on 2017/6/30.
//  Copyright © 2017年 ylchun. All rights reserved.
//
//  js调用oc函数返回值传递建议采用JSExportCallBack
//  直接return需要考虑js执行锁（在return执行之前执行js）,可采用[JSExportManager asyncCallJSAfterReturn:^{<#callJSCode#>}]或者子线程发起调用。

#import <Foundation/Foundation.h>
#import "JSExportModel.h"
#import <WebKit/WKUserContentController.h>

@interface JSExportManager : NSObject

/**
 删除一个JSExport handler

 @param aKey 对应key
 */
- (void)removeObjectForKey:(NSString*)aKey;

/**
 设置JSExport handler
 每次设置前会移除旧值，每次更新需要新加载页面
 
 @param anObject JSExportModel<JSExportProtocol>* 或者 Block
 若直接return函数方法体内需要调用js函数，需要在子线程执行或者采用[JSExportManager asyncCallJSAfterReturn:^{<#callJSCode#>}]
 @param aKey model 对应objectName 或者 Block 对应的funcName
 */
- (void)setObject:(id)anObject forKeyedSubscript:(NSString*)aKey;

/**
 移除所有JSExport handler
 */
- (void)removeAllHandler;

/**
 异步调用js函数（子线程）
 
 @param code 调用代码
 */
+(void)asyncCallJSAfterReturn:(void(^)(void))code;

@end

@interface WKUserContentController (JSExport)

/**
 设置JSExportManager，每次更新需要重新加载页面
 */
@property (nonatomic, strong) JSExportManager *jsExportManager;

@end
