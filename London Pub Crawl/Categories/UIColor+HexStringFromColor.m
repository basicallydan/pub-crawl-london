#import "UIColor+HexStringFromColor.h"

@implementation UIColor (HexStringFromColor)

- (NSString *)hexStringValue {
    return [self hexStringValueWithHash:YES];
}

- (NSString *)hexStringValueWithHash:(BOOL)withHash {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString = [NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    if (withHash) {
        hexString = [[NSString stringWithFormat:@"#%@", hexString] lowercaseString];
    }
    return hexString;
}

@end
