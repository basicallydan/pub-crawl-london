#import "LPCCreditsCell.h"

@implementation LPCCreditsCell

- (id)initBasedOnCell:(UITableViewCell *)cell {    
    self = [super initWithFrame:cell.frame];
    
    CGRect leftBorderFrame = cell.frame;
    leftBorderFrame.size.width = leftBorderFrame.size.width * 0.02;
    leftBorderFrame.origin.y = 0;
    UIView *leftBorderView = [[UIView alloc] initWithFrame:leftBorderFrame];
    leftBorderView.backgroundColor = cell.backgroundColor;
    [self addSubview:leftBorderView];
    
    self.backgroundColor = [UIColor whiteColor];
    
    return self;
}

@end
