#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LPCMapAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) NSInteger type;

- (LPCMapAnnotation *)initWithCoordinate:(CLLocationCoordinate2D )coordinate andType:(NSInteger)type;

@end