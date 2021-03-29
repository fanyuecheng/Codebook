//
//  CBCodeObject.h
//  Codebook
//
//  Created by YueCheng on 2021/1/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SAMKeychain/SAMKeychain.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const CBNewObjectNotification;
UIKIT_EXTERN NSString *const CBKeychainAccount;
UIKIT_EXTERN NSString *const CBKeychainService;

typedef NS_ENUM(NSUInteger, CBCodeObjectType) {
    CBCodeObjectTypeApp,
    CBCodeObjectTypeWeb,
    CBCodeObjectTypeBank,
    CBCodeObjectTypeOther
};

@interface CBCodeObject : NSObject

@property (nonatomic, assign) CBCodeObjectType type;
@property (nonatomic, copy) NSString *typeString;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *extra;

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)webObject;
+ (instancetype)appObject;
+ (instancetype)bankObject;
+ (instancetype)otherObject;

+ (NSArray <NSDictionary *>*)allDictionarys;
+ (NSArray <CBCodeObject *>*)allObjects;
+ (NSArray <CBCodeObject *>*)allWebObjects;
+ (NSArray <CBCodeObject *>*)allAppObjects;
+ (NSArray <CBCodeObject *>*)allBankObjects;
+ (NSArray <CBCodeObject *>*)allOtherObjects;

+ (NSArray <NSString *>*)commonAccounts;
+ (NSString *)savePasswordListToLocal;
+ (BOOL)saveAllData:(NSArray *)data;
- (NSDictionary *)dictionaryValue;
- (BOOL)saveCodeObject;
- (BOOL)deleteCodeObject;

@end

NS_ASSUME_NONNULL_END
