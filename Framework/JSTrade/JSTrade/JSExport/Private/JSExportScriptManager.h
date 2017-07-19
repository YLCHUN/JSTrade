//
//  JSExportScriptManager.h
//  JSTrade
//
//  Created by YLCHUN on 2017/7/4.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JSExportModel,JSExportMethod, WKUserScript, JSExportMessage;

@interface JSExportScriptManager : NSObject
@property (nonatomic, copy, readonly) NSString* key;
@property (nonatomic, strong, readonly) WKUserScript *script;

+(instancetype)methWithJSExportObject:(id)anObject andKey:(NSString*)aKey ;

-(void)addToDict:(NSMutableDictionary*)dict;

-(id)jsHandlerCallWithMessage:(JSExportMessage*)message;

@end
