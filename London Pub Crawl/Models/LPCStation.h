#import <Foundation/Foundation.h>

@interface LPCStation : NSObject

@property (strong, nonatomic) NSString *nestoriaCode;
@property (strong, nonatomic) NSString *name;

- (id)initWithStation:(NSDictionary *)station;

@end
