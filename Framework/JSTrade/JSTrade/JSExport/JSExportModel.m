//
//  JSExportModel.m
//  JSTrade
//
//  Created by YLCHUN on 2017/3/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSExportModel.h"
#import "JSExportModel_Import.h"
#import <objc/runtime.h>
#import "NSMethodSignature+JSTrade.h"
#import "WKWebView+JSTrade.h"
#import "NSJSONSerialization+JSTrade.h"
#import <WebKit/WebKit.h>
#import "JSTradeCommon.h"

#import "JSExportMethod.h"

#pragma mark -
#pragma mark - JSExportModel

@interface JSExportModel ()
@property (nonatomic, strong) NSDictionary <NSString*,JSExportMethod*> *methodDict;
@property (nonatomic, copy) NSArray <JSImportModel<JSImportProtocol> *> *jsImportModelArray;
@property (nonatomic, weak) WKWebView *webView;
@end

@implementation JSExportModel

-(instancetype)init {
    self = [super init];
    if (self) {
        [self construction];
    }
    return self;
}

-(void)construction {
    if (![self conformsToProtocol:@protocol(JSExportProtocol)]) {
        NSString *error = [NSString stringWithFormat:@"%@未实现JSExportProtocol子协议！", NSStringFromClass([self class])];
        NSAssert(NO, error);
        NSException *excp = [NSException exceptionWithName:@"JSExport Error" reason:error userInfo:nil];
        [excp raise]; // 抛出异常
    }else{
        self.jsImportModelArray = [self jsImportModels];
    }
}

-(void)dealloc {
    self.methodDict = nil;
}


#pragma mark - GET SET

-(void)setWebView:(WKWebView *)webView {
    if (_webView == webView) {
        return;
    }
    _webView = webView;
    for (JSImportModel *jsImportModel in self.jsImportModelArray) {
        jsImportModel.webView = _webView;
    }
}

-(NSDictionary<NSString *,JSExportMethod *> *)methodDict {
    NSDictionary <NSString*,JSExportMethod*> *methodDict = objc_getAssociatedObject(self, @selector(methodDict));
    if (!methodDict) {
        methodDict = [JSExportModel jsExportMethodsWithModel:self];
        self.methodDict = methodDict;
    }
    return methodDict;
}
-(void)setMethodDict:(NSDictionary<NSString *,JSExportMethod *> *)methodDict {
    objc_setAssociatedObject(self, @selector(methodDict), methodDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSArray<JSImportModel<JSImportProtocol> *> *)jsImportModelArray {
    return objc_getAssociatedObject(self, @selector(jsImportModelArray));
}

-(void)setJsImportModelArray:(NSArray<JSImportModel<JSImportProtocol> *> *)jsImportModelArray {
    objc_setAssociatedObject(self, @selector(jsImportModelArray), jsImportModelArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - JSExportProtocol analysize
+(NSDictionary<NSString *,JSExportMethod *>*)jsExportMethodsWithModel:(JSExportModel*)model {
    Protocol *jsProtocol = @protocol(JSExportProtocol);
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
        struct objc_method_description * methodList = protocol_copyMethodDescriptionList(jsProtocol, YES, YES, &listCount);
        NSMutableArray *methodArray = [NSMutableArray arrayWithCapacity:listCount];
        NSMutableDictionary *methodDict = [NSMutableDictionary dictionary];
        NSMutableDictionary *modelMethodDict = [NSMutableDictionary dictionary];
        
        for(int i=0;i<listCount;i++) {
            SEL sel = methodList[i].name;
            NSString *selName = NSStringFromSelector(sel);
            JSExportMethod *method = [JSExportMethod methWithTarget:model sel:sel];
            NSString *jsFuncName;
            if (method.callBack) {
                jsFuncName = [selName componentsSeparatedByString:@":"][0];
            }else{
                jsFuncName = [selName stringByReplacingOccurrencesOfString:@":" withString:@""];
            }
            method.jsFuncName = jsFuncName;
            methodArray[i] = method;
            methodDict[selName] = method;
            modelMethodDict[jsFuncName] = method;
        }
        free(methodList);
        struct objc_method_description * methodListAs = protocol_copyMethodDescriptionList(jsProtocol, NO, YES, &listCount);
        for(int i=0;i<listCount;i++) {
            SEL sel = methodListAs[i].name;
            NSString *selName = NSStringFromSelector(sel);
            if ([selName containsString:@"__JS_EXPORT_AS__"]) {
                NSArray *keys = [selName componentsSeparatedByString:@"__JS_EXPORT_AS__"];
                NSString *selName = keys[0];
                JSExportMethod *method = methodDict[selName];
                [modelMethodDict removeObjectForKey:method.jsFuncName];
                NSString *selNameAs = keys[1];
                NSString *jsFuncName = [selNameAs stringByReplacingOccurrencesOfString:@":" withString:@""];
                method.jsFuncName = jsFuncName;
                modelMethodDict[jsFuncName] = method;
            }
        }
        free(methodListAs);
        return modelMethodDict;
    }else{
        return nil;
    }
}

#pragma mark - WKUserScript
-(WKUserScript *)scriptWithKey:(NSString*)aKey {
    NSString *jsCode = [self jsExportCodeWithKey:aKey];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    return script;
}

-(NSString*)jsExportCodeWithKey:(NSString*)aKey {
    NSArray *methods = [self.methodDict allValues];
    NSMutableString *jsExportModelString = [NSMutableString string];
    [jsExportModelString appendFormat:@"window.%@ = {\n", aKey];
    [jsExportModelString appendFormat:@"spaceName: '%@',\n", aKey];
    NSMutableArray *funcArray = [NSMutableArray array];
    for (JSExportMethod *method in methods) {
        [funcArray addObject:[method scriptCode]];
    }
    [jsExportModelString appendString:[funcArray componentsJoinedByString:@",\n"]];
    [jsExportModelString appendString:@"}\n"];
    return jsExportModelString;
}

#pragma mark -

-(JSExportMethod*)methodWithFuncName:(NSString*)name {
    return self.methodDict[name];
}

-(id)callJSFunc:(NSString*)jsFunc arguments:(NSArray*)arguments {
    return [self.webView jsFunc:jsFunc arguments:arguments];
}

- (id)unserializeJSON:(NSString *)jsonString toStringValue:(BOOL)toStringValue {
    return [NSJSONSerialization unserializeJSON:jsonString toStringValue:toStringValue];
}

-(NSArray <JSImportModel<JSImportProtocol> *> *)jsImportModels {
    return nil;
}

@end
void import_JSExportModel(){
    
}
