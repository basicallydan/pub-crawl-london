#import <UIKit/UIKit.h>

@interface UIColor (HexStringFromColor)

- (NSString *)hexStringValue;
- (NSString *)hexStringValueWithHash:(BOOL)withHash;

@end
