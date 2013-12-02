#import <Foundation/Foundation.h>
#import "LPCStation.h"
#import "LPCLinePosition.h"

@class LPCLine; // Import in the .m file

typedef enum ForkDirection : NSInteger PlayerStateType;
enum ForkDirection : NSInteger {
    Left,
    Right
};

@interface LPCFork : NSObject

@property (strong, nonatomic) NSArray *destinationStations;
@property (strong, nonatomic) LPCLinePosition *linePosition;
@property (nonatomic) enum ForkDirection direction;

- (id)initWithFork:(NSDictionary *)fork forLine:(LPCLine *)line;
- (id)initWithFork:(NSDictionary *)fork forLine:(LPCLine *)line withPosition:(LPCLinePosition *)position;

- (LPCStation *)firstStationForDestination:(int)destinationIndex;

@end
