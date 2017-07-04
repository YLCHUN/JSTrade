//
//  JSImportModel.m
//  JSTrade
//
//  Created by YLCHUN on 2017/5/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSImportModel.h"
#import "JSImportModel_Import.h"
#import "JSImportMethod.h"
#import <objc/runtime.h>
#import "NSMethodSignature+JSTrade.h"
#import "WKWebView+JSTrade.h"
#import "NSJSONSerialization+JSTrade.h"

#pragma mark -
#pragma mark - JSImportModel

@interface JSImportModel ()
@property (nonatomic, copy) NSString* spaceName;
@property (nonatomic, strong) NSDictionary<NSString *, JSImportMethod *> *methodDict;
@end

@implementation JSImportModel

-(instancetype)init {
    self = [super init];
    if (self) {
        [self construction];
    }
    return self;
}

-(instancetype)initWithSpaceName:(NSString*)name {
    self = [super init];
    if (self) {
        self.spaceName = name;
        [self construction];
    }
    return self;
}

-(void)dealloc {
    self.methodDict = nil;
}

-(void)construction {
    if (![self conformsToProtocol:@protocol(JSImportProtocol)]) {
        NSString *error = [NSString stringWithFormat:@"%@未实现JSImportProtocol子协议！", NSStringFromClass([self class])];
        [[NSException exceptionWithName:@"JSImport Error" reason:error userInfo:nil]raise];
    }else{
        [JSImportModel jsImportMethodsWithModel:(JSImportModel<JSImportProtocol>*)self];
    }
}


#pragma mark - GET SET

