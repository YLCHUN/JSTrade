//
//  JSImportMethod.h
//  JSTrade
//
//  Created by YLCHUN on 2017/7/4.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSImportMethod : NSObject
@property (nonatomic) SEL sel;
@property (nonatomic, copy) NSString *selName;
@property (nonatomic, copy) NSString *jsFuncName;
@property (nonatomic, assign) BOOL isAs;
@property (nonatomic, assign) BOOL isVar;
@property (nonatomic, assign) BOOL isSet;
@end
