//
//  OCModel.m
//  WKWebView_JSTrade
//
//  Created by YLCHUN on 2017/3/14.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "OCModel1.h"

@implementation OCModel1

-(NSNumber*)func0 {
    return @(1);
}

-(void)func1:(id)p {
}

-(void)func2:(JSExportCallBack)cb {
    cb(@"func2:");
}

-(void)func3:(id)p cb:(JSExportCallBack)cb {
    cb([NSString stringWithFormat:@"func3:cb: %@", p]);
}

@end
