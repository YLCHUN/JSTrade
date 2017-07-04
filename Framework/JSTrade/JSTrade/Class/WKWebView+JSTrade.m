//
//  WKWebView+JSTrade.m
//  JSTrade
//
//  Created by YLCHUN on 2017/5/30.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "WKWebView+JSTrade.h"
#import "JSTradeCommon.h"

@implementation WKWebView (JSTrade)

-(id)jsFunc:(NSString*)func arguments:(NSArray*)arguments {
    NSString *params = [self arguments:arguments];
    NSString *jsString = [NSString stringWithFormat:@"%@(%@)", func, params];//函数转换
    id retuenValue =[self execJSCode:jsString];
    return retuenValue;
}

-(id)jsGetVar:(NSString*)var {
    NSString *jsString = var;//函数转换
    id retuenValue = [self execJSCode:jsString];
    return retuenValue;
}

-(void)jsSetVar:(NSString*)var value:(id)value {
    NSString *params = [self arguments:@[value]];
    NSString *jsString = [NSString stringWithFormat:@"%@=%@", var, params];//函数转换
    [self execJSCode:jsString];
}

-(id)execJSCode:(NSString*)jsCode {
    NSString *jsString = jsCode;//函数转换
    __block id retuenValue;
    __block BOOL isExecuted = NO;
    [self evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        retuenValue = result;
        isExecuted = YES;
        if (error) {
            NSLog(@"JSTrade_Error: %@ ❌ %@", [jsString containsString:kJSExport_registerKey] ? @"" : jsString, error);
        }
    }];
    while (isExecuted == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return retuenValue;
}

-(NSString*)arguments:(NSArray*)arguments {
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i<arguments.count; i++) {
        id p = arguments[i];
        if ([p isKindOfClass:[NSString class]]) {
            [arr addObject:[NSString stringWithFormat:@"'%@'", p]];
        }else
            if ([p isKindOfClass:[NSNumber class]]) {
                [arr addObject:[NSString stringWithFormat:@"%@", p]];
            }else
                if ([p isKindOfClass:[NSNull class]]) {
                    [arr addObject:@"null"];
                }else
                    if ([p isKindOfClass:[NSArray class]] || [p isKindOfClass:[NSDictionary class]]) {
                        [arr addObject:[self serializeMessageToJSON:p]];
                    }else {
                        NSString *tmp = [self serializeMessageToJSON:@[p]];
                        NSRange range= NSMakeRange(1,tmp.length-2);
                        tmp = [tmp substringWithRange:range];
                        [arr addObject:tmp];
                    }
        
    }
    NSString *paramsJSON = [arr componentsJoinedByString:@","];
    return paramsJSON;
}

- (NSString*)serializeMessageToJSON:(id)dictOrArr {
    NSError *error;
    NSString *jsonString = @"";
    @try {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictOrArr options:0 error:&error];
        if (jsonData){
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
        }
    } @catch (NSException *exception) {
        //object类型需要手动转换成NSDictionary
        [exception raise];
    } @finally {
        
    }
    return jsonString;
}


@end
void import_WKWebView_JSTrade() {
    
}
