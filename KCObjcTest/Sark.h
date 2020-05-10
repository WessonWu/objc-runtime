//
//  Sark.h
//  KCObjcTest
//
//  Created by wuweixin on 2020/5/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SarkDelegate <NSObject>

@required
+ (void)sark0;
- (void)sark1;
- (void)sark2;

@optional
- (void)sark3;
- (void)sark4;
+ (void)sark5;

@end

@interface Sark : NSObject {
    __strong id _gayFriend; // 无修饰符的对象默认会加 __strong
    id _gayFriend1; // 默认是strong
    __unsafe_unretained id _gayFriend2; //既不是__strong也不是__weak
    __weak id _girlFriend;
    __unsafe_unretained id _company;
}

@end

NS_ASSUME_NONNULL_END
