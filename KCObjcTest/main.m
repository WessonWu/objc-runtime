//
//  main.m
//  KCObjcTest
//
//  Created by Cooci on 2020/3/5.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>

@interface WXPerson : NSObject

@property(nonatomic, copy) NSString * name;

@end

@implementation WXPerson

@end


@interface NSObject (Foo)

+ (void)foo;

@end

@implementation NSObject (Foo)

- (void)foo {
    NSLog(@"foo");
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        ((void(*)(id, SEL))objc_msgSend)([NSObject class], @selector(foo));
//        __autoreleasing WXPerson *person = [[WXPerson alloc] init];
//        person.name = @"James";
//        NSLog(@"%@", object_getClass(person));
//
//        [person isKindOfClass:[NSObject class]];
//
//        __weak typeof(person) weakPerson = person;
//        void(^block)(void) = ^{
//            NSLog(@"%@", weakPerson);
//        };
//        block();
        
        
//        Class aClass = [Person class];
//        while (aClass != nil) {
//            NSLog(@"Class: %@", NSStringFromClass(aClass));
//            aClass = class_getSuperclass(aClass);
//        }
    }
    return 0;
}
