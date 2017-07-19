//
//  JSExportManager.m
//  JSTrade
//
//  Created by YLCHUN on 2017/6/30.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "JSExportManager.h"
#import "JSExportManager_Import.h"
#import <objc/runtime.h>
#import "JSTradeCommon.h"
#import <WebKit/WebKit.h>
#import "NSMethodSignature+JSTrade.h"
#import "JSExportMethod.h"
#import "JSExportScriptManager.h"
#import "JSExportMessage.h"
#import "NSJSONSerialization+JSTrade.h"

NSString* jsExportHandlerCode (){
    static NSString *jsExportModelString;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jsExportModelString = [NSString stringWithFormat:@"window.%@ = {\n\
                                        callBackHandlers: {},\n\
                                                callBack: function(params) {\n\
                                                    var spaceName = params.spaceName;\n\
                                                    var funcName = params.funcName;\n\
                                                    var param = params.param;\n\
                                                    var key = spaceName + '_' + funcName;\n\
                                                    var callBack = this.callBackHandlers[key];\n\
                                                    if (callBack) {\n\
                                                        callBack(param);\n\
                                                    }\n\
                                                },\n\
                               \n\
                                            holdCallBack: function(spaceName, funcName, callBack) {\n\
                                                var key = spaceName + '_' + funcName;\n\
                                                if ((callBack && key) && (this.callBackHandlers[key] != callBack)) {\n\
                                                    this.callBackHandlers[key] = callBack;\n\
                                                }\n\
                                            },\n\
                               \n\
                                              callWebKit: function(spaceName, funcName, params, isReturn, callBack) {\n\
                                                  if (callBack) {\n\
                                                      this.holdCallBack(spaceName, funcName, callBack);\n\
                                                  }\n\
                                                  var message = {};\n\
                                                  message['spaceName'] = spaceName;\n\
                                                  message['funcName'] = funcName;\n\
                                                  if (params) {\n\
                                                      message['params'] = params;\n\
                                                  }\n\
                                                  if (isReturn) {\n\
                                                      return this.doWebKit_prompt(message);\n\
                                                  } else {\n\
                                                      this.doWebKit_post(message);\n\
                                                  }\n\
                                              },\n\
                               \n\
                                           doWebKit_post: function(message) {\n\
                                               window.webkit.messageHandlers.%@.postMessage(message);\n\
                                           },\n\
                                         doWebKit_prompt: function(message) {\n\
                                             var message_json = JSON.stringify(message);\n\
                                             var result_json = prompt('%@', message_json);\n\
                                             var result = JSON.parse(result_json);\n\
                                             var res = result['result'];\n\
                                             return res;\n\
                                         },\n\
                               \n\
                                                transfer: function(spaceName, funcName, funcArguments, isReturn) {\n\
                                                    var params = new Array();\n\
                                                    var callBack;\n\
                                                    for (var i = 0; i < funcArguments.length; i++) {\n\
                                                        var funcArgument = funcArguments[i];\n\
                                                        var isFunc = typeof funcArgument == 'function';\n\
                                                        if (i == funcArguments.length - 1) {\n\
                                                            if (isFunc) {\n\
                                                                callBack = funcArgument;\n\
                                                            } else {\n\
                                                                params[i] = funcArgument;\n\
                                                            }\n\
                                                        } else {\n\
                                                            if (isFunc) {\n\
                                                                params[i] = null;\n\
                                                            } else {\n\
                                                                params[i] = funcArgument;\n\
                                                            }\n\
                                                        }\n\
                                                    }\n\
                                                    return this.callWebKit(spaceName, funcName, params, isReturn, callBack);\n\
                                                }\n\
                               }", kJSExport_registerKey, kJSExport_registerKey, kJSExport_registerKey];
    });
    return jsExportModelString;
}

#pragma mark -
#pragma mark - JSExportManager
@class _JSExportManager;

@interface JSExportManager ()
@property (nonatomic, strong) _JSExportManager* manager;
@property (nonatomic, weak) WKUserContentController *userContentController;
@property (nonatomic, strong) WKUserScript *managerScript;
@property (nonatomic, strong) NSMutableDictionary <NSString*, JSExportScriptManager*>*handlerDict;
@end

#pragma mark -
#pragma mark - _JSExportManager

