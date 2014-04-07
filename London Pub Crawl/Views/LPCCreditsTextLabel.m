#import "LPCCreditsTextLabel.h"

@implementation LPCCreditsTextLabel

- (id)initForCell:(UITableViewCell *)cell {
    UILabel *originalLabel = cell.textLabel;
    
    UILabel *creditsLabel = [super initWithFrame:originalLabel.frame];
    UIFont *creditsFont = [UIFont fontWithName:originalLabel.font.fontName size:originalLabel.font.pointSize * 0.9];
    creditsLabel.numberOfLines = 2.0f;
    creditsLabel.font = creditsFont;
//    creditsLabel.minimumScaleFactor = 0.9f;
    creditsLabel.adjustsFontSizeToFitWidth = YES;
    creditsLabel.textColor = [UIColor blackColor];
    return self;
}

@end
