//
//  JSModel_Document.h
//  WKWebView_JSTrade
//
//  Created by YLCHUN on 2017/5/31.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <JSTrade/JSImport.h>

@protocol JSModelProtocol_Document <JSImportProtocol>

@optional

JSImportVar(@property (nonatomic) NSString * title);
JSImportVar(@property (nonatomic) NSString * bgColor);
JSImportVar(@property (nonatomic) NSString * fgColor);
JSImportVar(@property (nonatomic) NSString * linkColor);
JSImportVar(@property (nonatomic) NSString * alinkColor);
JSImportVar(@property (nonatomic) NSString * vlinkColor);

-(void)write:(NSString*)htmlString;
-(void)createElement:(NSString*)tag;
-(id)getElementById:(NSString*)eId;//返回类型不支持
-(id)getElementsByName:(NSString*)eName;//返回类型不支持

//-(void)showMessage:(NSString*)message;
//JSImportAn(
//        -(int)func0;
//);
//
//-(id)func1:(id)p f:(id)f;
//
//JSImportAs(sum,
//           -(int)sum:(int)a b:(int)b
//           );
//-(NSString *)obj:(id)o;
@end

@interface JSModel_Document : NSObject<JSModelProtocol_Document>

-(instancetype)initWithSpaceName:(NSString *)name NS_UNAVAILABLE;
@end
