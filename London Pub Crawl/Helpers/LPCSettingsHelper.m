#import "LPCSettingsHelper.h"

#import "NSDictionary+FromJSONFile.h"

@implementation LPCSettingsHelper {
    NSDictionary *settings;
}

+ (LPCSettingsHelper *)sharedInstance {
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static LPCSettingsHelper *_sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        settings = [NSDictionary dictionaryWithContentsOfJSONFile:@"settings.json"];
    }
    return self;
}

- (NSString *)stringForSettingWithKey:(NSString *)key {
    return [settings valueForKey:key];
}

- (BOOL)booleanForSettingWithKey:(NSString *)key {
    id settingValue = [settings valueForKey:key];
    if (settingValue != nil) {
        return [settingValue boolValue];
    } else {
        return NO;
    }
}

@end
