//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates
//


#import "SMAction.h"
 
@implementation SMAction

+ (SMAction *)actionWithBlock:(SMActionBlock)actionBlock {
    return [[SMAction alloc] initWithBlock:actionBlock];
}

- (id) initWithBlock:(SMActionBlock)actionBlock {
    self = [super init];
    if (self) {
        _actionBlock = actionBlock;
    }
    return self;
}

- (void)executeWithPiggyback: (NSDictionary *) piggyback{
    if (self.actionBlock == nil) {
        return;
    } else {
        self.actionBlock(piggyback);
    }
}

@end
