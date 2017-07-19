//
//  OCModel.h
//  WKWebViewConteoller
//
//  Created by YLCHUN on 2017/3/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSTrade/JSExport.h>

@protocol OCModelProtocol <JSExportProtocol>
-(int)func0;
-(void)func1:(id)p;
-(void)func2:(JSExportCallBack)cb;
//-(void)func3:(id)p cb:(JSExportCallBack)cb;
JSExportAs(func3,
           -(void)func4:(int)p p2:(NSString*)p2 cb:(JSExportCallBack)cb
           );
@end

@interface OCModel : JSExportModel <OCModelProtocol>
@end
