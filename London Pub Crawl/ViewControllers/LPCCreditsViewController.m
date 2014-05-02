#import "LPCCreditsViewController.h"

#import "LPCCreditsCell.h"
#import "LPCLineTableViewCell.h"
#import <Analytics/Analytics.h>
#import <ChimpKit/ChimpKit.h>
#import "LPCSettingsHelper.h"
#import "LPCThemeManager.h"
#import <CGLMail/CGLMailHelper.h>

@interface LPCCreditsViewController () <UITextFieldDelegate>

@end

@implementation LPCCreditsViewController

NSString *const emailAddress = @"info+pubcrawl@happilyltd.co";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    UILongPressGestureRecognizer *emailButtonLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondToEmailLongPress:)];
    [self.happyEmailButton addGestureRecognizer:emailButtonLongPress];
    
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)initWithCells:(NSArray *)lineCells andOffset:(float)offset {
    self = [super initWithNibName:@"LPCCreditsViewController" bundle:[NSBundle mainBundle]];
    
    for (LPCLineTableViewCell *cell in lineCells) {
        UIView *creditsCell = [[LPCCreditsCell alloc] initBasedOnCell:cell andOffset:offset];
        [self.view addSubview:creditsCell];
    }
    
    return self;
}

- (IBAction)backButtonPressed:(id)sender {
    [[Analytics sharedAnalytics] track:@"Closed credits"];
    
    CGFloat width = self.view.bounds.size.width;
    [self.view.superview addSubview:self.presentingViewController.view];
    [UIView animateWithDuration:.5 animations:^{
        self.presentingViewController.view.center = CGPointMake(self.presentingViewController.view.center.x + width, self.presentingViewController.view.center.y);
        self.view.center = CGPointMake(self.view.center.x + width, self.view.center.y);
        
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (IBAction)foursquareLogoPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://foursquare.com"]];
}

- (IBAction)mapboxLogoPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.mapbox.com"]];
}

- (IBAction)tflLogoPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://tfl.gov.uk"]];
}

- (IBAction)happilyLinkPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://happilyltd.co"]];
}

- (IBAction)happilyEmailPressed:(id)sender {
    UIViewController *mailVC = [CGLMailHelper supportMailViewControllerWithRecipient:emailAddress subject:@"Pub Crawl: London" completion:nil];
    [self presentViewController:mailVC animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.emailTextField resignFirstResponder];
        NSLog(@"Email address is %@", self.emailTextField.text);
        NSString *subscriberEmailAddress = self.emailTextField.text;
        
        [[ChimpKit sharedKit] setApiKey:[[LPCSettingsHelper sharedInstance] stringForSettingWithKey:@"mailchimp-key"]];
        
        NSDictionary *params = @{@"id": [[LPCSettingsHelper sharedInstance] stringForSettingWithKey:@"mailchimp-list-id"], @"email": @{@"email": subscriberEmailAddress}, @"merge_vars": @{
                                         @"groupings":@[
                                                 @{
                                                     @"name":[[LPCSettingsHelper sharedInstance] stringForSettingWithKey:@"mailchimp-grouping-name"],
                                                     @"groups":@[[[LPCSettingsHelper sharedInstance] stringForSettingWithKey:@"mailchimp-group-name"]]
                                                     }
                                                 ]}
                                 };
        [[ChimpKit sharedKit] callApiMethod:@"lists/subscribe" withParams:params andCompletionHandler:^(ChimpKitRequest *request, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
            }
            NSLog(@"HTTP Status Code: %d", request.response.statusCode);
            NSLog(@"Response String: %@", request.responseString);
            
            if (request.response.statusCode != 200) {
                NSLog(@"Something failed in the subscription");
                [self showErroneousEmailMessageWithText:@"Can't subscribe :( Try re-entering."];
            } else {
                [self.emailTextField setText:@""];
                [self showSuccessfulEmailMessageWithText:@"Thanks for subscribing :)"];
            }
        }];
    }
    return YES;
}

#pragma Private Methods

- (void)dismissKeyboard {
    [self.emailTextField resignFirstResponder];
}

- (void)showSuccessfulEmailMessageWithText:(NSString *)text {
    [self.emailMessageLabel setText:text];
    [self.emailMessageLabel setTextColor:[LPCThemeManager getSuccessMessageTextColor]];
    [UIView animateWithDuration:.4 animations:^{
        [self.emailMessageLabel setAlpha:1.0f];
    }];
}

- (void)showErroneousEmailMessageWithText:(NSString *)text {
    [self.emailMessageLabel setText:text];
    [self.emailMessageLabel setTextColor:[LPCThemeManager getErrorMessageTextColor]];
    [UIView animateWithDuration:.4 animations:^{
        [self.emailMessageLabel setAlpha:1.0f];
    }];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -120.0f;
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0;
        self.view.frame = f;
    }];
}

- (void)respondToEmailLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self copyEmail];
        return;
    }
}

- (void)copyEmail {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = emailAddress;
}

@end
