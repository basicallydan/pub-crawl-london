#import <UIKit/UIKit.h>

#import "LPCLine.h"

@protocol LPCBuyLineViewDelegate <NSObject>

- (void)didChooseToBuyAll;
- (void)didChooseToBuyLine:(LPCLine *)line;

@end

@interface LPCBuyLineView : UIView

@property (strong, nonatomic) LPCLine *line;

@property (weak, nonatomic) id<LPCBuyLineViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *lineNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyAllButton;
@property (weak, nonatomic) IBOutlet UIButton *buyThisButton;

- (IBAction)buyAllButtonPressed:(id)sender;
- (IBAction)buyLineButtonPressed:(id)sender;

@end
