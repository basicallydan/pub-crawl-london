#import <Foundation/Foundation.h>

@interface LPCSettingsHelper : NSObject

+ (LPCSettingsHelper *)sharedInstance;

- (NSString *)stringForSettingWithKey:(NSString *)key;
- (BOOL)booleanForSettingWithKey:(NSString *)key;

@end
