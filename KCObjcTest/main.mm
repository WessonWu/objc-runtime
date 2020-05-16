//
//  main.m
//  KCObjcTest
//
//  Created by wuweixin on 2020/3/5.
//

#import <Foundation/Foundation.h>
#import "WXPerson.h"
#import "Sark.h"
#import "NSObject+Foo.h"
#import <objc/message.h>
#import <objc/runtime.h>

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

static __attribute__((constructor)) void beforeFunction()
{
    printf("beforeFunction\n");
}
static __attribute__((destructor)) void afterFunction()
{
    printf("afterFunction\n");
}


void deepinIvarLayout() {
    // 探索IvarLayout
    Class cls = [Sark class];
    const uint8_t *strongLayout = class_getIvarLayout(cls);
    const uint8_t *weakLayout = class_getWeakIvarLayout(cls);
    
    NSLog(@"=========Deep in Ivar Layout Begin ==========");
    printf("Sark stong ivar layout: ");
    unsigned char byte;
    while ((byte = *strongLayout++)) {
        printf("%02x ", byte);
    }
    printf("\n");
    
    printf("Sark weak ivar layout: ");
    while ((byte = *weakLayout++)) {
        printf("%02x ", byte);
    }
    printf("\n");
    NSLog(@"=========Deep in Ivar Layout End  ==========");
}

void deepinMethodList() {
    NSLog(@"=========Deep in Method List Begin ==========");
    Class cls = [WXPerson class];
    unsigned int count = 0;
    Method * mlist = class_copyMethodList(cls, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method meth = mlist[i];
        SEL methname = method_getName(meth);
        NSLog(@"%@", NSStringFromSelector(methname));
    }
    
    free(mlist);
    NSLog(@"=========Deep in Method List End  ==========");
}


static const void *kWXPersonAssociatedFullnameKey = "WXPersonAssociatedFullname";
// hook保留之前的旧值然后在新的hook函数中调用它
static objc_hook_setAssociatedObject wxperson_old_setAssociatedObject;
void wxperson_hook_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy) {
    wxperson_old_setAssociatedObject(object, key, value, policy);
}

static void fixup_class_arc(Class cls) {
    struct {
        Class isa;
        Class superclass;
        struct {
            void *_buckets;
#if __LP64__
            uint32_t _mask;
            uint32_t _occupied;
#else
            uint16_t _mask;
            uint16_t _occupied;
#endif
        } cache;
        uintptr_t bits;
    } *objcClass = (__bridge typeof(objcClass))cls;
#if !__LP64__
#define FAST_DATA_MASK 0xfffffffcUL
#else
#define FAST_DATA_MASK 0x00007ffffffffff8UL
#endif
    struct {
        uint32_t flags;
        uint32_t version;
        struct {
            uint32_t flags;
        } *ro;
    } *objcRWClass = (typeof(objcRWClass))(objcClass->bits & FAST_DATA_MASK);
#define RO_IS_ARR 1<<7
    objcRWClass->ro->flags |= RO_IS_ARR;
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Class nsobjectClass = [NSObject class];
        ((void(*)(id, SEL))objc_msgSend)(nsobjectClass, @selector(foo));
        deepinIvarLayout();
        
        Class newClass = objc_allocateClassPair(nsobjectClass, "WXObject", 0);
        // alignment 为2^alignment 即alignment=2则按4字节对齐,alignment=3则按8字节对齐，会影响到实例对象的大小
        class_addIvar(newClass, "_gayFriend", sizeof(id), log2(sizeof(id)), @encode(id)); // weak
        class_addIvar(newClass, "wx_var2", sizeof(long), log2(sizeof(long)), @encode(long)); // strong
        class_addIvar(newClass, "wx_var1", sizeof(int), log2(sizeof(int)), @encode(int)); // strong
        class_addIvar(newClass, "_girlFriend", sizeof(id), log2(sizeof(id)), @encode(id)); // __unsafe_unretained
        class_addIvar(newClass, "_company", sizeof(id), log2(sizeof(id)), @encode(id)); // strong
        class_addIvar(newClass, "_company2", sizeof(id), log2(sizeof(id)), @encode(id)); // weak
        /**
         strong 和 weak 的内存管理并没有生效， class 的 flags 中有一个标记位记录这个类是否 ARC，
         正常编译的类，且标识了 -fobjc-arc flag 时，这个标记位为1，而动态创建的类并没有设置它。
         */
        class_setIvarLayout(newClass, (const uint8_t *)"\x12\x11");
        class_setWeakIvarLayout(newClass, (const uint8_t *)"\x01\x41");
        objc_registerClassPair(newClass);
        fixup_class_arc(newClass); // 动态添加的类默认不是ARC的所以我们必须修正它
        
        id newObj = ((id(*)(id, SEL))objc_msgSend)(newClass, @selector(new));
        Ivar wx_var1 = class_getInstanceVariable(newClass, "wx_var1");
        Ivar wx_var2 = class_getInstanceVariable(newClass, "wx_var2");
        
        test_ivar_t *test_wx_var1 = (test_ivar_t *)wx_var1;
        test_ivar_t *test_wx_var2 = (test_ivar_t *)wx_var2;
        NSLog(@"ivar1 offset: %d, ivar2 offset: %d, instanceSize: %zu", *test_wx_var1->offset, *test_wx_var2->offset, class_getInstanceSize(newClass));
        NSNumber *num1 = [NSNumber numberWithInt:1];
        NSNumber *num2 = [NSNumber numberWithLong:2];
        object_setIvarWithStrongDefault(newObj, wx_var1, num1);
        object_setIvarWithStrongDefault(newObj, wx_var2, num2);
        
        NSLog(@"通过object_set/getIvar: %@ %@", object_getIvar(newObj, wx_var1), object_getIvar(newObj, wx_var2));
        
        // 通过直接rw内存地址
        int32_t ivar1_offset = *test_wx_var1->offset;
        int32_t ivar2_offset = *test_wx_var2->offset;
        uint64_t newObj_ref = (uint64_t) newObj;
        uint64_t *newObj_ivar1_ref = (uint64_t *)(newObj_ref + ivar1_offset);
        // 写的时候要转成oc对象
        *newObj_ivar1_ref = (uint64_t)[NSNumber numberWithInt:3];
        uint64_t *newObj_ivar2_ref = (uint64_t *)(newObj_ref + ivar2_offset);
        *newObj_ivar2_ref = (uint64_t)[NSNumber numberWithInt:4];
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored"-Weverything"
        NSLog(@"直接读写内存: %@ %@", *newObj_ivar1_ref, *newObj_ivar2_ref);
        #pragma clang diagnostic pop
        WXPerson *person = [WXPerson new];
        
        deepinMethodList();
        
//        [person performSelector:NSSelectorFromString(@"testForwardMethod")];
        
        NSLog(@"isKindOfClass: %@, isMemberOfClass: %@", @([person isKindOfClass:[WXPerson class]]), @([person isMemberOfClass:[WXPerson class]]));
        
        
        
        // 深入objc_setAssociatedObject
        objc_setHook_setAssociatedObject(wxperson_hook_setAssociatedObject, &wxperson_old_setAssociatedObject);
        objc_setAssociatedObject(person, kWXPersonAssociatedFullnameKey, @"Lebron James", OBJC_ASSOCIATION_COPY_NONATOMIC);
        NSLog(@"person associated fullname: %@", objc_getAssociatedObject(person, kWXPersonAssociatedFullnameKey));
        
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
