//
//  JSExportManager.h
//  JSTrade
//
//  Created by YLCHUN on 2017/6/30.
//  Copyright © 2017年 ylchun. All rights reserved.
//

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
 @param aKey model 对应objectName 或者 Block 对应的funcName
 */
- (void)setObject:(id)anObject forKeyedSubscript:(NSString*)aKey;

/**
 移除所有JSExport handler
 */
- (void)removeAllHandler;

@end

@interface WKUserContentController (JSExport)

/**
 设置JSExportManager，每次更新需要重新加载页面
 */
@property (nonatomic, strong) JSExportManager *jsExportManager;

@end
