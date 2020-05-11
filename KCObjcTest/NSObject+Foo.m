//
//  NSObject+Foo.m
//  KCObjcTest
//
//  Created by wuweixin on 2020/5/11.
//

#import "NSObject+Foo.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Weverything"
@implementation NSObject (Foo)
#pragma clang diagnostic pop
- (void)foo {
    NSLog(@"foo");
}

@end
