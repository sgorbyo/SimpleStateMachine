
#import "SMStateMachine.h"

@interface SMStateMachine ()
@property(strong, nonatomic, readonly) NSMutableArray *states;
@end

@implementation SMStateMachine
@synthesize states = _states;
@synthesize curState = _curState;
@synthesize globalExecuteIn = _globalExecuteIn;
@synthesize initialState = _initialState;
@synthesize monitor = _monitor;

- (NSArray *) allStates {
    return [self.states copy];
}

- (SMState *)createState:(NSString *)name {
    SMState *state = [[SMState alloc] initWithName:name];
    [self.states addObject:state];
    return state;
}

- (SMDecision *)createDecision:(NSString *)name withPredicateBoolBlock:(SMBoolDecisionBlock)block {
    SMDecision* node = [[SMDecision alloc] initWithName:name andBoolBlock:block];
    [self.states addObject:node];
    return node;
}

- (SMDecision *)createDecision:(NSString *)name withPredicateBlock:(SMDecisionBlock)block {
    SMDecision* node = [[SMDecision alloc] initWithName:name andBlock:block];
    [self.states addObject:node];
    return node;
}

- (void)transitionFrom:(SMNode *)fromState to:(SMNode *)toState forEvent:(NSString *)event {
    [self transitionFrom:fromState to:toState forEvent:event withAction:nil];
}

- (void)transitionFrom:(SMNode *)fromState to:(SMNode *)toState forEvent:(NSString *)event withBlock:(SMActionBlock)actionBlock {
    [self transitionFrom:fromState to:toState forEvent:event withAction:[SMAction actionWithBlock:actionBlock]];
}

- (void)trueTransitionFrom:(SMDecision *)fromState to:(SMNode *)toState {
    [self transitionFrom:fromState to:toState forEvent:SM_EVENT_TRUE withAction:nil];
}

- (void) trueTransitionFrom:(SMDecision *)fromState to:(SMNode *)toState withBlock:(SMActionBlock)actionBlock {
    [self transitionFrom:fromState to:toState forEvent:SM_EVENT_TRUE withAction:[SMAction actionWithBlock:actionBlock]];
}

- (void)falseTransitionFrom:(SMDecision *)fromState to:(SMNode *)toState {
    [self transitionFrom:fromState to:toState forEvent:SM_EVENT_FALSE withAction:nil];
}

- (void) falseTransitionFrom:(SMDecision *)fromState to:(SMNode *)toState withBlock:(SMActionBlock)actionBlock {
    [self transitionFrom:fromState to:toState forEvent:SM_EVENT_FALSE withAction:[SMAction actionWithBlock:actionBlock]];
}

- (void) internalTransitionFrom:(SMNode *)fromState forEvent:(NSString *)event {
    [self transitionFrom:fromState to:nil forEvent:event withAction:nil];
}

- (void) internalTransitionFrom:(SMNode *)fromState forEvent:(NSString *)event withBlock:(SMActionBlock)actionBlock {
    [self transitionFrom:fromState to:nil forEvent:event withAction:[SMAction actionWithBlock:actionBlock]];
}


- (void)transitionFrom:(SMNode *)fromState to:(SMNode *)toState forEvent:(NSString *)event withAction:(id<SMActionProtocol>)action {
    SMTransition *transition = [[SMTransition alloc] init];
    transition.from = fromState;
    transition.to = toState;
    transition.event = event;
    transition.action = action;
    [fromState _addTransition:transition];
}

- (void)validate {
    if ([self.states count] == 0) {
        [NSException raise:@"Invalid statemachine" format:@"No states"];
    }
    if (_initialState == nil) {
        [NSException raise:@"Invalid statemachine" format:@"initialState is nil"];
    }
        //TODO: Add more validations
}

- (void)post:(NSString *)event withPiggyback: (NSDictionary *) piggyback {
    SMStateMachineExecuteContext *context = [[SMStateMachineExecuteContext alloc] init];
    context.globalExecuteIn = self.globalExecuteIn;
    context.monitor = self.monitor;
    context.curState = _curState;
    [_curState _postEvent:event withContext:context withPiggyback:piggyback];
    _curState = context.curState;
}

- (NSMutableArray *)states {
    if (_states == nil) {
        _states = [[NSMutableArray alloc] init];
    }
    return _states;
}

-(void)setInitialState:(SMState*)aState {
    _initialState = aState;
    if (_curState == nil) {
        _curState = _initialState;
    }
}

- (NSDictionary *) statesTreeFrom: (NSString *) parent {
    NSMutableDictionary *dictionaryOfNodes = [NSMutableDictionary new];
    for (SMNode *node in self.states) {
        if (parent ? [node.parent.name isEqualToString:parent] : node.parent == nil) {
            dictionaryOfNodes[node.name] = [self statesTreeFrom:node.name];
        }
    }
    return [dictionaryOfNodes copy];
}

- (SMNode *) nodeWithName: (NSString *) name {
    for (SMNode *node in self.allStates) {
        if ([name isEqualToString:node.name]) {
            return node;
        }
    }
    return nil;
}

- (NSString *) hierarchyUml: (NSDictionary *) treeDictionary{
    NSString *result = @"";
    for (NSString *name in treeDictionary.allKeys) {
        NSDictionary *dictionary = treeDictionary[name];
        if (dictionary.count > 0) {
            result = [result stringByAppendingFormat:@"state %@ {\n", name];
            result = [result stringByAppendingString:[self hierarchyUml:dictionary]];
            result = [result stringByAppendingString:@"}\n"];
        } else {
            SMNode * node = [self nodeWithName:name];
            if ([node isMemberOfClass:[SMDecision class]]) {
                result = [result stringByAppendingFormat:@"state %@<<Decision>>\n", node.name];
            } else {
                result = [result stringByAppendingFormat:@"state %@\n", node.name];
            }
        }
    }
    return result;
}

- (NSString *) plantUml {
    NSString *result = @"";
    result = [result stringByAppendingString:@"@startuml\n"];
    result = [result stringByAppendingString:@"\tskinparam backgroundColor White\n"];
    result = [result stringByAppendingString:@"\tskinparam StateArrowColor Black\n"];
    result = [result stringByAppendingString:@"\tskinparam StateArrowColor<<Decision>> red\n"];
    result = [result stringByAppendingString:@"\tskinparam StateBackgroundColor White\n"];
    result = [result stringByAppendingString:@"\tskinparam StateBackgroundColor<<Decision>> Yellow\n"];
    result = [result stringByAppendingString:@"\tskinparam StateBorderColor<<Decision>> Red\n"];
    result = [result stringByAppendingString:@"\tskinparam StateBorderColor Black\n"];
    result = [result stringByAppendingString:@"\tskinparam StateFontName Arial\n"];
    result = [result stringByAppendingString:@"\tskinparam stateFontColor<<Decision>> Red\n"];
    result = [result stringByAppendingString:@"\tskinparam stateFontColor Black\n"];
    
    result = [result stringByAppendingFormat:@"[*] --> %@\n", self.initialState.name];
    
    result = [result stringByAppendingString:[self hierarchyUml:[self statesTreeFrom:nil]]];
    for (SMNode *node in self.allStates) {
        result = [result stringByAppendingString:[node transitionsPlantuml]];
    }
    result = [result stringByAppendingString:@"@enduml\n"];
    return result;
}

@end
