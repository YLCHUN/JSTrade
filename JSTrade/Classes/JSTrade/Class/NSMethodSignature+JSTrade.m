//
//  NSMethodSignature+JSTrade.m
//  JSTrade
//
//  Created by YLCHUN on 2017/5/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NSMethodSignature+JSTrade.h"

typedef NS_ENUM(NSInteger, MethodArgumentType) {
    kMethodArgumentTypeOther             = 0,
    kMethodArgumentTypeInt,
    kMethodArgumentTypeLong,
    kMethodArgumentTypeFloat,
    kMethodArgumentTypeDouble,
    kMethodArgumentTypeBool,
    kMethodArgumentTypeObject,
    kMethodArgumentTypeClass
};

@implementation NSInvocation (JSMethod)

+ (MethodArgumentType)argumentTypeWithEncode:(const char *)encode {
    if (strcmp(encode, @encode(int)) == 0) {
        return kMethodArgumentTypeInt;
    } else if (strcmp(encode, @encode(long)) == 0) {
        return kMethodArgumentTypeLong;
    } else if (strcmp(encode, @encode(float)) == 0) {
        return kMethodArgumentTypeFloat;
    } else if (strcmp(encode, @encode(double)) == 0) {
        return kMethodArgumentTypeDouble;
    } else if (strcmp(encode, @encode(BOOL)) == 0) {
        return kMethodArgumentTypeBool;
    } else if (strcmp(encode, @encode(id)) == 0) {
        return kMethodArgumentTypeObject;
    } else if (strcmp(encode, @encode(Class)) == 0) {
        return kMethodArgumentTypeClass;
    } else {
        return kMethodArgumentTypeOther;
    }
}

+(NSString*)nameWithType:(MethodArgumentType)type {
    switch (type) {
        case kMethodArgumentTypeInt:
            return @"Int";
        case kMethodArgumentTypeLong:
            return @"Long";
        case kMethodArgumentTypeFloat:
            return @"Float";
        case kMethodArgumentTypeDouble:
            return @"Double";
        case kMethodArgumentTypeBool:
            return @"Bool";
        case kMethodArgumentTypeObject:
            return @"Object";
        case kMethodArgumentTypeClass:
            return @"Class";
        default:
            return @"Other";
    }
}

- (void)setValue:(id)anValue type:(MethodArgumentType)type atIndex:(NSInteger)idx {
    NSString *typeNme = [NSInvocation nameWithType:type];
    @try {
        switch (type) {
            case kMethodArgumentTypeInt: {
                int value = [anValue intValue];
                [self setValue:&value atIndex:idx];
            } break;
            case kMethodArgumentTypeLong: {
                long value = [anValue longValue];
                [self setValue:&value atIndex:idx];
            } break;
            case kMethodArgumentTypeFloat: {
                float value = [anValue floatValue];
                [self setValue:&value atIndex:idx];
            } break;
            case kMethodArgumentTypeDouble: {
                double value = [anValue doubleValue];
                [self setValue:&value atIndex:idx];
            } break;
            case kMethodArgumentTypeBool: {
                BOOL value = [anValue boolValue];
                [self setValue:&value atIndex:idx];
            } break;
            case kMethodArgumentTypeObject: {
                [self setValue:&anValue atIndex:idx];
            } break;
            case kMethodArgumentTypeClass: {
                Class value = [anValue class];
                [self setValue:&value atIndex:idx];
            } break;
            default:
                [self setValue:&anValue atIndex:idx];
                break;
        }
    } @catch (NSException *exception) {
        NSString *error = [NSString stringWithFormat:@"数据类型错误，请检查%@ %@", anValue, typeNme];
        NSLog(@"JSTrade_Error %@",error);
    }
}

- (void)setValue:(void *)value atIndex:(NSInteger)idx {
    if (idx < 0) {
        [self setReturnValue:value];
    }else {
        [self setArgument:value atIndex:idx];
    }
}


- (id)getValuetWithType:(MethodArgumentType)type atIndex:(NSInteger)idx {
    NSString *typeNme = [NSInvocation nameWithType:type];
    id anValue;
    @try {
        switch (type) {
            case kMethodArgumentTypeInt: {
                int value;
                [self getValue:&value atIndex:idx];
                anValue = @(value);
            } break;
            case kMethodArgumentTypeLong: {
                long value;
                [self getValue:&value atIndex:idx];
                anValue = @(value);
            } break;
            case kMethodArgumentTypeFloat: {
                float value;
                [self getValue:&value atIndex:idx];
                anValue = @(value);
            } break;
            case kMethodArgumentTypeDouble: {
                double value;
                [self getValue:&value atIndex:idx];
                anValue = @(value);
            } break;
            case kMethodArgumentTypeBool: {
                BOOL value;
                [self getValue:&value atIndex:idx];
                anValue = @(value);
            } break;
            case kMethodArgumentTypeObject: {
                __unsafe_unretained id value;
                [self getValue:&value atIndex:idx];
                anValue = value;
            } break;
            case kMethodArgumentTypeClass: {
                Class value;
                [self getValue:&value atIndex:idx];
                anValue = NSStringFromClass(value);
            } break;
            default: {
                __unsafe_unretained id value;
                [self getValue:&value atIndex:idx];
                anValue = value;
            } break;
        }
    } @catch (NSException *exception) {
        NSString *error = [NSString stringWithFormat:@"数据类型错误，请检查%@ %@", anValue, typeNme];
        NSLog(@"JSTrade_Error %@",error);
    }  @finally {
        return anValue;
    }
}

- (void)getValue:(void *)value atIndex:(NSInteger)idx {
    if (idx < 0) {
        [self getReturnValue:value];
    }else {
        [self getArgument:value atIndex:idx];
    }
}

@end

@implementation NSMethodSignature (JSTrade)

- (MethodArgumentType)argumentTypeAtIndex:(NSInteger)index {
    const char * encode;
    if (index < 0) {
        encode = [self methodReturnType];
    }else{
        encode = [self getArgumentTypeAtIndex:index];
    }
    return [NSInvocation argumentTypeWithEncode:encode];
}


- (void)setInvocation:(NSInvocation*)invocation value:(id)anValue atIndex:(NSInteger)idx {
    NSInteger index = idx;
    MethodArgumentType type = [self argumentTypeAtIndex:index];
    [invocation setValue:anValue type:type atIndex:index];
}

- (id)getInvocationValue:(NSInvocation*)invocation atIndex:(NSInteger)idx {
    NSInteger index = idx;
    MethodArgumentType type = [self argumentTypeAtIndex:index];
    id anValue = [invocation getValuetWithType:type atIndex:index];
    return anValue;
}

@end

void import_NSMethodSignature_JSTrade() {
    
}



