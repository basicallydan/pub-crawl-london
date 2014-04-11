#import <Foundation/Foundation.h>

@interface LPCThemeManager : NSObject

+ (UIColor *)getLinkColor;
+ (UIColor *)getSelectedLinkColor;
+ (UIColor *)getLightGrey;
+ (UIColor *)getFacebookBlue;
+ (UIColor *)getTwitterBlue;

+ (UIImage *)tubeLineForkWithColor:(UIColor *)color;
+ (UIImage *)recolorImage:(UIImage *)image withColor:(UIColor *)color;

@end
