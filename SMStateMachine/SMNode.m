//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SMNode.h"
#import "SMTransition.h"
#import "SMStateMachine.h"


@interface SMNode()
@property(strong, nonatomic) NSMutableArray *transitions;
@end

@implementation SMNode
@synthesize name = _name;
@synthesize transitions = _transitions;
@synthesize parent = _parent;

- (id)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

- (void)_entryWithContext:(SMStateMachineExecuteContext *)context withPiggyback: (NSDictionary *) piggyback {

}

- (void)_exitWithContext:(SMStateMachineExecuteContext *)context withPiggyback: (NSDictionary *) piggyback {

}

- (void) _postEvent:(NSString *)event withContext:(SMStateMachineExecuteContext *)context withPiggyback:(NSDictionary *)piggyback {
    
}

- (void)_addTransition:(SMTransition *)transition {
    [self.transitions addObject:transition];
}

- (SMTransition *)_getTransitionForEvent:(NSString *)event {
    for (SMTransition *curTr in self.transitions) {
        if ([curTr.event isEqualToString:event]) {
            return curTr;
        }
    }
    for (SMTransition *curTr in self.transitions) {
        if ([curTr.event isEqualToString:SMDEFAULT]) {
            return curTr;
        }
    }
    if (self.parent) {
        return [self.parent _getTransitionForEvent:event];
    }
    return nil;
}


- (NSMutableArray *)transitions {
    if (_transitions == nil) {
        _transitions = [[NSMutableArray alloc] init];
    }
    return _transitions;
}

- (NSString *) transitionsPlantuml {
    NSString *result = @"";
    for (SMTransition *transition in self.transitions) {
        result = [result stringByAppendingFormat:@"%@ --> %@ : %@\n", transition.from.name, transition.to.name ?: transition.from.name, transition.event];
    }
    return result;
}


@end
