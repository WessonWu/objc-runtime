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

#ifdef __LP64__
#   define WORD_SHIFT 3UL
#   define WORD_MASK 7UL
#   define WORD_BITS 64
#else
#   define WORD_SHIFT 2UL
#   define WORD_MASK 3UL
#   define WORD_BITS 32
#endif

struct test_ivar_t {
    int32_t *offset; // 偏移量
    const char *name; // 变量名称
    const char *type; //变量类型
    // alignment is sometimes -1; use alignment() instead
    uint32_t alignment_raw;
    uint32_t size;

    uint32_t alignment() const {
        if (alignment_raw == ~(uint32_t)0) return 1U << WORD_SHIFT;
        return 1 << alignment_raw;
    }
};


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Class nsobjectClass = [NSObject class];
        ((void(*)(id, SEL))objc_msgSend)(nsobjectClass, @selector(foo));
        Class newClass = objc_allocateClassPair(nsobjectClass, "WXObject", 0);
        // alignment 为2^alignment 即alignment=2则按4字节对齐,alignment=3则按8字节对齐，会影响到实例对象的大小
        class_addIvar(newClass, "wx_var2", sizeof(long), 3, @encode(long));
        class_addIvar(newClass, "wx_var1", sizeof(int), 2, @encode(int));
        objc_registerClassPair(newClass);
        id newObj = ((id(*)(id, SEL))objc_msgSend)(newClass, @selector(new));
        Ivar wx_var1 = class_getInstanceVariable(newClass, "wx_var1");
        Ivar wx_var2 = class_getInstanceVariable(newClass, "wx_var2");
        
        test_ivar_t *test_wx_var1 = (test_ivar_t *)wx_var1;
        test_ivar_t *test_wx_var2 = (test_ivar_t *)wx_var2;
        NSLog(@"%d %d %zu", *test_wx_var1->offset, *test_wx_var2->offset, class_getInstanceSize(newClass));
        NSNumber *num1 = [NSNumber numberWithInt:1];
        NSNumber *num2 = [NSNumber numberWithLong:2];
        object_setIvarWithStrongDefault(newObj, wx_var1, num1);
        object_setIvarWithStrongDefault(newObj, wx_var2, num2);
        
        NSLog(@"%@ %@", object_getIvar(newObj, wx_var1), object_getIvar(newObj, wx_var2));
        
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
