//
//  JSModel.h
//  WKWebView_JSTrade
//
//  Created by YLCHUN on 2017/5/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <JSTrade/JSImport.h>

@protocol JSModelProtocol <JSImportProtocol>

@optional

JSImportVar(@property(nonatomic) NSString * str);
JSImportVar(@property(nonatomic) NSString * Str2);

JSImportVarAs(ss, @property(nonatomic) NSString * str3);
-(void)showMessage:(NSString*)message;
//JSImportFunc(
//        -(int)func0;
//);
//
//-(id)func1:(id)p f:(id)f;
//
JSImportFuncAs(sum,
           -(int)sum:(int)a b:(int)b
           );
-(NSString *)obj:(id)o;
@end

@interface JSModel : NSObject <JSModelProtocol>

@end
