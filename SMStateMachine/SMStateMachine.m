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

- (SMState *) createState:(NSString *)name
      umlStateDescription:(nullable NSString *)umlStateDescription
            operationType:(IGenogramOperation)operationType
          stateCursorType:(SMStateCursorType)stateCursorType
         stateCursorScope:(SMStateCursorScope)stateCursorScope
           assistantClear:(BOOL)assistantClear {
    SMState *state = [[SMState alloc] initWithName:name
                               umlStateDescription:umlStateDescription
                                     operationType:operationType
                                   stateCursorType:stateCursorType
                                  stateCursorScope:stateCursorScope
                                    assistantClear:assistantClear];
    [self.states addObject:state];
    return state;
}

- (nullable SMState *) createAssistantStateWithName:(NSString *)name
                                umlStateDescription:(NSString *)umlStateDescription
                                      operationType:(IGenogramOperation)operationType
                                    stateCursorType:(SMStateCursorType)stateCursorType
                                   stateCursorScope:(SMStateCursorScope)stateCursorScope
                                         osxMessage:(NSString *)osxMessage
                                         iosMessage:(NSString *)iosMessage
                                      osxHelpAnchor:(NSString *)osxHelpAnchor
                                      iosHelpAnchor:(NSString *)iosHelpAnchor
                                   osxAssistantType:(SMStateAssistantOptions)osxAssistantType
                                   iosAssistantType:(SMStateAssistantOptions)iosAssistantType
                                             parent:(SMState *)parent {
    
    SMState *state = [[SMState alloc] initAssistantStateWithName:name
                                             umlStateDescription:umlStateDescription
                                                   operationType:operationType
                                                      osxMessage:osxMessage
                                                      iosMessage:iosMessage
                                                   osxHelpAnchor:osxHelpAnchor
                                                   iosHelpAnchor:iosHelpAnchor
                                                osxAssistantType:osxAssistantType
                                                iosAssistantType:iosAssistantType];
    state.stateCursorType = stateCursorType;
    state.stateCursorScope = stateCursorScope;
    state.parent = parent;
    [self.states addObject:state];
    return state;
}

- (SMState *) createIndividualOnTheFlyStateWithName:(NSString *)name
                                umlStateDescription:(NSString *)umlStateDescription
                                      operationType:(IGenogramOperation)operationType
                           cancelAddIndividualBlock:(SMIndividualOntheFlyBlock) cancelAddIndividualBlock
                                 addIndividualBlock:(SMIndividualOntheFlyBlock) addIndividualBlock
                                             parent:(SMState *)parent {
    
    SMState *state = [[SMState alloc] initWithName:name
                               umlStateDescription:umlStateDescription
                                     operationType:operationType
                                   stateCursorType:SMStateCursorTypeNone
                                  stateCursorScope:SMStateCursorScopeNone
                                    assistantClear:NO];
    
    state.onTheFlyCancelAddIndividualBlock = cancelAddIndividualBlock;
    state.onTheFlyAddIndividualBlock = addIndividualBlock;
    state.messageType = SMMessageTypeOnTheFlyIndividual;
    
    state.parent = parent;
    
    [self.states addObject:state];
    return state;
}

- (SMState *) createCoupleOnTheFlyStateWithName:(NSString *)name
                            umlStateDescription:(NSString *)umlStateDescription
                                  operationType:(IGenogramOperation)operationType
                           cancelAddCoupleBlock: (SMCoupleOntheFlyBlock) cancelAddCoupleBlock
                                 addCoupleBlock: (SMCoupleOntheFlyBlock) addCoupleBlock
                                         parent:(SMState *)parent {
    
    SMState *state = [[SMState alloc] initWithName:name
                               umlStateDescription:umlStateDescription
                                     operationType:operationType
                                   stateCursorType:SMStateCursorTypeNone
                                  stateCursorScope:SMStateCursorScopeNone
                                    assistantClear:NO];
    
    state.onTheFlyCancelAddCoupleBlock  = cancelAddCoupleBlock;
    state.onTheFlyAddCoupleBlock = addCoupleBlock;
    state.messageType = SMMessageTypeOnTheFlyParents;
    
    state.parent = parent;
    
    [self.states addObject:state];
    return state;
}

