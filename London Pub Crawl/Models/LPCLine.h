#import <Foundation/Foundation.h>

@interface LPCLine : NSObject

@property (strong, nonatomic) NSArray *leafStations;
@property (strong, nonatomic) NSArray *allStations;

- (id)initWithLine:(NSDictionary *)line;

@end
