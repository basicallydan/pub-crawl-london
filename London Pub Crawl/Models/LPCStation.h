#import <Foundation/Foundation.h>
#import "LPCLinePosition.h"
#import <MapKit/MapKit.h>

@interface LPCStation : NSObject

@property (strong, nonatomic) NSString *nestoriaCode;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *coordinate;
@property (strong, nonatomic) LPCLinePosition *linePosition;
@property (nonatomic) BOOL firstStation;
@property (nonatomic) BOOL terminatingStation;

- (id)initWithStation:(NSDictionary *)station;

@end
