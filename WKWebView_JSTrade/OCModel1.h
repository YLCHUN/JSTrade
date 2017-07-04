//
//  OCModel.h
//  WKWebViewConteoller
//
//  Created by YLCHUN on 2017/3/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSTrade/JSExport.h>


@protocol OCModel1Protocol <JSExportProtocol>
-(void)func0;
-(void)func1:(id)p;
-(void)func2:(JSExportCallBack)cb;
-(void)func3:(id)p cb:(JSExportCallBack)cb;
@end

@interface OCModel1 : JSExportModel <OCModel1Protocol>
@end
