#import <Foundation/Foundation.h>

// A pointer which should be useful for refering to where we are on the line
// We will only ever use this when using LPCLine I expect
@interface LPCLinePosition : NSObject

@property int mainLineIndex;
@property (copy) NSString *branchCode;
@property int branchLineIndex;

- (LPCLinePosition *)previousPossiblePosition;
- (LPCLinePosition *)nextPossiblePosition;
- (LPCLinePosition *)positionOfParentFork;

- (BOOL)beforePosition:(LPCLinePosition *)otherPosition;
- (BOOL)afterPosition:(LPCLinePosition *)otherPosition;
- (BOOL)isPartOfForkAtPosition:(LPCLinePosition *)otherPosition;

@end