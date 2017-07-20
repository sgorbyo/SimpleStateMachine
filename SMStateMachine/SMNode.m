//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SMNode.h"
#import "SMTransition.h"
#import "SMStateMachine.h"

NSString *const  StateClassificationTypeKey =  @"StateClassificationTypeKey";
NSString *const  StateClassificationScopeKey =  @"StateClassificationScopeKey";

@interface SMNode()
@property(strong, nonatomic) NSMutableArray *transitions;
@end

@implementation SMNode
@synthesize name = _name;
@synthesize transitions = _transitions;
@synthesize parent = _parent;

- (instancetype) initWithName:(nonnull NSString *)name umlStateDescription:(nullable NSString *)umlStateDescription{
    self = [super init];
    if (self) {
        _name = name;
        _localProperties = [NSMutableDictionary new];
        _umlStateDescription = umlStateDescription;
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

- (void) setStateClassificationType:(iltStateClassificationType)stateClassificationType {
    self.localProperties[StateClassificationTypeKey] = @(stateClassificationType);
}

- (iltStateClassificationType) stateClassificationType {
    if (!self.localProperties[StateClassificationTypeKey]) {
        self.localProperties[StateClassificationTypeKey] = @(iltSCNone);
    }
    NSNumber *number = self.localProperties[StateClassificationTypeKey];
    return number.unsignedIntegerValue;
}

- (void) setStateClassificationScope:(iltStateClassificationScope)stateClassificationScope {
    self.localProperties[StateClassificationScopeKey] = @(stateClassificationScope);
}

- (iltStateClassificationScope) stateClassificationScope {
    if (!self.localProperties[StateClassificationScopeKey]) {
        self.localProperties[StateClassificationScopeKey] = @(iltSSIndifferent);
    }
    NSNumber *number = self.localProperties[StateClassificationScopeKey];
    return number.unsignedIntegerValue;
}


- (NSString *) transitionsPlantuml {
    NSString *result = @"";
    NSString *arrowType = nil;
    NSString *arrowColor = nil;
    for (SMTransition *transition in self.transitions) {
        if ([transition.event isEqualToString:@"SM_TRUE"]) {
            arrowType = @"-[#green,bold]->";
            arrowColor = @"<color:Green>";
        } else if ([transition.event isEqualToString:@"SM_FALSE"]) {
            arrowType = @"-[#red,bold]->";
            arrowColor = @"<color:Red>";
        } else if ([transition.event isEqualToString:@"dragTouchStart"]) {
            arrowType = @"-[#Blue,bold]->";
            arrowColor = @"<color:Blue>";
        } else if ([transition.event isEqualToString:@"dragTouchContinue"]) {
            arrowType = @"-[#Magenta,bold]->";
            arrowColor = @"<color:Magenta>";
        } else if ([transition.event isEqualToString:@"dragTouchEnd"]) {
            arrowType = @"-[#Violet,bold]->";
            arrowColor = @"<color:Violet>";
        } else if ([transition.event isEqualToString:@"touch"]) {
            arrowType = @"-[#DarkSeaGreen,bold]->";
            arrowColor = @"<color:DarkSeaGreen>";
        } else if ([transition.event isEqualToString:@"doubleTouch"]) {
            arrowType = @"-[#Darkorange,bold]->";
            arrowColor = @"<color:Darkorange>";
        } else {
            arrowType = @"-->";
            arrowColor = @"<color:Black>";
        }
        result = [result stringByAppendingFormat:@"%@ %@ %@ : %@%@\n", transition.from.name, arrowType, transition.to.name ?: transition.from.name, arrowColor, transition.event];
    }
    return result;
}


@end
