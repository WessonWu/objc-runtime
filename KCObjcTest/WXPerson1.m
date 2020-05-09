//
//  WXPerson1.m
//  KCObjcTest
//
//  Created by wuweixin on 2020/5/9.
//

#import "WXPerson1.h"

@implementation WXPerson1

+ (instancetype)shareInstance {
    static WXPerson1 * shareInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shareInstance = [WXPerson1 new];
    });
    
    return shareInstance;
}

@end
