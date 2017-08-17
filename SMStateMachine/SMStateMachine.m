#import "SMStateMachine.h"


NSString *CorrectLenghtAndCharForString(NSString *string, NSUInteger len) {
    NSString *result = @"";
    NSArray <NSString *> *mainArray = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray <NSString *> *splittedArray = [NSMutableArray new];
    for (NSString *part in mainArray) {
        if (part.length > len) {
            NSMutableArray <NSString *> *array = [[part componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
            while (array.count > 0) {
                NSString *small = @"";
                while (small.length < len && array.count > 0) {
                    if (small.length > 0) {
                        small = [small stringByAppendingString:@" "];
                    }
                    small = [small stringByAppendingString:array[0]];
                    [array removeObjectAtIndex:0];
                }
                [splittedArray addObject:small];
            }
        } else {
            [splittedArray addObject:part];
        }
    }
    for (NSString *string in splittedArray) {
        result = [result stringByAppendingString:string];
        result = [result stringByAppendingString:@"\\n"];
    }
    return result;
}


@interface SMStateMachine ()
@property(strong, nonatomic, readonly) NSMutableArray *states;
@property (strong, nonatomic) NSMutableArray *allowedTimingEvents;
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

- (SMState *)createState:(NSString *)name umlStateDescription:(nullable NSString *)umlStateDescription {
    SMState *state = [[SMState alloc] initWithName:name umlStateDescription:umlStateDescription];
    [self.states addObject:state];
    return state;
}

- (nullable SMStateWithUserMessage *)createStateWithUserMessage:(nonnull NSString *)name
                                            umlStateDescription: (nullable NSString *) umlStateDescription
                                                    messageType: (ILTMessageType) messageType
                                                          title: (nullable NSString *) title
                                                     messageOsx: (nullable NSString *) messageOsx
                                                     messageIos: (nullable NSString *) messageIos
                                                      helpTitle: (nullable NSString *) helpTitle
                                                   helpResource: (nullable NSString *) helpResource
                                                     suppressId: (nullable NSString *) suppressId
                                                        okTitle: (nullable NSString *) okTitle
                                                    cancelTitle: (nullable NSString *) cancelTitle {
    
    SMStateWithUserMessage *state = [[SMStateWithUserMessage alloc] initWithName:name
                                                             umlStateDescription:umlStateDescription
                                                                     messageType:messageType
                                                                           title:title
                                                                      messageOsx:messageOsx
                                                                      messageIos:messageIos
                                                                       helpTitle:helpTitle
                                                                    helpResource:helpResource
                                                                      suppressId:suppressId
                                                                         okTitle:okTitle
                                                                     cancelTitle:cancelTitle];
    [self.states addObject:state];
    return state;
}

- (SMDecision *)createDecision:(NSString *)name umlStateDescription: (nullable NSString *) umlStateDescription withPredicateBoolBlock:(SMBoolDecisionBlock)block {
    SMDecision* node = [[SMDecision alloc] initWithName:name umlStateDescription: umlStateDescription andBoolBlock:block];
    [self.states addObject:node];
    return node;
}

- (SMDecision *)createDecision:(NSString *)name umlStateDescription: (nullable NSString *) umlStateDescription withPredicateBlock:(SMDecisionBlock)block {
    SMDecision* node = [[SMDecision alloc] initWithName:name umlStateDescription: umlStateDescription andBlock:block];
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
    context.stateMachine = self;
    [_curState _postEvent:event withContext:context withPiggyback:piggyback];
    _curState = context.curState;
}

- (void)postAsync:(NSString *)event withPiggyback: (NSDictionary *) piggyback {
    dispatch_async(self.serialQueue, ^{
        [self post: event withPiggyback:piggyback];
    });
}

-(void)dropTimingEvent:(NSString *)eventUuid {
    if ([self.allowedTimingEvents containsObject:eventUuid]){
        [self.allowedTimingEvents removeObject:eventUuid];
    }
}

-(NSString *)postAsync:(NSString *)event withPiggyback:(NSDictionary *)piggyback after:(NSUInteger)milliseconds {
    __weak SMStateMachine* weakSelf = self;
    NSString *uuid = [self createUuid];
    [self.allowedTimingEvents addObject:uuid];
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, milliseconds * NSEC_PER_MSEC);
    dispatch_after(timeout, self.serialQueue, ^{
        if ([weakSelf.allowedTimingEvents containsObject:uuid]){
            [weakSelf.allowedTimingEvents removeObject:uuid];
            [weakSelf postAsync:event withPiggyback:piggyback];
        }
    });
    return uuid;
}

-(NSString *)createUuid{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString * res= (__bridge NSString *) (CFUUIDCreateString(kCFAllocatorDefault, uuid));
    return res;
}

-(NSMutableArray *)allowedTimingEvents {
    if (_allowedTimingEvents == nil){
        _allowedTimingEvents = [[NSMutableArray alloc] init];
    }
    return _allowedTimingEvents;
}

-(dispatch_queue_t)serialQueue {
    if (_serialQueue == NULL){
        _serialQueue = dispatch_get_main_queue();
    }
    return _serialQueue;
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

- (NSString *) listOfAttributes {
    NSString *result = @"";
    for (SMNode *node in self.allStates) {
        if (node.umlStateDescription) {
            result = [result stringByAppendingFormat:@"%@ : %@\n", node.name, CorrectLenghtAndCharForString(node.umlStateDescription, 35)];
        }
        if (node.stateClassificationType != iltSCNone) {
            switch (node.stateClassificationType) {
                case iltSCNormal:
                    result = [result stringByAppendingFormat:@"%@ : <b>Classification:</b> %@\n", node.name, @"Normal"];
                    break;
                case iltSCMovable:
                    result = [result stringByAppendingFormat:@"%@ : <b>Classification:</b> %@\n", node.name, @"Moveable"];
                    break;
                case iltSCMoving:
                    result = [result stringByAppendingFormat:@"%@ : <b>Classification:</b> %@\n", node.name, @"Moving"];
                    break;
                case iltSCConnectingOnSpace:
                    result = [result stringByAppendingFormat:@"%@ : <b>Classification:</b> %@\n", node.name, @"Connecting On Space"];
                    break;
                case iltSCConnectingOnAccepting:
                    result = [result stringByAppendingFormat:@"%@ : <b>Classification:</b> %@\n", node.name, @"Connecting On Accepting"];
                    break;
                case iltSCConnectingOnRefusing:
                    result = [result stringByAppendingFormat:@"%@ : <b>Classification:</b> %@\n", node.name, @"Connecting On Refusing"];
                    break;
                case iltSCAddingRemoving:
                    result = [result stringByAppendingFormat:@"%@ : <b>Classification:</b> %@\n", node.name, @"Adding, removing Idle"];
                    break;
                case iltSCAddingRemovingPlus:
                    result = [result stringByAppendingFormat:@"%@ : <b>Classification:</b> %@\n", node.name, @"Adding"];
                    break;
                case iltSCAddingRemovingMinus:
                    result = [result stringByAppendingFormat:@"%@ : <b>Classification:</b> %@\n", node.name, @"Removing"];
                    break;
                case iltSCAddingNew:
                    result = [result stringByAppendingFormat:@"%@ : <b>Classification:</b> %@\n", node.name, @"Adding New"];
                    break;
                default:
                    break;
            }
            if (node.stateClassificationScope == iltSSLocal) {
                result = [result stringByAppendingFormat:@"%@ : <b>Classification Scope:</b> %@\n", node.name, @"Local"];
            } else {
                result = [result stringByAppendingFormat:@"%@ : <b>Classification Scope:</b> %@\n", node.name, @"Global"];
            }
            
        }
        if ([node isMemberOfClass:[SMStateWithUserMessage class]]) {
            result = [result stringByAppendingFormat:@"%@ : ..Messages..\n" , node.name];
            SMStateWithUserMessage *state = (SMStateWithUserMessage *) node;
            result = [result stringByAppendingFormat:@"%@ : <b>Type:</b> %@\n" , state.name, state.messageTypeDescription];
            result = [result stringByAppendingFormat:@"%@ : <b>Title:</b>\\n%@\n" , state.name, state.title];
            result = [result stringByAppendingFormat:@"%@ : <b>MessageOsx:</b>\\n%@\n" , state.name, CorrectLenghtAndCharForString(state.messageOsx, 35)];
            result = [result stringByAppendingFormat:@"%@ : <b>MessageIos:</b>\\n%@\n" , state.name, CorrectLenghtAndCharForString(state.messageIos, 35)];
            result = [result stringByAppendingFormat:@"%@ : <b>HelpTitle:</b> %@\n" , state.name, state.helpTitle];
            result = [result stringByAppendingFormat:@"%@ : <b>HelpResource:</b> %@\n" , state.name, state.helpResource];
            result = [result stringByAppendingFormat:@"%@ : <b>SuppressId:</b> %@\n" , state.name, state.suppressId];
            result = [result stringByAppendingFormat:@"%@ : <b>OkTitle:</b> %@\n" , state.name, state.okTitle];
            result = [result stringByAppendingFormat:@"%@ : <b>CancelTitle:</b> %@\n" , state.name, state.cancelTitle];
        }
        if (!!node.assistantOsxMessageType || (!!node.assistantOsxMessage && node.assistantOsxMessage.length > 0) || !!node.assistantOsxSubMessage) {
            result = [result stringByAppendingFormat:@"%@ : <b>OS X Assistant:</b> %@\n" , node.name, CorrectLenghtAndCharForString(node.assistantOsxMessage, 35)];
        }
        
        if (!!node.assistantOsxSubMessage) {
            result = [result stringByAppendingFormat:@"%@ : <b>OS X SubMessage:</b> %@\n" , node.name, CorrectLenghtAndCharForString(node.assistantOsxSubMessage, 35)];
        }
        if (!!node.assistantOsxMessageType) {
            result = [result stringByAppendingFormat:@"%@ : <b>OS XType:</b> %@\n" , node.name, node.assistantOsxMessageType];
        }
        
        if (!!node.assistantIosMessageType || (!!node.assistantIosMessage && node.assistantIosMessage.length > 0) || !!node.assistantIosSubMessage) {
            result = [result stringByAppendingFormat:@"%@ : <b>iOS Assistant:</b> %@\n" , node.name, CorrectLenghtAndCharForString(node.assistantIosMessage, 35)];
        }
        if (!!node.assistantIosSubMessage) {
            result = [result stringByAppendingFormat:@"%@ : <b>iOS SubMessage:</b> %@\n" , node.name, CorrectLenghtAndCharForString(node.assistantIosSubMessage, 35)];
        }
        if (!!node.assistantIosMessageType) {
            result = [result stringByAppendingFormat:@"%@ : <b>iOS Type:</b> %@\n" , node.name, node.assistantIosMessageType];
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
    
    if (self.stateMachineName.length > 0) {
        result = [result stringByAppendingFormat:@"title **%@**\n", self.stateMachineName];
    }
    
    result = [result stringByAppendingFormat:@"[*] --> %@\n", self.initialState.name];
    
    result = [result stringByAppendingString:[self hierarchyUml:[self statesTreeFrom:nil]]];
    for (SMNode *node in self.allStates) {
        result = [result stringByAppendingString:[node transitionsPlantuml]];
    }
    result = [result stringByAppendingString:[self listOfAttributes]];
    result = [result stringByAppendingString:@"@enduml\n"];
    return result;
}

@end
