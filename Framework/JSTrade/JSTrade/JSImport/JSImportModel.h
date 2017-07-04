//
//  JSImportModel.h
//  JSTrade
//
//  Created by YLCHUN on 2017/5/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//
//  支持数据类型：基本数据类型，NSDictionary， NSArray，NSNumber，NSString，nil，object类型需要转NSDictionary或者NSArray
//  JSImportVar 不允许 var 和 Var 属性同时存在（属性名仅首字母大小写不一致）

#import <Foundation/Foundation.h>
@class WKWebView;

#define JSImportVar(Property)\
@optional Property##__JS_IMPORT_AS_VAR__ NS_UNAVAILABLE; @optional Property

//JSImportVar 同时存在 var 和 Var（属性名仅首字母大小写不一致）时候采用JSImportVarAs 取别名
#define JSImportVarAs(Var, Property)\
@optional Property##__JS_IMPORT_AS_VAR_AS__##Var NS_UNAVAILABLE; @optional Property

#define JSImportFunc(Selector) \
@optional Selector

//JSImportFunc 存在多个参数时候采用 JSImportFuncAs 取别名
#define JSImportFuncAs(FunctionName, Selector) \
@optional Selector __JS_IMPORT_AS__##FunctionName:(id)argument NS_UNAVAILABLE; @optional Selector

//采用自动转发函数请用 @optional 关键字修饰且禁止实现协议方法，@required 关键字修饰 需要手动实现方法体转发
@protocol JSImportProtocol <NSObject>
//@optional
//JSImportVar(NSString *, str);
//-(void)func0;                                 //window.<#spaceName#>.func0();
//-(void)func1:(id)p;                           //window.<#spaceName#>.func1(<#param#>);

//      JSExportAs(doFoo,
//           - (void)doFoo:(id)foo withBar:(id)bar
//           );//window.<#spaceName#>.doFoo(foo,bar);
@end

@interface JSImportModel : NSObject
/**
 调用js代码 window.<#spaceName#>.func()
 */
@property (nonatomic, readonly) NSString* spaceName;

@property (nonatomic, weak) WKWebView *webView;

-(instancetype)initWithSpaceName:(NSString*)name;

-(id)unserializeJSON:(NSString *)jsonString toStringValue:(BOOL)toStringValue;

@end
