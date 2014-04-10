#import "LPCCreditsView.h"

#import "LPCLineTableViewCell.h"
#import "LPCCreditsCell.h"
#import "LPCCreditsTextLabel.h"

@interface LPCCreditsView () <UITextFieldDelegate>
@end

@implementation LPCCreditsView {
    UITextField *emailField;
}

- (id)initFromTableView:(UITableView *)tableView andCells:(NSArray *)lineCells {
    UIImage *foursquareLogo = [UIImage imageNamed:@"foursquare-logo.png"];
    UIImage *mapBoxLogo = [UIImage imageNamed:@"mapbox-logo.png"];
    UIImage *tflLogo = [UIImage imageNamed:@"tfl-logo.png"];
    
    CGRect creditsViewStartingFrame = tableView.frame;
    creditsViewStartingFrame.origin.x = creditsViewStartingFrame.size.width;
    self = [super initWithFrame:creditsViewStartingFrame];
    int cellNumber = 0;
    for (LPCLineTableViewCell *cell in lineCells) {
        UIView *creditsCell = [[LPCCreditsCell alloc] initBasedOnCell:cell];
        UILabel *creditsLabel = [[LPCCreditsTextLabel alloc] initForCell:cell];
        
        if (cellNumber == 0) {
            [creditsCell addSubview:creditsLabel];
            [creditsLabel setText:@"Pub Crawl: LDN is a Happily Project\nCreated in London, UK"];
        } else if (cellNumber == 1) {
            [creditsCell addSubview:creditsLabel];
            [creditsLabel setText:@"For more visit happilyltd.co\nWe're very grateful for data from"];
        } else if (cellNumber == 2) {
            UIImageView *foursquareImageView = [[UIImageView alloc] initWithImage:foursquareLogo];
            CGRect foursquareFrame = foursquareImageView.frame;
            foursquareFrame.origin = creditsLabel.frame.origin;
            foursquareFrame.origin.y = (creditsCell.frame.size.height - foursquareFrame.size.height) / 2;
            foursquareImageView.frame = foursquareFrame;
            
            UIImageView *mapBoxImageView = [[UIImageView alloc] initWithImage:mapBoxLogo];
            CGRect mapBoxFrame = mapBoxImageView.frame;
            mapBoxFrame.origin.y = (creditsCell.frame.size.height - mapBoxFrame.size.height) / 2;
            mapBoxFrame.origin.x = creditsCell.frame.size.width - mapBoxFrame.size.width - foursquareFrame.origin.x;
            mapBoxImageView.frame = mapBoxFrame;
            
            UIImageView *tflImageView = [[UIImageView alloc] initWithImage:tflLogo];
            CGRect tflFrame = tflImageView.frame;
            tflFrame.origin.y = (creditsCell.frame.size.height - tflFrame.size.height) / 2;
            CGFloat foursquareRightEdge = foursquareFrame.origin.x + foursquareFrame.size.width;
            CGFloat middleSpace = mapBoxFrame.origin.x - foursquareRightEdge;
            tflFrame.origin.x = foursquareRightEdge + ((middleSpace - tflFrame.size.width) / 2);
            tflImageView.frame = tflFrame;
            
            [creditsCell addSubview:foursquareImageView];
            [creditsCell addSubview:tflImageView];
            [creditsCell addSubview:mapBoxImageView];
        } else if (cellNumber == 4) {
            [creditsCell addSubview:creditsLabel];
            [creditsLabel setText:@"To get started, select a line.\nFor help whilst on a line, tap the '?'"];
        } else if (cellNumber == 5) {
            [creditsCell addSubview:creditsLabel];
            [creditsLabel setText:@"To keep in the loop\nEnter your email address below."];
        } else if (cellNumber == 6) {
            emailField = [[UITextField alloc] initWithFrame:creditsLabel.frame];
            [emailField setPlaceholder:@"your@emailaddress.com"];
            [emailField setReturnKeyType:UIReturnKeyGo];
            [emailField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            [emailField setKeyboardType:UIKeyboardTypeEmailAddress];
            emailField.delegate = self;
            [creditsCell addSubview:emailField];
        } else if (cellNumber == 9) {
            UIButton *doneButton = [[UIButton alloc] initWithFrame:creditsLabel.frame];
            [doneButton setTitle:@"Great!" forState:UIControlStateNormal];
            [doneButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//            [doneButton addTarget:self action:@selector(hideCredits) forControlEvents:UIControlEventTouchUpInside];
            doneButton.backgroundColor = [UIColor whiteColor];
            [creditsCell addSubview:doneButton];
        }
        
        [self addSubview:creditsCell];
        
        cellNumber++;
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
//        [emailField setPlaceholder:@"Thanks!"];
//        emailField.enabled = NO;
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

@end