- (SMState *)createMessageBoxStateWithName:(NSString *)name
                       umlStateDescription:(NSString *)umlStateDescription
                             operationType:(IGenogramOperation)operationType
                               messageType:(SMMessageType) messageType
                                osxMessage:(NSString *)osxMessage
                        osxInformativeText:(NSString *)osxInformativeText
                                iosMessage:(NSString *)iosMessage
                        iosInformativeText:(NSString *)iosInformativeText
                             osxHelpAnchor:(NSString *)osxHelpAnchor
                             iosHelpAnchor:(NSString *)iosHelpAnchor
                                   okTitle:(NSString *)okTitle
                               cancelTitle:(NSString *)cancelTitle
                                suppressId:(NSString *)suppressId
                                    parent:(SMState *)parent {
    
    SMState *state = [[SMState alloc] initMessageBoxStateWithName:name
                                              umlStateDescription:umlStateDescription
                                                    operationType:operationType
                                                       osxMessage:osxMessage
                                                       iosMessage:iosMessage
                                                    osxHelpAnchor:osxHelpAnchor
                                                    iosHelpAnchor:iosHelpAnchor
                                                          okTitle:okTitle
                                                      cancelTitle:cancelTitle
                                                       suppressId:suppressId];
    state.messageType = messageType;
    state.iosInformativeText = iosInformativeText;
    state.osxInformativeText = osxInformativeText;
    state.parent = parent;
    [self.states addObject:state];
    return state;
}

- (SMDecision *) createDecision:(NSString *)name
            umlStateDescription: (nullable NSString *) umlStateDescription
                  operationType: (IGenogramOperation) operationType
         withPredicateBoolBlock:(SMBoolDecisionBlock)block {

    SMDecision* node = [[SMDecision alloc] initWithName:name
                                    umlStateDescription: umlStateDescription
                                          operationType:operationType
                                           andBoolBlock:block];
    [self.states addObject:node];
    return node;
}

