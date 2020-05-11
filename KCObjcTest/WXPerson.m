//
//  WXPerson.m
//  KCObjcTest
//
//  Created by wuweixin on 2020/5/11.
//

#import "WXPerson.h"
#import "Sark.h"

@interface WXPerson () <SarkDelegate>

@end

@implementation WXPerson

// 当我们实现load方式时，该class的引用就会被存放在__objc_nlclslist区中，在map_image(_read_images)阶段时该类&元类对象就会被初始化
// 所以更加推荐使用initialize方法进行惰性初始化
+ (void)load {
    NSLog(@"%@: %@", NSStringFromClass(self), NSStringFromSelector(_cmd));
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

+ (void)sark0 {
    NSLog(@"method: %@", NSStringFromSelector(_cmd));
}

- (void)sark1 {
    NSLog(@"method: %@", NSStringFromSelector(_cmd));
}

- (void)sark2 {
    NSLog(@"method: %@", NSStringFromSelector(_cmd));
}

- (void)dealloc
{
    NSLog(@"%@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//    [super dealloc];
}

@end
