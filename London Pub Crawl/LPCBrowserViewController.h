#import <UIKit/UIKit.h>

@interface LPCBrowserViewController : UIViewController

- (id)initWithURLString:(NSString *)string;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
