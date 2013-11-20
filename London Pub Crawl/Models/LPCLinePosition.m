#import "LPCLinePosition.h"

@implementation LPCLinePosition

- (NSString *) description {
    NSString *desc = [NSString stringWithFormat: @"%d", self.mainLineIndex];
    
    if (self.branchCode) {
        desc = [NSString stringWithFormat:@"%@.%@.%d", desc, self.branchCode, self.branchLineIndex];
    }
    
    return desc;
}

- (LPCLinePosition *)previousPossiblePosition {
    LPCLinePosition *previous = [[LPCLinePosition alloc] init];
    if (self.branchCode) {        
        previous.mainLineIndex = self.mainLineIndex;
        if (self.branchLineIndex > 0) {
            previous.branchCode = self.branchCode;
            previous.branchLineIndex = self.branchLineIndex - 1;
        }
    } else {
        if (self.mainLineIndex == 0) {
            return nil;
        }
        
        previous.mainLineIndex = self.mainLineIndex - 1;
    }
    
    return previous;
}

- (LPCLinePosition *)nextPossiblePosition {
    LPCLinePosition *next = [[LPCLinePosition alloc] init];
    if (self.branchCode) {
        next.mainLineIndex = self.mainLineIndex;
        next.branchCode = self.branchCode;
        next.branchLineIndex = self.branchLineIndex + 1;
    } else {
        next.mainLineIndex = self.mainLineIndex + 1;
    }
    
    return next;
}

@end
