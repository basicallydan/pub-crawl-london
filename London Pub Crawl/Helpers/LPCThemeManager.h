#import <Foundation/Foundation.h>

@interface LPCThemeManager : NSObject

+ (UIColor *)getLinkColor;
+ (UIColor *)getSelectedLinkColor;
+ (UIColor *)getLightGrey;
+ (UIColor *)getFacebookBlue;
+ (UIColor *)getTwitterBlue;

+ (UIColor *)getSuccessMessageTextColor;
+ (UIColor *)getErrorMessageTextColor;

+ (UIColor *)lightenColor:(UIColor *)color;
+ (UIColor *)darkenColor:(UIColor *)color;
+ (UIColor *)lightenOrDarkenColor:(UIColor *)color;

+ (UIImage *)tubeLineForkWithColor:(UIColor *)color;
+ (UIImage *)recolorImage:(UIImage *)image withColor:(UIColor *)color;

@end