-(NSString *)spaceName {
    return objc_getAssociatedObject(self, @selector(spaceName));
}
-(void)setSpaceName:(NSString *)spaceName {
    objc_setAssociatedObject(self, @selector(spaceName), spaceName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(NSDictionary<NSString *,JSImportMethod *> *)methodDict {
    return objc_getAssociatedObject(self, @selector(methodDict));
}
-(void)setMethodDict:(NSDictionary<NSString *,JSImportMethod *> *)methodDict {
    objc_setAssociatedObject(self, @selector(methodDict), methodDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - forward

-(void)forwardFunction {
    
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    NSString *selName = NSStringFromSelector(anInvocation.selector);
    JSImportMethod *method = [self.methodDict objectForKey:selName];
    if (method) {
        if (!anInvocation.argumentsRetained) {
            [anInvocation retainArguments];
        }
        NSMethodSignature *signature = anInvocation.methodSignature;
        
        NSString *jsFuncName = self.spaceName.length>0 ? [NSString stringWithFormat:@"%@.%@", self.spaceName, method.jsFuncName] : method.jsFuncName;
        id returnValue;
        if (method.isVar) {
            if (method.isSet) {
                id param = [signature getInvocationValue:anInvocation atIndex:2];
                if (!param) {
                    param = [[NSNull alloc] init];
                }
                [self.webView jsSetVar:jsFuncName value:param];
            }else{
                returnValue = [self.webView jsGetVar:jsFuncName];
            }
        }else{
            NSInteger paramsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
            NSMutableArray * params = [NSMutableArray array];
            for (NSInteger i = 0; i < paramsCount; i++) {
                id argument = [signature getInvocationValue:anInvocation atIndex:i + 2];
                if (!argument) {
                    argument = [[NSNull alloc] init];
                }
                [params addObject:argument];
            }
            returnValue = [self.webView jsFunc:jsFuncName arguments:params];
        }
        anInvocation.selector = @selector(forwardFunction);
        [anInvocation invoke];
        
        if (signature.methodReturnLength>0) {
            [signature setInvocation:anInvocation value:returnValue atIndex:-1];
        }
    }else {
        [super forwardInvocation:anInvocation];
    }
}

#pragma mark - JSImportProtocol analysize
+(void)jsImportMethodsWithModel:(JSImportModel<JSImportProtocol>*)model {
    Protocol *jsProtocol = @protocol(JSImportProtocol);
    Class cls = [model class];
    if (class_conformsToProtocol(cls,jsProtocol)){
        unsigned int listCount = 0;
        Protocol * __unsafe_unretained *protocolList =  class_copyProtocolList(cls, &listCount);
        for (int i = 0; i < listCount; i++) {
            Protocol *protocol = protocolList[i];
            if(protocol_conformsToProtocol(protocol, jsProtocol)) {
                jsProtocol = protocol;
                break;
            }
        }
        free(protocolList);
        struct objc_method_description * methodList = protocol_copyMethodDescriptionList(jsProtocol, NO, YES, &listCount);
        NSMutableDictionary *methodDict = [NSMutableDictionary dictionary];
        NSMutableArray *varNameArray = [NSMutableArray array];
        for(int i=0;i<listCount;i++) {
            SEL sel = methodList[i].name;
            NSString *selName = NSStringFromSelector(sel);
            NSString *jsFuncName;
            JSImportMethod *method;
            
            if (![selName containsString:@"__JS_IMPORT_AS_"]) {
                method = methodDict[selName];
                if (!method) {
                    method = [[JSImportMethod alloc] init];
                    methodDict[selName] = method;
                }
                method.sel = sel;
                method.selName  = selName;
                char *type = methodList[i].types;
                NSString *selTypes = [NSString stringWithUTF8String:type];
                
                if ([selTypes containsString:@":"]) {
                    NSArray *arr = [selName componentsSeparatedByString:@":"];
                    if ((arr.count>2 && method.isAs) || (method.isVar && method.isAs)) {
                        continue;
                    }else{
                        jsFuncName = arr[0];
                    }
                }else{
                    jsFuncName = selName;
                }
                method.jsFuncName = jsFuncName;
            }else{
                if ([selName containsString:@"__JS_IMPORT_AS__"]) {
                    NSArray *keys = [selName componentsSeparatedByString:@"__JS_IMPORT_AS__"];
                    selName = keys[0];
                    NSString *selNameAs = keys[1];
                    jsFuncName = [selNameAs stringByReplacingOccurrencesOfString:@":" withString:@""];
                    method = methodDict[selName];
                    if (!method) {
                        method = [[JSImportMethod alloc] init];
                        methodDict[selName] = method;
                    }
                    method.isAs = YES;
                    method.jsFuncName = jsFuncName;
                } else {//__JS_IMPORT_AS_VAR_
                    [varNameArray addObject:selName];
                    BOOL isSet = NO;
                    NSString *getName = selName;
                    if ([selName hasPrefix:@"set"]) {
                        NSString *tmp =  [selName substringWithRange:NSMakeRange(3, selName.length-4)];
                        if ([varNameArray containsObject:tmp]) {
                            getName = tmp;
                            isSet = YES;
                        }else{
                            tmp = [tmp stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[tmp substringToIndex:1] lowercaseString]];
                            if ([varNameArray containsObject:tmp]) {
                                getName = tmp;
                                isSet = YES;
                            }
                        }
                    }
                    if ([selName containsString:@"__JS_IMPORT_AS_VAR_AS__"]) {
                        jsFuncName = [getName componentsSeparatedByString:@"__JS_IMPORT_AS_VAR_AS__"][1];
                        selName = [selName componentsSeparatedByString:@"__JS_IMPORT_AS_VAR_AS__"][0];
                        if (isSet) {
                            selName = [selName stringByAppendingString:@":"];
                        }
                    }else {
                        jsFuncName = [getName stringByReplacingOccurrencesOfString:@"__JS_IMPORT_AS_VAR__" withString:@""];
                        selName = [selName stringByReplacingOccurrencesOfString:@"__JS_IMPORT_AS_VAR__" withString:@""];
                    }
                    method = methodDict[selName];
                    if (!method) {
                        method = [[JSImportMethod alloc] init];
                        methodDict[selName] = method;
                    }
                    method.isSet = isSet;
                    method.isVar = YES;
                    method.jsFuncName = jsFuncName;
                    method.isAs = YES;
                }
            }
        }
        free(methodList);
        model.methodDict = methodDict;
    }
}

#pragma mark -
- (id)unserializeJSON:(NSString *)jsonString toStringValue:(BOOL)toStringValue {
    return [NSJSONSerialization unserializeJSON:jsonString toStringValue:toStringValue];
}
@end

void import_JSImportModel() {}
