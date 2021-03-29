//
//  CBCodeObject.m
//  Codebook
//
//  Created by YueCheng on 2021/1/8.
//

#import "CBCodeObject.h"
 
NSString *const CBNewObjectNotification = @"CBNewObjectNotification";
NSString *const CBKeychainAccount = @"com.fancy.codebook.account";
NSString *const CBKeychainService = @"com.fancy.codebook.service";

@implementation CBCodeObject

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary {
    CBCodeObject *obj = [[CBCodeObject alloc] init];
    obj.type = [dictionary[@"type"] integerValue];
    obj.account = dictionary[@"account"];
    obj.password = dictionary[@"password"];
    obj.extra = dictionary[@"extra"];
    return obj;
}

+ (instancetype)webObject {
    CBCodeObject *obj = [[CBCodeObject alloc] init];
    obj.type = CBCodeObjectTypeWeb;
    return obj;
}

+ (instancetype)appObject {
    CBCodeObject *obj = [[CBCodeObject alloc] init];
    obj.type = CBCodeObjectTypeApp;
    return obj;
}

+ (instancetype)bankObject {
    CBCodeObject *obj = [[CBCodeObject alloc] init];
    obj.type = CBCodeObjectTypeBank;
    return obj;
}

+ (instancetype)otherObject {
    CBCodeObject *obj = [[CBCodeObject alloc] init];
    obj.type = CBCodeObjectTypeOther;
    return obj;
}

+ (NSArray <NSDictionary *>*)allDictionarys {
    NSData *data = [SAMKeychain passwordDataForService:CBKeychainService account:CBKeychainAccount];
    NSData *decompressData = [data decompressedDataUsingAlgorithm:NSDataCompressionAlgorithmZlib error:nil];
    if (decompressData) {
        NSError *error = nil;
        NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:decompressData
                                                              options:NSJSONReadingAllowFragments
                                                                error:&error];
        if (jsonObject != nil && error == nil) {
            return jsonObject;
        } else {
            return [NSArray array];
        }
    } else {
        return [NSArray array];
    }
}

+ (NSArray <CBCodeObject *>*)allObjects {
    NSMutableArray *resultArray = [NSMutableArray array];
    NSArray *dictionarys = [CBCodeObject allDictionarys];
    [dictionarys enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [resultArray addObject:[CBCodeObject objectWithDictionary:obj]];
    }];
    return resultArray;
}

+ (NSArray <CBCodeObject *>*)allWebObjects {
    NSArray *objectArray = [CBCodeObject allObjects];
    NSMutableArray *resultArray = [NSMutableArray array];
    [objectArray enumerateObjectsUsingBlock:^(CBCodeObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == CBCodeObjectTypeWeb) {
            [resultArray addObject:obj];
        }
    }];
    return resultArray;
}

+ (NSArray <CBCodeObject *>*)allAppObjects {
    NSArray *objectArray = [CBCodeObject allObjects];
    NSMutableArray *resultArray = [NSMutableArray array];
    [objectArray enumerateObjectsUsingBlock:^(CBCodeObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == CBCodeObjectTypeApp) {
            [resultArray addObject:obj];
        }
    }];
    return resultArray;
}

+ (NSArray <CBCodeObject *>*)allBankObjects {
    NSArray *objectArray = [CBCodeObject allObjects];
    NSMutableArray *resultArray = [NSMutableArray array];
    [objectArray enumerateObjectsUsingBlock:^(CBCodeObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == CBCodeObjectTypeBank) {
            [resultArray addObject:obj];
        }
    }];
    return resultArray;
}

+ (NSArray <CBCodeObject *>*)allOtherObjects {
    NSArray *objectArray = [CBCodeObject allObjects];
    NSMutableArray *resultArray = [NSMutableArray array];
    [objectArray enumerateObjectsUsingBlock:^(CBCodeObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == CBCodeObjectTypeOther) {
            [resultArray addObject:obj];
        }
    }];
    return resultArray;
}

- (NSString *)typeString {
    switch (self.type) {
        case 0:
            return @"App";
            break;
        case 1:
            return @"网站";
            break;
        case 2:
            return @"银行";
            break;
        default:
            return @"其他";
            break;
    }
}

+ (NSArray <NSString *>*)commonAccounts {
    NSArray <CBCodeObject *> *allObjects = [CBCodeObject allObjects];
    NSMutableDictionary *accountDict = [NSMutableDictionary dictionary];
    
    [allObjects enumerateObjectsUsingBlock:^(CBCodeObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger count = [[accountDict objectForKey:obj.account] integerValue];
        if (count) {
            count ++;
            [accountDict setObject:@(count) forKey:obj.account];
        } else {
            [accountDict setObject:@(1) forKey:obj.account];
        }
    }];
    
    [accountDict.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger count = [[accountDict objectForKey:obj] integerValue];
        if (count < 3) {
            [accountDict removeObjectForKey:obj];
        }
    }];
    
    return [accountDict allKeys];
}

+ (NSString *)savePasswordListToLocal {
    NSArray *objectArray = [CBCodeObject allDictionarys];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:objectArray options:0 error:NULL];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *localPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"CBPassword.text"];
    BOOL success = [jsonString writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (success) {
        return localPath;
    } else {
        return nil;
    }
}

- (NSDictionary *)dictionaryValue {
    return @{@"type"     : @(self.type),
             @"account"  : self.account ? self.account : @"",
             @"password" : self.password ? self.password : @"",
             @"extra"    : self.extra.length ? self.extra : @""};
}

- (BOOL)saveCodeObject {
    if (self.account.length == 0 || self.password.length == 0) {
        return NO;
    }
    NSDictionary *object = @{@"type"     : @(self.type),
                             @"account"  : self.account,
                             @"password" : self.password,
                             @"extra"    : self.extra.length ? self.extra : @""};
    NSMutableArray *objectArray = [[CBCodeObject allDictionarys] mutableCopy];
    [objectArray addObject:object];
    return [CBCodeObject saveAllData:objectArray];
}

- (BOOL)deleteCodeObject {
    NSMutableArray *objectArray = [[CBCodeObject allDictionarys] mutableCopy];
    if (objectArray.count) {
        [objectArray removeObject:[self dictionaryValue]];
    }
    return [CBCodeObject saveAllData:objectArray];
}

+ (BOOL)saveAllData:(NSArray *)array {
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:0 error:NULL];
    NSData *compressData = [data compressedDataUsingAlgorithm:NSDataCompressionAlgorithmZlib error:nil];
    return [SAMKeychain setPasswordData:compressData forService:CBKeychainService account:CBKeychainAccount];
}

- (BOOL)isEqual:(id)object {
    if (!object) return NO;
    if (self == object) return YES;
    if (![object isKindOfClass:[self class]]) return NO;
    CBCodeObject *codeObject = (CBCodeObject *)object;
    return self.type == codeObject.type && [self.account isEqualToString:codeObject.account] && [self.password isEqualToString:codeObject.password] && [self.extra isEqualToString:codeObject.extra];
}

@end
