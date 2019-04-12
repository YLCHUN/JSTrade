//
//  NSJSONSerialization+JSTrade.m
//  JSTrade
//
//  Created by YLCHUN on 2017/5/30.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NSJSONSerialization+JSTrade.h"
#import <objc/runtime.h>

@implementation NSJSONSerialization (JSTrade)

static id toValueString(id value) {
    if (!value) return nil;
    
    if ([value isKindOfClass:[NSNull class]]) return nil;
    
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"<null>"]) return nil;
        return value;
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@", value];
    }
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *resDict = [NSMutableDictionary dictionary];
        [value enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            resDict[key] = toValueString(obj);
        }];
        if (resDict.count == 0) return nil;
        return resDict;
    }
    
    if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *resArr = [NSMutableArray array];
        [value enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id val = toValueString(obj);
            if (val) [resArr addObject:val];
        }];
        if (resArr.count == 0) return nil;
        return resArr;
    }
    
    NSMutableDictionary *resDict = [NSMutableDictionary dictionary];
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList([value class], &count);
    for(int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(propertyList[i])];
        id obj = [value valueForKey:key];
        resDict[key] = toValueString(obj);
    }
    if (resDict.count == 0) return nil;
    return resDict;
}

+ (id)unserializeJSON:(NSString *)jsonString toStringValue:(BOOL)toStringValue {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData.length == 0)  return nil;
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    if (error) {// 解析错误
        NSLog(@"unserializeJSON: %@ \n\neror: %@",jsonString, error.description);
        return nil;
    }
    if (toStringValue) {
        return toValueString(jsonObject);
    }
    return jsonObject;
}


+ (NSString*)serializeToJSON:(id)dictOrArr {
    NSString *jsonString = @"";
    @try {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictOrArr options:0 error:&error];
        if (error) {
            NSLog(@"unserializeToJSON: %@ \n\neror: %@",dictOrArr, error.description);
        }
        else if (jsonData.length > 0){
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//去除掉首尾的空白字符和换行字符
        }
    } @catch (NSException *exception) {
        //object类型需要手动转换成NSDictionary
        [exception raise];
    } @finally {
        return jsonString;
    }
}

@end
void import_NSJSONSerialization_JSTrade() {
    
}
