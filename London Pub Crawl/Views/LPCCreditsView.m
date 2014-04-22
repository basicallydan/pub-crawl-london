#import "LPCCreditsView.h"

#import "LPCLineTableViewCell.h"
#import "LPCCreditsCell.h"
#import "LPCCreditsTextLabel.h"
#import "LPCThemeManager.h"
#import <UIColor+HexString.h>
#import <NSAttributedStringMarkdownParser/NSAttributedStringMarkdownParser.h>
#import <CGLMail/CGLMailHelper.h>

@interface LPCCreditsView () <UITextFieldDelegate>
@end

@implementation LPCCreditsView {
    UITextField *emailField;
    UIButton *emailButton;
}

NSString *const emailAddress = @"info+pubcrawl@happilyltd.co";

- (id)initFromTableView:(UITableView *)tableView andCells:(NSArray *)lineCells {
    UIImage *foursquareLogo = [UIImage imageNamed:@"foursquare-logo.png"];
    UIImage *mapBoxLogo = [UIImage imageNamed:@"mapbox-logo.png"];
    UIImage *tflLogo = [UIImage imageNamed:@"tfl-logo.png"];
    
    NSAttributedStringMarkdownParser* parser = [[NSAttributedStringMarkdownParser alloc] init];
    [parser setParagraphFont:[UIFont systemFontOfSize:15.0f]];
    
    CGRect creditsViewStartingFrame = tableView.frame;
    creditsViewStartingFrame.origin.x = creditsViewStartingFrame.size.width;
    self = [super initWithFrame:creditsViewStartingFrame];
//    int cellNumber = 0;
    for (LPCLineTableViewCell *cell in lineCells) {
        UIView *creditsCell = [[LPCCreditsCell alloc] initBasedOnCell:cell];
//        UILabel *creditsLabel = [[LPCCreditsTextLabel alloc] initForCell:cell];
//        creditsLabel.numberOfLines = 3;
//        [creditsLabel setTextAlignment:NSTextAlignmentCenter];
        
//        if (cellNumber == 0) {
//            [creditsCell addSubview:creditsLabel];
//            [creditsLabel setAttributedText:[parser attributedStringFromMarkdownString:@"## Pub Crawl: London"]];
//        } else if (cellNumber == 1) {
//            [creditsCell addSubview:creditsLabel];
//            [creditsLabel setAttributedText:[parser attributedStringFromMarkdownString:@"**Pub Crawl: LDN** is a Happily Project created in London, UK"]];
////            [creditsLabel setText:@"Pub Crawl: LDN is a Happily Project\nCreated in London, UK"];
//        } else if (cellNumber == 2) {
//            [creditsCell addSubview:creditsLabel];
//            [creditsLabel setAttributedText:[parser attributedStringFromMarkdownString:@"For more visit **happilyltd.co**\nWe're very grateful for data from..."]];
//        } else if (cellNumber == 3) {
//            UIImageView *foursquareImageView = [[UIImageView alloc] initWithImage:foursquareLogo];
//            CGRect foursquareFrame = foursquareImageView.frame;
//            foursquareFrame.origin = creditsLabel.frame.origin;
//            foursquareFrame.origin.y = (creditsCell.frame.size.height - foursquareFrame.size.height) / 2;
//            foursquareImageView.frame = foursquareFrame;
//            
//            UIImageView *mapBoxImageView = [[UIImageView alloc] initWithImage:mapBoxLogo];
//            CGRect mapBoxFrame = mapBoxImageView.frame;
//            mapBoxFrame.origin.y = (creditsCell.frame.size.height - mapBoxFrame.size.height) / 2;
//            mapBoxFrame.origin.x = creditsCell.frame.size.width - mapBoxFrame.size.width - foursquareFrame.origin.x;
//            mapBoxImageView.frame = mapBoxFrame;
//            
//            UIImageView *tflImageView = [[UIImageView alloc] initWithImage:tflLogo];
//            CGRect tflFrame = tflImageView.frame;
//            tflFrame.origin.y = (creditsCell.frame.size.height - tflFrame.size.height) / 2;
//            CGFloat foursquareRightEdge = foursquareFrame.origin.x + foursquareFrame.size.width;
//            CGFloat middleSpace = mapBoxFrame.origin.x - foursquareRightEdge;
//            tflFrame.origin.x = foursquareRightEdge + ((middleSpace - tflFrame.size.width) / 2);
//            tflImageView.frame = tflFrame;
//            
//            [creditsCell addSubview:foursquareImageView];
//            [creditsCell addSubview:tflImageView];
//            [creditsCell addSubview:mapBoxImageView];
//        } else if (cellNumber == 4) {
//            [creditsCell addSubview:creditsLabel];
//            [creditsLabel setAttributedText:[parser attributedStringFromMarkdownString:@"To get in touch, **use the following email address**"]];
//        } else if (cellNumber == 5) {
//            emailButton = [UIButton buttonWithType:UIButtonTypeSystem];
//            emailButton.frame = creditsLabel.frame;
//            [emailButton setTitle:emailAddress forState:UIControlStateNormal];
//            [emailButton addTarget:self action:@selector(sendEmail) forControlEvents:UIControlEventTouchUpInside];
//            UILongPressGestureRecognizer *emailButtonLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondToEmailLongPress:)];
//            [emailButton addGestureRecognizer:emailButtonLongPress];
//            emailButton.backgroundColor = [UIColor whiteColor];
//            [creditsCell addSubview:emailButton];
//        } else if (cellNumber == 6) {
//            [creditsCell addSubview:creditsLabel];
//            [creditsLabel setAttributedText:[parser attributedStringFromMarkdownString:@"To keep in the loop, **enter your email address below** and hit **Go**"]];
//        } else if (cellNumber == 7) {
//            emailField = [[UITextField alloc] initWithFrame:creditsLabel.frame];
//            emailField.clipsToBounds = YES;
//            emailField.layer.cornerRadius = 10.0f;
//            emailField.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
//            [emailField setPlaceholder:@"your@emailaddress.com"];
//            [emailField setReturnKeyType:UIReturnKeyGo];
//            [emailField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//            [emailField setKeyboardType:UIKeyboardTypeEmailAddress];
//            emailField.textAlignment = NSTextAlignmentCenter;
//            emailField.delegate = self;
//            [creditsCell addSubview:emailField];
//        } else if (cellNumber == 8) {
//            [creditsCell addSubview:creditsLabel];
//            [creditsLabel setAttributedText:[parser attributedStringFromMarkdownString:@"Please, remember to drink responsibly :)"]];
//        } else if (cellNumber == 9) {
//            UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
//            doneButton.frame = creditsLabel.frame;
//            [doneButton setTitle:@"I promise. Back to the pubs!" forState:UIControlStateNormal];
//            [doneButton addTarget:self action:@selector(closeCredits) forControlEvents:UIControlEventTouchUpInside];
//            [creditsCell addSubview:doneButton];
//        }
        
        [self addSubview:creditsCell];
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == emailField) {
        NSLog(@"Email address is %@", emailField.text);
        if (self.delegate) {
            [self.delegate didSubmitEmailAddress:emailField.text];
        }
        [emailField resignFirstResponder];
        [emailField setText:@""];
        // TODO: Something better than this!
        [emailField setPlaceholder:@"thanks@forsubscribing.com"];
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([emailField isFirstResponder] && [touch view] != emailField) {
        [emailField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)respondToEmailLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self copyEmail];
        return;
    }
}

- (void)sendEmail {
    [self.delegate didClickEmail:emailAddress];
}

- (void)copyEmail {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = emailAddress;
}

- (void)closeCredits {
    [self.delegate didCloseCreditsView];
}

@end
