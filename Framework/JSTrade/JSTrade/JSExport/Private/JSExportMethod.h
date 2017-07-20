//
//  JSExportMethod.h
//  JSTrade
//
//  Created by YLCHUN on 2017/7/4.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSExportProtocol.h"
typedef id JSExportBlock;

@interface JSExportMethod : NSObject
@property (nonatomic, copy) NSString *jsFuncName;
@property (nonatomic, assign, readonly) BOOL callBack;
@property (nonatomic, copy, readonly) NSString *scriptCode;


/**
 JSExportModel method

 @param target JSExportModel
 @param sel sel
 @return JSExportModel
 */
+(instancetype)methWithTarget:(JSExportObject)target sel:(SEL)sel;


/**
 JSExportBlock method

 @param target JSExportBlock
 @return JSExportModel
 */
+(instancetype)methWithTarget:(JSExportBlock)target;


/**
 invoke method

 @param params params
 @param callBack callBack = YES 时候
 @return 结果
 */
- (id)invokeWithParams:(NSArray *)params callBack:(JSExportCallBack)callBack;

@end
