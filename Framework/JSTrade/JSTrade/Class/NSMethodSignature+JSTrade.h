//
//  NSMethodSignature+JSTrade.h
//  JSTrade
//
//  Created by YLCHUN on 2017/5/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMethodSignature (JSTrade)

/**
 设置值

 @param invocation <#invocation description#>
 @param anValue 值
 @param idx ：methodSignature: idx < 0（returnValue），idx==0（self），idx == 1 （__cmd），idx > 1（参数）; blockSignature: idx==0（self），idx > 0（参数）
 */
- (void)setInvocation:(NSInvocation*)invocation value:(id)anValue atIndex:(NSInteger)idx;

/**
 获取值

 @param invocation <#invocation description#>
 @param idx ：methodSignature: idx < 0（returnValue），idx==0（self），idx == 1 （__cmd），idx > 1（参数）; blockSignature: idx==0（self），idx > 0（参数）
 @return 对应值
 */
- (id)getInvocationValue:(NSInvocation*)invocation atIndex:(NSInteger)idx;

@end

void import_NSMethodSignature_JSTrade(void);
