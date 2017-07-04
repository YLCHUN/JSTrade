//
//  NSJSONSerialization+JSTrade.m
//  JSTrade
//
//  Created by YLCHUN on 2017/5/30.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NSJSONSerialization+JSTrade.h"

@implementation NSJSONSerialization (JSTrade)

+(NSDictionary*)stringDictWithDict:(NSDictionary*)dict {
    NSMutableDictionary *resDict = [NSMutableDictionary dictionary];
    NSArray * allKeys = [dict allKeys];
    for (id key in allKeys) {
        id value = dict[key];
        if ([value isKindOfClass:[NSNumber class]]) {
            value = ((NSNumber*)value).description;
        }else
            if ([value isKindOfClass:[NSDictionary class]]) {
                value = [self stringDictWithDict:value];
            }else
                if ([value isKindOfClass:[NSArray class]]) {
                    value = [self stringArrWithArr:value];
                }else
                    if ([value isKindOfClass:[NSNull class]]) {
                        value = @"";
                    }else
                        if ([value isEqualToString:@"<null>"]) {
                            value = @"";
                        }
        resDict[key] = value;
    }
    return resDict;
}

+(NSArray *)stringArrWithArr:(NSArray*)arr {
    NSMutableArray *resArr = [NSMutableArray arrayWithCapacity:arr.count];
    for (long i = 0; i<arr.count; i++) {
        id value = arr[i];
        if ([value isKindOfClass:[NSNumber class]]) {
            value = ((NSNumber*)value).description;
        }else
            if ([value isKindOfClass:[NSDictionary class]]) {
                value = [self stringDictWithDict:value];
            }else
                if ([value isKindOfClass:[NSArray class]]) {
                    value = [self stringArrWithArr:value];
                }else
                    if ([value isEqualToString:@"<null>"]) {
                        value = @"";
                    }
        resArr[i] = value;
    }
    return resArr;
}

+ (id)unserializeJSON:(NSString *)jsonString toStringValue:(BOOL)toStringValue {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    if (!jsonData) {
        return nil;
    }
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    if (jsonObject != nil && error == nil){
        if (toStringValue) {
            if ([jsonObject isKindOfClass:[NSArray class]]) {
                jsonObject = [self stringArrWithArr:jsonObject];
            }
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                jsonObject = [self stringDictWithDict:jsonObject];
            }
        }
        return jsonObject;
    }else{
        NSLog(@"unserializeJSON: %@ \n\neror: %@",jsonString, error.description);
        // 解析错误
        return nil;
    }
}

@end
void import_NSJSONSerialization_JSTrade() {
    
}
