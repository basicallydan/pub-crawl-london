#import "LPCCreditsCell.h"

@implementation LPCCreditsCell

- (id)initBasedOnCell:(UITableViewCell *)cell andOffset:(float)offset {
    CGRect leftBorderFrame = cell.frame;
    leftBorderFrame.size.width = leftBorderFrame.size.width * 0.01;
    leftBorderFrame.origin.y += offset;
//    leftBorderFrame.origin.y = 0;
    
    self = [super initWithFrame:leftBorderFrame];
//    UIView *leftBorderView = [[UIView alloc] initWithFrame:leftBorderFrame];
//    leftBorderView.backgroundColor = cell.backgroundColor;
//    [self addSubview:leftBorderView];
    
    self.backgroundColor = cell.backgroundColor;
    
    return self;
}

@end
