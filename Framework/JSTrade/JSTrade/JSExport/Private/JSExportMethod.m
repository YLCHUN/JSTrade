//
//  JSExportMethod.m
//  JSTrade
//
//  Created by YLCHUN on 2017/7/4.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSExportMethod.h"
#import "JSTradeCommon.h"
#import "NSMethodSignature+JSTrade.h"

typedef NS_OPTIONS(int, JSHandlerBlockFlags) {
    JSHandlerBlockFlagsHasCopyDisposeHelpers = (1 << 25),
    JSHandlerBlockFlagsHasSignature          = (1 << 30)
};
typedef struct _JSHandlerBlock {
    __unused Class isa;
    JSHandlerBlockFlags flags;
    __unused int reserved;
    void (__unused *invoke)(struct _JSHandlerBlock *block, ...);
    struct {
        unsigned long int reserved;
        unsigned long int size;
        void (*copy)(void *dst, const void *src);
        void (*dispose)(const void *);
        const char *signature;
        const char *layout;
    } *descriptor;
} *JSHandlerBlockRef;


NSString* JSExportCallBack_encode(){
    static NSString *kEncode;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kEncode = [NSString stringWithUTF8String:@encode(JSExportCallBack)];
    });
    return kEncode;
}


@interface JSExportMethod ()
@property (nonatomic, weak) id target_model;
@property (nonatomic) SEL sel_model;

@property (nonatomic, copy) id target_block;

@property (nonatomic, strong) NSMethodSignature *signature;
@property (nonatomic, assign) BOOL callBack;
@property (nonatomic, assign) NSUInteger indexOffset;
@property (nonatomic, copy) NSString *scriptCode;
@end

@implementation JSExportMethod

+(instancetype)methWithTarget:(id)target sel:(SEL)sel {
    JSExportMethod *jsExportMethod = [[self alloc] init];
    jsExportMethod.target_model = target;
    jsExportMethod.sel_model = sel;
    jsExportMethod.indexOffset = 2;//self, _com, arguments...
    return jsExportMethod;
}

+(instancetype)methWithTarget:(JSExportBlock)target {
    JSExportMethod *jsExportMethod = [[self alloc] init];
    jsExportMethod.target_block = target;
    jsExportMethod.indexOffset = 1;//self, arguments...
    return jsExportMethod;
}

#pragma mark - GET SET

-(BOOL)callBack {
    if (!_signature) {
        [self signature];
    }
    return _callBack;
}

-(NSMethodSignature *)signature {
    if (!_signature) {
        if (self.target_model) {
            _signature = [self.target_model methodSignatureForSelector:self.sel_model];
        }else{
            _signature = [self methodSignatureForBlock:self.target_block];
        }
        const char *encode = [_signature getArgumentTypeAtIndex:_signature.numberOfArguments - 1];
        NSString *lastEncode = [NSString stringWithUTF8String:encode];
        _callBack = [lastEncode containsString:JSExportCallBack_encode()];
    }
    return _signature;
}

-(NSString *)scriptCode {
    if (!_scriptCode) {
        NSString *isRetuen = self.signature.methodReturnLength>0?@"true":@"false";
        if (self.sel_model) {
            _scriptCode = [NSString stringWithFormat:@"%@: function() {\n\
                           funcName = '%@';\n\
                           return window.%@.transfer(this.spaceName, funcName, arguments, %@);\n\
                           }\n", self.jsFuncName, self.jsFuncName, kJSExport_registerKey, isRetuen];
        }else {
            _scriptCode = [NSString stringWithFormat:@"function %@() {\n\
                           funcName = '%@';\n\
                           return window.%@.transfer(funcName, funcName, arguments, %@);\n\
                           }\n", self.jsFuncName, self.jsFuncName, kJSExport_registerKey, isRetuen];
        }
    }
    return _scriptCode;
}

#pragma mark - invokeWithParams

- (id)invokeWithParams:(NSArray *)params callBack:(JSExportCallBack)callBack {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:self.signature];
    if (self.sel_model) {
        invocation.target = self.target_model;
        invocation.selector = self.sel_model;
    }else{
        invocation.target = self.target_block;
    }
    NSInteger paramsCount = self.signature.numberOfArguments - self.indexOffset;
    for (NSInteger i = 0; i < paramsCount; i++) {
        id param;
        if (i == paramsCount-1) {
            if(callBack) {
                param = callBack;
            }else{
                if (params.count>i) {
                    param = params[i];
                }
            }
        }else{
            if (params.count>i) {
                param = params[i];
            }
        }
        if (!param || [param isKindOfClass:[NSNull class]]){
            continue;
        }
        [self.signature setInvocation:invocation value:param atIndex:i + self.indexOffset];
    }
    [invocation invoke];
    id returnValue = nil;
    if (self.signature.methodReturnLength) {
       returnValue = [self.signature getInvocationValue:invocation atIndex:-1];
    }
    return returnValue;
}

#pragma mark -

-(NSMethodSignature*)methodSignatureForBlock:(id)block {
    JSHandlerBlockRef layout = (__bridge void *)block;
    if (!(layout->flags & JSHandlerBlockFlagsHasSignature)) {
        return nil;
    }
    void *desc = layout->descriptor;
    desc += 2 * sizeof(unsigned long int);
    if (layout->flags & JSHandlerBlockFlagsHasCopyDisposeHelpers) {
        desc += 2 * sizeof(void *);
    }
    if (!desc) {
        return nil;
    }
    const char *signature = (*(const char **)desc);
    return [NSMethodSignature signatureWithObjCTypes:signature];
}
@end
