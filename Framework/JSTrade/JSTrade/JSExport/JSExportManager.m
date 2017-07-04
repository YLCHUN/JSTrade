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
                               var key = spaceName+'_'+funcName;\n\
                               var callBack = this.callBackHandlers[key];\n\
                               if (callBack) {\n\
                               callBack(param);\n\
                               }\n\
                               },\n\
                               \n\
                               holdCallBack: function(spaceName, funcName, callBack) {\n\
                               var key = spaceName+'_'+funcName;\n\
                               if ((callBack && key) && (this.callBackHandlers[key] != callBack)) {\n\
                               this.callBackHandlers[key] = callBack;\n\
                               }\n\
                               },\n\
                               \n\
                               callWebKit: function(spaceName, funcName, params, callBack) {\n\
                               if (callBack) {\n\
                               this.holdCallBack(spaceName, funcName, callBack);\n\
                               }\n\
                               var message = {};\n\
                               message['spaceName'] = spaceName;\n\
                               message['funcName'] = funcName;\n\
                               if (params) {\n\
                               message['params'] = params;\n\
                               }\n\
                               this.doWebKit(message);\n\
                               },\n\
                               \n\
                               doWebKit: function(message){\n\
                               window.webkit.messageHandlers.%@.postMessage(message);\n\
                               },\n\
                               \n\
                               transfer: function(spaceName, funcName, funcArguments) {\n\
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
                               this.callWebKit(spaceName, funcName, params, callBack);\n\
                               }\n\
                               }\n", kJSExport_registerKey, kJSExport_registerKey];
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

@interface _JSExportManager : NSObject <WKScriptMessageHandler>
@property (nonatomic, weak) JSExportManager *manager;
@end
@implementation _JSExportManager
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:kJSExport_registerKey]) {
        NSDictionary *dict = message.body;
        NSString *spaceName = dict[@"spaceName"];
        if (spaceName.length>0) {
            JSExportScriptManager *sm = self.manager.handlerDict[spaceName];
            [sm jsHandlerCallWithMessage:message];
        }
    }
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