- (SMDecision *)createDecision:(NSString *)name
           umlStateDescription: (nullable NSString *) umlStateDescription
                 operationType: (IGenogramOperation) operationType
            withPredicateBlock:(SMDecisionBlock)block {

    SMDecision* node = [[SMDecision alloc] initWithName:name
                                    umlStateDescription: umlStateDescription
                                          operationType:operationType
                                               andBlock:block];
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
    NSUUID *uuid = [NSUUID UUID];
    NSString * res= uuid.UUIDString;
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
                result = [result stringByAppendingFormat:@"state %@ %@ \n", node.name, node.stateColor ? [NSString stringWithFormat:@"#%@", node.stateColor] : @""];
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
        if (node.stateCursorType != SMStateCursorTypeNone) {
            switch (node.stateCursorType) {
                case SMStateCursorTypeNormal:
                    result = [result stringByAppendingFormat:@"%@ : <b>Cursor type:</b> %@\n", node.name, @"Normal"];
                    break;
                case SMStateCursorTypeMovable:
                    result = [result stringByAppendingFormat:@"%@ : <b>Cursor type:</b> %@\n", node.name, @"Moveable"];
                    break;
                case SMStateCursorTypeMoving:
                    result = [result stringByAppendingFormat:@"%@ : <b>Cursor type:</b> %@\n", node.name, @"Moving"];
                    break;
                case SMStateCursorTypeConnectingOnSpace:
                    result = [result stringByAppendingFormat:@"%@ : <b>Cursor type:</b> %@\n", node.name, @"Connecting On Space"];
                    break;
                case SMStateCursorTypeConnectingOnAccepting:
                    result = [result stringByAppendingFormat:@"%@ : <b>Cursor type:</b> %@\n", node.name, @"Connecting On Accepting"];
                    break;
                case SMStateCursorTypeConnectingOnRefusing:
                    result = [result stringByAppendingFormat:@"%@ : <b>Cursor type:</b> %@\n", node.name, @"Connecting On Refusing"];
                    break;
                case SMStateCursorTypeAddingRemoving:
                    result = [result stringByAppendingFormat:@"%@ : <b>Cursor type:</b> %@\n", node.name, @"Adding, removing Idle"];
                    break;
                case SMStateCursorTypeAddingRemovingPlus:
                    result = [result stringByAppendingFormat:@"%@ : <b>Cursor type:</b> %@\n", node.name, @"Adding"];
                    break;
                case SMStateCursorTypeAddingRemovingMinus:
                    result = [result stringByAppendingFormat:@"%@ : <b>Cursor type:</b> %@\n", node.name, @"Removing"];
                    break;
                case SMStateCursorTypeAddingNew:
                    result = [result stringByAppendingFormat:@"%@ : <b>Cursor type:</b> %@\n", node.name, @"Adding New"];
                    break;
                default:
                    break;
            }
            if (node.stateCursorScope == SMStateCursorScopeLocal) {
                result = [result stringByAppendingFormat:@"%@ : <b>Cursor Scope:</b> %@\n", node.name, @"Local"];
            } else {
                result = [result stringByAppendingFormat:@"%@ : <b>Cursor Scope:</b> %@\n", node.name, @"Global"];
            }
            
        }
        result = [result stringByAppendingFormat:@"%@ : %@\n" , node.name, node.messageTypeDescription];
        result = [result stringByAppendingFormat:@"%@ : <b>Type:</b> %@\n" , node.name, node.messageTypeDescription];
        result = [result stringByAppendingFormat:@"%@ : <b>Osx Operation:</b>\\n%@\n" , node.name, node.osxTitle];
        result = [result stringByAppendingFormat:@"%@ : <b>Ios Operation:</b>\\n%@\n" , node.name, node.iosTitle];
        switch (node.messageType) {
            case SMMessageTypeWarning:
            case SMMessageTypeCritical:
            case SMMessageTypeInformation:
                result = [result stringByAppendingFormat:@"%@ : <b>MessageOsx:</b>\\n%@\n" , node.name, CorrectLenghtAndCharForString(node.osxMessage, 35)];
                result = [result stringByAppendingFormat:@"%@ : <b>InformativeTextOsx:</b>\\n%@\n" , node.name, CorrectLenghtAndCharForString(node.osxInformativeText, 35)];
                result = [result stringByAppendingFormat:@"%@ : <b>OsxHelpAnchor:</b> %@\n" , node.name, node.osxHelpAnchor];
                result = [result stringByAppendingFormat:@"%@ : <b>MessageIos:</b>\\n%@\n" , node.name, CorrectLenghtAndCharForString(node.iosMessage, 35)];
                result = [result stringByAppendingFormat:@"%@ : <b>InformativeTextIos:</b>\\n%@\n" , node.name, CorrectLenghtAndCharForString(node.iosInformativeText, 35)];
                result = [result stringByAppendingFormat:@"%@ : <b>IosHelpAnchor:</b> %@\n" , node.name, node.iosHelpAnchor];
                result = [result stringByAppendingFormat:@"%@ : <b>SuppressId:</b> %@\n" , node.name, node.suppressId];
                result = [result stringByAppendingFormat:@"%@ : <b>OkTitle:</b> %@\n" , node.name, node.okTitle];
                result = [result stringByAppendingFormat:@"%@ : <b>CancelTitle:</b> %@\n" , node.name, node.cancelTitle];
                break;
            case SMMessageTypeAssistant:
                result = [result stringByAppendingFormat:@"%@ : <b>MessageOsx:</b>\\n%@\n" , node.name, CorrectLenghtAndCharForString(node.osxMessage, 35)];
                result = [result stringByAppendingFormat:@"%@ : <b>OsxHelpAnchor:</b> %@\n" , node.name, node.osxHelpAnchor];
                result = [result stringByAppendingFormat:@"%@ : <b>MessageIos:</b>\\n%@\n" , node.name, CorrectLenghtAndCharForString(node.iosMessage, 35)];
                result = [result stringByAppendingFormat:@"%@ : <b>IosHelpAnchor:</b> %@\n" , node.name, node.iosHelpAnchor];
                if (node.osxAssistantOptions & SMStateAssistantOptionsRemoveAssistant) {
                    result = [result stringByAppendingFormat:@"%@ : <b>Clear Assistant Area</b>\n" , node.name];
                } else {
                    if (node.osxAssistantOptions & SMStateAssistantOptionsOkButton) {
                        result = [result stringByAppendingFormat:@"%@ : <b>Osx OK Button</b>\n" , node.name];
                    }
                    if (node.iosAssistantOptions & SMStateAssistantOptionsOkButton) {
                        result = [result stringByAppendingFormat:@"%@ : <b>Ios OK Button</b>\n" , node.name];
                    }
                    if (node.osxAssistantOptions & SMStateAssistantOptionsCancelButton) {
                        result = [result stringByAppendingFormat:@"%@ : <b>Osx CANCEL Button</b>\n" , node.name];
                    }
                    if (node.iosAssistantOptions & SMStateAssistantOptionsCancelButton) {
                        result = [result stringByAppendingFormat:@"%@ : <b>Ios CANCEL Button</b>\n" , node.name];
                    }
                }
                break;
            case SMMessageTypeOnTheFlyIndividual:
                result = [result stringByAppendingFormat:@"%@ : <b>Initial Individual Type:</b>\\n%d\n" , node.name, node.onTheFlyStartingIndividualType];
                break;
            case SMMessageTypeOnTheFlyParents:
                result = [result stringByAppendingFormat:@"%@ : <b>Initial Couple Type:</b>\\n%d\n" , node.name, node.onTheFlyStartingCoupleType];
                result = [result stringByAppendingFormat:@"%@ : <b>Initial Individual1 Type:</b>\\n%d\n" , node.name, node.onTheFlyStartingIndividualType];
                result = [result stringByAppendingFormat:@"%@ : <b>Initial Individual2 Type:</b>\\n%d\n" , node.name, node.onTheFlyStartingIndividualType2];
            default:
                break;
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