@interface _JSExportManager : NSObject <WKScriptMessageHandler, WKUIDelegate>
@property (nonatomic, weak) JSExportManager *manager;
@property (nonatomic, weak) id UIDelegateReceiver;
@end
@implementation _JSExportManager

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:kJSExport_registerKey]) {
        NSDictionary *dict = message.body;
        NSString *spaceName = dict[@"spaceName"];
        if (spaceName.length>0) {
            JSExportMessage *msg = [[JSExportMessage alloc] initWithWebView:message.webView message:dict];
            JSExportScriptManager *sm = self.manager.handlerDict[spaceName];
            [sm jsHandlerCallWithMessage:msg];
        }
    }
}

#pragma mark - UIDelegate Prompt
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    if ([prompt isEqualToString:kJSExport_registerKey]) {
        id resault;
        NSDictionary *dict = [NSJSONSerialization unserializeJSON:defaultText toStringValue:NO];
        NSString *spaceName = dict[@"spaceName"];
        if (spaceName.length>0) {
            JSExportMessage *msg = [[JSExportMessage alloc] initWithWebView:webView message:dict];
            JSExportScriptManager *sm = self.manager.handlerDict[spaceName];
            resault = [sm jsHandlerCallWithMessage:msg];
        }
        NSMutableDictionary *res = [NSMutableDictionary dictionary];
        res[@"funcName"] = dict[@"funcName"];
        res[@"result"] = [resault?resault:[NSNull alloc] init];;
        NSString *resault_json = [NSJSONSerialization serializeDictOrArr:res];
        completionHandler(resault_json);
    }else{
        if ([self.UIDelegateReceiver respondsToSelector:_cmd]) {
            [self.UIDelegateReceiver webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
        }
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return self;
    }
    if (self.UIDelegateReceiver && [self.UIDelegateReceiver respondsToSelector:aSelector]) {
        return self.UIDelegateReceiver;
    }
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (self.UIDelegateReceiver && [self.UIDelegateReceiver respondsToSelector:aSelector]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}
@end

#pragma mark -
#pragma mark - JSExportManager

@implementation JSExportManager

#pragma mark - GET SET

-(_JSExportManager *)manager {
    if (!_manager) {
        _manager = [[_JSExportManager alloc] init];
        _manager.manager = self;
    }
    return _manager;
}

-(WKUserScript *)managerScript {
    if (!_managerScript) {
        NSString *jsCode = jsExportHandlerCode();
        _managerScript = [[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    }
    return _managerScript;
}

-(NSMutableDictionary<NSString *,JSExportScriptManager*> *)handlerDict {
    NSMutableDictionary<NSString *,JSExportScriptManager*> *handlerDict = objc_getAssociatedObject(self, @selector(handlerDict));
    if (!handlerDict) {
        handlerDict = [NSMutableDictionary dictionary];
        self.handlerDict = handlerDict;
    }
    return handlerDict;
}
-(void)setHandlerDict:(NSMutableDictionary<NSString *,JSExportScriptManager *> *)handlerDict {
    objc_setAssociatedObject(self, @selector(handlerDict), handlerDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setUserContentController:(WKUserContentController *)userContentController {
    if (userContentController == _userContentController) {
        return;
    }
    if (_userContentController) {
        [self _removeAllHandlerOnlyUserContentController];
        [_userContentController removeScriptMessageHandlerForName:kJSExport_registerKey];
    }
    _userContentController = userContentController;
    [_userContentController addScriptMessageHandler:self.manager name:kJSExport_registerKey];
    [_userContentController addUserScript:self.managerScript];
    if (self.handlerDict) {
        NSArray<JSExportScriptManager*> *allSM = [self.handlerDict allValues];
        for (JSExportScriptManager *sm in allSM) {
            [_userContentController addUserScript:sm.script];
        }
    }
}

#pragma mark -

- (void)removeObjectForKey:(NSString*)aKey {
    [self _removeObjectForKeyOnlyUserContentController:aKey];
    [self.handlerDict removeObjectForKey:aKey];
}

- (void)_removeObjectForKeyOnlyUserContentController:(NSString*)aKey {
    JSExportScriptManager* sm = self.handlerDict[aKey];
    NSMutableArray *userScripts = [self.userContentController.userScripts mutableCopy];
    if ([userScripts containsObject:sm.script]) {
        [userScripts removeObject:sm.script];
        [self.userContentController removeAllUserScripts];
        for (WKUserScript *userScript in userScripts) {
            [self.userContentController addUserScript:userScript];
        }
    }
}

- (void)setObject:(id)anObject forKeyedSubscript:(NSString*)aKey {
    if (aKey.length>0) {
        NSRange _range = [aKey rangeOfString:@" "];
        if (_range.location != NSNotFound) {
            NSString *error = [NSString stringWithFormat:@"key格式错误，请检查%@", aKey];
            [[NSException exceptionWithName:@"JSExport Error" reason:error userInfo:nil] raise];
            return;
        }
        [self removeObjectForKey:aKey];
        if (anObject) {
            JSExportScriptManager *jsExportScriptManager = [JSExportScriptManager methWithJSExportObject:anObject andKey:aKey];
            [jsExportScriptManager addToDict:self.handlerDict];
            if (self.userContentController && jsExportScriptManager) {
                [self.userContentController addUserScript:jsExportScriptManager.script];
            }
        }
    }
}

- (void)removeAllHandler {
    [self _removeAllHandlerOnlyUserContentController];
    [self.handlerDict removeAllObjects];
}

- (void)_removeAllHandlerOnlyUserContentController {
    NSMutableArray<JSExportScriptManager*> *allSM = [[self.handlerDict allValues] mutableCopy];
    NSMutableArray *userScripts = [self.userContentController.userScripts mutableCopy];
    NSInteger uCount = userScripts.count;
    for (JSExportScriptManager* sm in allSM){
        if ([userScripts containsObject:sm.script]) {
            [userScripts removeObject:sm.script];
        }
    }
    if ([userScripts containsObject:self.managerScript]) {
        [userScripts removeObject:self.managerScript];
    }
    if (uCount != userScripts.count) {
        [self.userContentController removeAllUserScripts];
        for (WKUserScript *userScript in userScripts) {
            [self.userContentController addUserScript:userScript];
        }
    }
}

#pragma mark - 
+(void)asyncCallJSAfterReturn:(void(^)(void))code {
    if (code) {
        dispatch_async(dispatch_get_global_queue(0, 0), code);
    }
}
@end

#pragma mark -
#pragma mark - WKUserContentController

@interface WKUserContentController ()
@property (nonatomic, strong) JSExportManager *jsExportManager;
@end

@implementation WKUserContentController (JSExport)

-(void)setJsExportManager:(JSExportManager *)jsExportManager {
    JSExportManager *_jsExportManager = objc_getAssociatedObject(self, @selector(jsExportManager));
    if (_jsExportManager == jsExportManager) {
        return;
    }
    _jsExportManager.userContentController = nil;
    
    objc_setAssociatedObject(self, @selector(jsExportManager), jsExportManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    jsExportManager.userContentController = self;
}

-(JSExportManager *)jsExportManager {
    return objc_getAssociatedObject(self, @selector(jsExportManager));
}
@end;


void import_JSExportManager(void) {
    
}

#pragma mark -
#pragma mark - WKWebView_UIDelegate;

void jsTrade_replaceMethod(Class class, SEL originSelector, SEL newSelector) {
    Method oriMethod = class_getInstanceMethod(class, originSelector);
    Method newMethod = class_getInstanceMethod(class, newSelector);
    BOOL isAddedMethod = class_addMethod(class, originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(class, newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}

@implementation WKWebView (JSExport)
+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        jsTrade_replaceMethod(class, @selector(setUIDelegate:), @selector(_setUIDelegate:));
        jsTrade_replaceMethod(class, @selector(UIDelegate), @selector(_UIDelegate));
        jsTrade_replaceMethod(class, @selector(initWithFrame:configuration:), @selector(_initWithFrame:configuration:));
        
    });
}
-(instancetype)_initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    WKWebView *webView = [self _initWithFrame:frame configuration:configuration];
    if (configuration.userContentController.jsExportManager) {
        self.UIDelegate = nil;
    }
    return webView;
}

-(void)_setUIDelegate:(id<WKUIDelegate>)UIDelegate {
    _JSExportManager *delegate = self.configuration.userContentController.jsExportManager.manager;
    if (delegate) {
        if (delegate != UIDelegate) {
            delegate.UIDelegateReceiver = UIDelegate;
        }
        [self _setUIDelegate:delegate];
    }else{
        [self _setUIDelegate:UIDelegate];
    }
}

-(id<WKUIDelegate>)_UIDelegate {
    _JSExportManager *delegate = self.configuration.userContentController.jsExportManager.manager;
    if (delegate) {
        return delegate.UIDelegateReceiver;
    }else {
        return [self _UIDelegate];
    }
}

@end
