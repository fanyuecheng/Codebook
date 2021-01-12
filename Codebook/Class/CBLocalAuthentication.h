//
//  CBLocalAuthentication.h
//  Codebook
//
//  Created by 米画师 on 2021/1/11.
//

#import <LocalAuthentication/LocalAuthentication.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBLocalAuthentication : LAContext

+ (instancetype)sharedInstance;

- (void)authenticationWithDescribe:(NSString *)desc stateBlock:(void (^)(NSError *error))stateBlock;

- (void)showTouchIDWithDescribe:(NSString *)desc stateBlock:(void (^)(NSError *error))stateBlock;

- (void)showFaceIDWithDescribe:(NSString *)desc stateBlock:(void (^)(NSError *error))stateBlock;

@end

NS_ASSUME_NONNULL_END
