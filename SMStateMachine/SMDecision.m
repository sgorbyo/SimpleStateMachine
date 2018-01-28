//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates
//


#import "SMDecision.h"
#import "SMCommon.h"
#import "SMTransition.h"


@implementation SMDecision
@synthesize block = _block;


- (instancetype) initWithName:(NSString *)name
          umlStateDescription:(nullable NSString *)umlStateDescription
                operationType: (IGenogramOperation) operationType
                     andBlock:(SMDecisionBlock)block {
    self = [super initWithName:name
           umlStateDescription:umlStateDescription
                 operationType:operationType
               stateCursorType:SMStateCursorTypeNone
              stateCursorScope:SMStateCursorScopeNone
                assistantClear:NO];
    if (self) {
        _block = block;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
         umlStateDescription:(nullable NSString *)umlStateDescription
               operationType: (IGenogramOperation) operationType
                andBoolBlock:(SMBoolDecisionBlock)block {
    self = [super initWithName:name
           umlStateDescription:umlStateDescription
                 operationType:operationType
               stateCursorType:SMStateCursorTypeNone
              stateCursorScope:SMStateCursorScopeNone
                assistantClear:NO];
    if (self) {
        _block = ^(NSDictionary *piggyback){
            BOOL res = block(piggyback);
            return res ? SM_EVENT_TRUE : SM_EVENT_FALSE;
        };
    }
    return self;
}


- (void)_entryWithContext:(SMStateMachineExecuteContext *)context withPiggyback: (NSDictionary *) piggyback {
    if (_block == nil){
        [NSException raise:SMEXCEPTION format:@"Block must be set"];
        return;
    }
    NSString *eventToPost = self.block(piggyback);
    SMTransition *curTr = [self _getTransitionForEvent:eventToPost];
    if (curTr == nil){
        [NSException raise:SMEXCEPTION format:@"Invalid event for this decision"];
        return;
    }
    if ([context.monitor respondsToSelector:@selector(receiveEvent:forState:foundTransition:piggyback:)]) {
        [context.monitor receiveEvent:eventToPost forState:self foundTransition:curTr piggyback:piggyback];
    }
    if ([context.monitor respondsToSelector:@selector(receiveEvent:forState:foundTransition:)]) {
        [context.monitor receiveEvent:eventToPost forState:self foundTransition:curTr];
    }
    
    if ([context.monitor respondsToSelector:@selector(stateMachine:receiveEvent:forState:foundTransition:piggyback:)]) {
        [context.monitor stateMachine: context.stateMachine receiveEvent:eventToPost forState:self foundTransition:curTr piggyback:piggyback];
    }
    if ([context.monitor respondsToSelector:@selector(stateMachine:receiveEvent:forState:foundTransition:)]) {
        [context.monitor stateMachine: context.stateMachine receiveEvent:eventToPost forState:self foundTransition:curTr];
    }
    
    context.curState = curTr.to;

    [[curTr action] executeWithPiggyback:piggyback];
    [context.curState _entryWithContext:context withPiggyback:piggyback];
    if ([context.monitor respondsToSelector:@selector(didExecuteTransitionFrom:to:withEvent:piggyback:)]) {
        [context.monitor didExecuteTransitionFrom:curTr.from to:context.curState withEvent:eventToPost piggyback:piggyback];
    }
    if ([context.monitor respondsToSelector:@selector(didExecuteTransitionFrom:to:withEvent:)]) {
        [context.monitor didExecuteTransitionFrom:curTr.from to:context.curState withEvent:eventToPost];
    }
    
    if ([context.monitor respondsToSelector:@selector(stateMachine:didExecuteTransitionFrom:to:withEvent:piggyback:)]) {
        [context.monitor stateMachine: context.stateMachine didExecuteTransitionFrom:curTr.from to:context.curState withEvent:eventToPost piggyback:piggyback];
    }
    if ([context.monitor respondsToSelector:@selector(stateMachine:didExecuteTransitionFrom:to:withEvent:)]) {
        [context.monitor stateMachine: context.stateMachine didExecuteTransitionFrom:curTr.from to:context.curState withEvent:eventToPost];
    }
}

- (void)_exitWithContext:(SMStateMachineExecuteContext *)context withPiggyback: (NSDictionary *) piggyback {
    [super _exitWithContext:context withPiggyback:piggyback];
}

- (void)_postEvent:(NSString *)event withContext:(SMStateMachineExecuteContext *)context withPiggyback: (NSDictionary *) piggyback {
    [NSException raise:SMEXCEPTION format:@"Post event not supported in desicions"];
}


@end
