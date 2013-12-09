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

- (LPCLinePosition *)positionOfParentFork {
    LPCLinePosition *parent = [[LPCLinePosition alloc] init];
    parent.mainLineIndex = self.mainLineIndex;
    
    return parent;
}

- (BOOL)beforePosition:(LPCLinePosition *)otherPosition {
    if (otherPosition.branchCode) {
        if (self.branchCode && otherPosition.branchCode) {
            if (self.branchLineIndex == otherPosition.branchLineIndex) {
                return self.branchLineIndex > 0;
            }
            return [self.branchCode isEqualToString:otherPosition.branchCode] && self.branchLineIndex < otherPosition.branchLineIndex;
        
        } else {
            return self.mainLineIndex <= otherPosition.mainLineIndex;
        }
    } else if (self.branchCode) {
        // The other one is on a branch but the other isn't
        if (self.mainLineIndex == otherPosition.mainLineIndex) {
            // self is on the branch that the other position forks onto
            if (self.branchLineIndex > 0) {
                // It's at the tail end of a branch
                return YES;
            }
        }
    } else {
        return self.mainLineIndex <= otherPosition.mainLineIndex;
    }
    return NO;
}

- (BOOL)afterPosition:(LPCLinePosition *)otherPosition {
    return [otherPosition beforePosition:self];
}

- (BOOL)isPartOfForkAtPosition:(LPCLinePosition *)otherPosition {
    return self.branchCode && otherPosition.mainLineIndex == self.mainLineIndex;
}

@end
