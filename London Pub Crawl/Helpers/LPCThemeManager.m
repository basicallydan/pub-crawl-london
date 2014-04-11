#import "LPCThemeManager.h"

#import <UIColor+HexString.h>

@implementation LPCThemeManager

+ (UIColor *)getLightGrey
{
    return [UIColor colorWithHexString:@"#f1f1f1"];
}

+ (UIColor *)getLinkColor
{
    return [UIColor colorWithHexString:@"#0066ff"];
}

+ (UIColor *)getSelectedLinkColor
{
    return [UIColor colorWithHexString:@"#6699ff"];
}

+ (UIColor *)getFacebookBlue
{
    return [UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f];
}

+ (UIColor *)getTwitterBlue
{
    return [UIColor colorWithRed:64/255.0f green:153/255.0f blue:255/255.0f alpha:1.0f];
}

+ (UIImage *)tubeLineForkWithColor:(UIColor *)color {
    UIImage *image = [UIImage imageNamed:@"tube-line-fork-double-sided"];
    
    return [self recolorImage:image withColor:color];
}

+ (UIImage *)recolorImage:(UIImage *)image withColor:(UIColor *)color {
    CGRect rect;
    
    if ([UIScreen mainScreen].scale == 2.0) {
        rect = CGRectMake(0, 0, image.size.width * 2, image.size.height * 2);
    } else {
        rect = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    
    return flippedImage;
}

@end
