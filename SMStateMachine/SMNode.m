//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates
//


#import "SMNode.h"
#import "SMTransition.h"
#import "SMStateMachine.h"

NSString *const  StateClassificationTypeKey =  @"StateClassificationTypeKey";
NSString *const  StateClassificationScopeKey =  @"StateClassificationScopeKey";

NSString *const  AssistantOsxMessageKey =  @"AssistantOsxMessage";
NSString *const  AssistantOsxSubMessageKey =  @"AssistantOsxSubMessage";
NSString *const  AssistantOsxMessageTypeKey =  @"AssistantOsxMessageType";
NSString *const  AssistantOsxHelpAnchorKey =  @"AssistantOsxHelpAnchor";

NSString *const  AssistantIosMessageKey =  @"AssistantIosMessage";
NSString *const  AssistantIosSubMessageKey =  @"AssistantIosSubMessage";
NSString *const  AssistantIosMessageTypeKey =  @"AssistantIosMessageType";
NSString *const  AssistantIosHelpAnchorKey =  @"AssistantIosHelpAnchor";


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
        } else if ([transition.event isEqualToString:@"cmdTouch"]) {
            arrowType = @"-[#BlueViolet,bold]->";
            arrowColor = @"<color:BlueViolet >";
        } else if ([transition.event isEqualToString:@"userChooseOk"]) {
            arrowType = @"-[#green,bold]->";
            arrowColor = @"<color:green >";
        } else if ([transition.event isEqualToString:@"userChooseCancel"]) {
            arrowType = @"-[#red,bold]->";
            arrowColor = @"<color:red >";
        } else if ([transition.event isEqualToString:@"userChooseVideo"]) {
            arrowType = @"-[#BlueViolet,bold]->";
            arrowColor = @"<color:BlueViolet >";
        } else if ([transition.event isEqualToString:@"userCloseVideo"]) {
            arrowType = @"-[#green,bold]->";
            arrowColor = @"<color:green >";
        } else if ([transition.event isEqualToString:@"_default_"]) {
            arrowType = @"-[#black,bold]->";
            arrowColor = @"<color:black >";
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

- (NSString *) assistantOsxMessage {
    return self.localProperties[AssistantOsxMessageKey];
}

- (void) setAssistantOsxMessage:(NSString *)assistantOsxMessage {
    [self willChangeValueForKey:@"assistantOsxMessage"];
    self.localProperties[AssistantOsxMessageKey] = [assistantOsxMessage copy];
    [self didChangeValueForKey:@"assistantOsxMessage"];
}

- (NSString *) assistantOsxSubMessage {
    return self.localProperties[AssistantOsxSubMessageKey];
}

- (void) setAssistantOsxSubMessage:(NSString *)assistantOsxSubMessage {
    [self willChangeValueForKey:@"assistantOsxSubMessage"];
    self.localProperties[AssistantOsxSubMessageKey] = [assistantOsxSubMessage copy];
    [self didChangeValueForKey:@"assistantOsxSubMessage"];
}

- (NSNumber *) assistantOsxMessageType {
    return self.localProperties[AssistantOsxMessageTypeKey];
}

- (void) setAssistantOsxMessageType:(NSNumber *)assistantOsxMessageType {
    [self willChangeValueForKey:@"assistantOsxMessageType"];
    self.localProperties[AssistantOsxMessageTypeKey] = [assistantOsxMessageType copy];
    [self didChangeValueForKey:@"assistantOsxMessageType"];
}

- (NSString *) assistantOsxHelpAnchor {
    return self.localProperties[AssistantOsxHelpAnchorKey];
}

- (void) setAssistantOsxHelpAnchor:(NSString *)assistantOsxHelpAnchor {
    [self willChangeValueForKey:@"assistantOsxHelpAnchor"];
    self.localProperties[AssistantOsxHelpAnchorKey] = [assistantOsxHelpAnchor copy];
    [self didChangeValueForKey:@"assistantOsxHelpAnchor"];
}

- (NSArray *) assistantIosMessage {
    return self.localProperties[AssistantIosMessageKey];
}

- (void) setAssistantIosMessage:(NSString *)assistantIosMessage {
    [self willChangeValueForKey:@"assistantIosMessages"];
    self.localProperties[AssistantIosMessageKey] = [assistantIosMessage copy];
    [self didChangeValueForKey:@"assistantIosMessages"];
}

- (NSString *) assistantIosSubMessage {
    return self.localProperties[AssistantIosSubMessageKey];
}

- (void) setAssistantIosSubMessage:(NSString *)assistantIosSubMessage {
    [self willChangeValueForKey:@"assistantIosSubMessage"];
    self.localProperties[AssistantIosSubMessageKey] = [assistantIosSubMessage copy];
    [self didChangeValueForKey:@"assistantIosSubMessage"];
}

- (NSNumber *) assistantIosMessageType {
    return self.localProperties[AssistantIosMessageTypeKey];
}

- (void) setAssistantIosMessageType:(NSNumber *)assistantIosMessageType {
    [self willChangeValueForKey:@"assistantIosMessageType"];
    self.localProperties[AssistantIosMessageTypeKey] = [assistantIosMessageType copy];
    [self didChangeValueForKey:@"assistantIosMessageType"];
}

- (NSString *) assistantIosHelpAnchor {
    return self.localProperties[AssistantIosHelpAnchorKey];
}

- (void) setAssistantIosHelpAnchor:(NSString *)assistantIosHelpAnchor {
    
}

@end
