#import "LPCBuyLineView.h"
#import "LPCAppDelegate.h"

@implementation LPCBuyLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setLine:(LPCLine *)line {
    _line = line;
    [self.lineNameLabel setText:[NSString stringWithFormat:@"%@ Line", line.name]];
//    LPCAppDelegate *appDelegate = ((LPCAppDelegate *)[[UIApplication sharedApplication] delegate]);
    SKProduct *product = [LPCAppDelegate productWithIdentifier:line.iapProductIdentifier];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:product.priceLocale];
    NSString *currencyString = [formatter stringFromNumber:product.price];
    [self.buyAllButton setTitle:[NSString stringWithFormat:self.buyAllButton.titleLabel.text, [LPCAppDelegate priceStringForAllTheLines]] forState:UIControlStateNormal];
    [self.buyThisButton setTitle:[NSString stringWithFormat:self.buyThisButton.titleLabel.text, currencyString] forState:UIControlStateNormal];
}

- (void)buyAllButtonPressed:(id)sender {
    [self.delegate didChooseToBuyAll];
}

- (void)buyLineButtonPressed:(id)sender {
    [self.delegate didChooseToBuyLine:self.line];
}

@end
