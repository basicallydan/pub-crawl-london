#import <UIKit/UIKit.h>
#import "LPCStation.h"
#import "LPCLinePosition.h"

@interface LPCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *lines;
@property (strong, nonatomic) NSDictionary *stations;
@property (strong, nonatomic) NSDictionary *pubs;
@property (strong, nonatomic) NSArray *linesArray;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

- (UIColor *)colorForLine:(NSString *)lineCode;

+ (LPCStation *)stationWithNestoriaCode:(NSString *)nestoriaCode atPosition:(LPCLinePosition *)position;

@end
