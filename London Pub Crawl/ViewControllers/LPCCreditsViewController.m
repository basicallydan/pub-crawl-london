#import "LPCCreditsViewController.h"

#import "LPCCreditsCell.h"
#import "LPCLineTableViewCell.h"
#import <Analytics/Analytics.h>
#import <ChimpKit/ChimpKit.h>
#import "LPCSettingsHelper.h"
#import "LPCThemeManager.h"

@interface LPCCreditsViewController () <UITextFieldDelegate>

@end

@implementation LPCCreditsViewController

NSString *const emailAddress = @"info+pubcrawl@happilyltd.co";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
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
    // Dispose of any resources that can be recreated.
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
}

- (IBAction)mapboxLogoPressed:(id)sender {
}

- (IBAction)tflLogoPressed:(id)sender {
}

- (IBAction)happilyLinkPressed:(id)sender {
}

- (IBAction)happilyEmailPressed:(id)sender {
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
        // TODO: Something better than this!
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
    [UIView animateWithDuration:.5 animations:^{
        [self.emailMessageLabel setAlpha:1.0f];
    }];
}

- (void)showErroneousEmailMessageWithText:(NSString *)text {
    [self.emailMessageLabel setText:text];
    [self.emailMessageLabel setTextColor:[LPCThemeManager getErrorMessageTextColor]];
    [UIView animateWithDuration:.5 animations:^{
        [self.emailMessageLabel setAlpha:1.0f];
    }];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -90.0f;
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

//- (id)initFromTableView:(UITableView *)tableView andCells:(NSArray *)lineCells {
//    CGRect creditsViewStartingFrame = tableView.frame;
//    creditsViewStartingFrame.origin.x = creditsViewStartingFrame.size.width;
//    self = [self initWithNibName:@"LPCCreditsViewController" bundle:[NSBundle mainBundle]];
//    //    int cellNumber = 0;
//    for (LPCLineTableViewCell *cell in lineCells) {
//        UIView *creditsCell = [[LPCCreditsCell alloc] initBasedOnCell:cell];
//        [self.view addSubview:creditsCell];
//        
//        //        UILabel *creditsLabel = [[LPCCreditsTextLabel alloc] initForCell:cell];
//        //        creditsLabel.numberOfLines = 3;
//        //        [creditsLabel setTextAlignment:NSTextAlignmentCenter];
//        
//        //        if (cellNumber == 0) {
//        //            [creditsCell addSubview:creditsLabel];
//        //            [creditsLabel setAttributedText:[parser attributedStringFromMarkdownString:@"## Pub Crawl: London"]];
//        //        } else if (cellNumber == 1) {
//        //            [creditsCell addSubview:creditsLabel];
//        //            [creditsLabel setAttributedText:[parser attributedStringFromMarkdownString:@"**Pub Crawl: LDN** is a Happily Project created in London, UK"]];
//        ////            [creditsLabel setText:@"Pub Crawl: LDN is a Happily Project\nCreated in London, UK"];
//        //        } else if (cellNumber == 2) {
//        //            [creditsCell addSubview:creditsLabel];
//        //            [creditsLabel setAttributedText:[parser attributedStringFromMarkdownString:@"For more visit **happilyltd.co**\nWe're very grateful for data from..."]];
//        //        } else if (cellNumber == 3) {
//        //            UIImageView *foursquareImageView = [[UIImageView alloc] initWithImage:foursquareLogo];
//        //            CGRect foursquareFrame = foursquareImageView.frame;
//        //            foursquareFrame.origin = creditsLabel.frame.origin;
//        //            foursquareFrame.origin.y = (creditsCell.frame.size.height - foursquareFrame.size.height) / 2;
//        //            foursquareImageView.frame = foursquareFrame;
//        //
//        //            UIImageView *mapBoxImageView = [[UIImageView alloc] initWithImage:mapBoxLogo];
//        //            CGRect mapBoxFrame = mapBoxImageView.frame;
//        //            mapBoxFrame.origin.y = (creditsCell.frame.size.height - mapBoxFrame.size.height) / 2;
//        //            mapBoxFrame.origin.x = creditsCell.frame.size.width - mapBoxFrame.size.width - foursquareFrame.origin.x;
//        //            mapBoxImageView.frame = mapBoxFrame;
//        //
//        //            UIImageView *tflImageView = [[UIImageView alloc] initWithImage:tflLogo];
//        //            CGRect tflFrame = tflImageView.frame;
//        //            tflFrame.origin.y = (creditsCell.frame.size.height - tflFrame.size.height) / 2;
//        //            CGFloat foursquareRightEdge = foursquareFrame.origin.x + foursquareFrame.size.width;
//        //            CGFloat middleSpace = mapBoxFrame.origin.x - foursquareRightEdge;
//        //            tflFrame.origin.x = foursquareRightEdge + ((middleSpace - tflFrame.size.width) / 2);
//        //            tflImageView.frame = tflFrame;
//        //
//        //            [creditsCell addSubview:foursquareImageView];
//        //            [creditsCell addSubview:tflImageView];
//        //            [creditsCell addSubview:mapBoxImageView];
//        //        } else if (cellNumber == 4) {
//        //            [creditsCell addSubview:creditsLabel];
//        //            [creditsLabel setAttributedText:[parser attributedStringFromMarkdownString:@"To get in touch, **use the following email address**"]];
//        //        } else if (cellNumber == 5) {
//        //            emailButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        //            emailButton.frame = creditsLabel.frame;
//        //            [emailButton setTitle:emailAddress forState:UIControlStateNormal];
//        //            [emailButton addTarget:self action:@selector(sendEmail) forControlEvents:UIControlEventTouchUpInside];
//        //            UILongPressGestureRecognizer *emailButtonLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondToEmailLongPress:)];
//        //            [emailButton addGestureRecognizer:emailButtonLongPress];
//        //            emailButton.backgroundColor = [UIColor whiteColor];
//        //            [creditsCell addSubview:emailButton];
//        //        } else if (cellNumber == 6) {
//        //            [creditsCell addSubview:creditsLabel];
//        //            [creditsLabel setAttributedText:[parser attributedStringFromMarkdownString:@"To keep in the loop, **enter your email address below** and hit **Go**"]];
//        //        } else if (cellNumber == 7) {
//        //            emailField = [[UITextField alloc] initWithFrame:creditsLabel.frame];
//        //            emailField.clipsToBounds = YES;
//        //            emailField.layer.cornerRadius = 10.0f;
//        //            emailField.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
//        //            [emailField setPlaceholder:@"your@emailaddress.com"];
//        //            [emailField setReturnKeyType:UIReturnKeyGo];
//        //            [emailField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//        //            [emailField setKeyboardType:UIKeyboardTypeEmailAddress];
//        //            emailField.textAlignment = NSTextAlignmentCenter;
//        //            emailField.delegate = self;
//        //            [creditsCell addSubview:emailField];
//        //        } else if (cellNumber == 8) {
//        //            [creditsCell addSubview:creditsLabel];
//        //            [creditsLabel setAttributedText:[parser attributedStringFromMarkdownString:@"Please, remember to drink responsibly :)"]];
//        //        } else if (cellNumber == 9) {
//        //            UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        //            doneButton.frame = creditsLabel.frame;
//        //            [doneButton setTitle:@"I promise. Back to the pubs!" forState:UIControlStateNormal];
//        //            [doneButton addTarget:self action:@selector(closeCredits) forControlEvents:UIControlEventTouchUpInside];
//        //            [creditsCell addSubview:doneButton];
//        //        }
//        
//        [self.view addSubview:creditsCell];
//    }
//    return self;
//}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if (textField == emailField) {
//        NSLog(@"Email address is %@", emailField.text);
//        if (self.delegate) {
//            [self.delegate didSubmitEmailAddress:emailField.text];
//        }
//        [emailField resignFirstResponder];
//        [emailField setText:@""];
//        // TODO: Something better than this!
//        [emailField setPlaceholder:@"thanks@forsubscribing.com"];
//    }
//    return YES;
//}
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [[event allTouches] anyObject];
//    if ([emailField isFirstResponder] && [touch view] != emailField) {
//        [emailField resignFirstResponder];
//    }
//    [super touchesBegan:touches withEvent:event];
//}
//
//- (void)respondToEmailLongPress:(UILongPressGestureRecognizer *)recognizer {
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        [self copyEmail];
//        return;
//    }
//}
//
//- (void)sendEmail {
//    [self.delegate didClickEmail:emailAddress];
//}
//
//- (void)copyEmail {
//    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//    pasteboard.string = emailAddress;
//}
//
//- (void)closeCredits {
//    [self.delegate didCloseCreditsView];
//}

@end
