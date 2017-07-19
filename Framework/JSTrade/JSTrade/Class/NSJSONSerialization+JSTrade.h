//
//  NSJSONSerialization+JSTrade.h
//  JSTrade
//
//  Created by YLCHUN on 2017/5/30.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (JSTrade)

/**
 解析JSON字符串

 @param jsonString json字符串
 @param toStringValue YES 子项转换成NSString
 @return 字典或数组
 */
+ (id)unserializeJSON:(NSString *)jsonString toStringValue:(BOOL)toStringValue;

/**
 对象转JSON字符串

 @param dictOrArr <#dictOrArr description#>
 @return json
 */
+ (NSString*)serializeDictOrArr:(id)dictOrArr;

@end
void import_NSJSONSerialization_JSTrade(void);
