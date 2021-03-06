//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates
//


#import "SMState.h"
#import "SMTransition.h"


@implementation SMState

@synthesize entry = _entry;
@synthesize exit = _exit;

- (instancetype)initAssistantStateWithName:(nonnull NSString *)name
                       umlStateDescription:(nullable NSString *)umlStateDescription
                             operationType:(IGenogramOperation)operationType
                                osxMessage:(nullable NSString *)osxMessage
                                iosMessage:(nullable NSString *)iosMessage
                             osxHelpAnchor:(nullable NSString *)osxHelpAnchor
                             iosHelpAnchor:(nullable NSString *)iosHelpAnchor
                          osxAssistantType:(SMStateAssistantOptions)osxAssistantType
                          iosAssistantType:(SMStateAssistantOptions)iosAssistantType {
    self = [super initWithName:name
           umlStateDescription:umlStateDescription
                 operationType:operationType
               stateCursorType:SMStateCursorTypeNone
              stateCursorScope:SMStateCursorScopeNone
                assistantClear:NO];
    if (!self) {
        return nil;
    }
    self.messageType = SMMessageTypeAssistant;
    self.osxMessage = osxMessage;
    self.iosMessage = iosMessage;
    self.osxHelpAnchor = osxHelpAnchor;
    self.iosHelpAnchor = iosHelpAnchor;
    self.osxAssistantOptions = osxAssistantType;
    self.iosAssistantOptions = iosAssistantType;

    return self;
}

- (instancetype)initMessageBoxStateWithName:(nonnull NSString *)name
                        umlStateDescription:(nullable NSString *)umlStateDescription
                              operationType:(IGenogramOperation)operationType
                                 osxMessage:(nullable NSString *)osxMessage
                                 iosMessage:(nullable NSString *)iosMessage
                              osxHelpAnchor:(nullable NSString *)osxHelpAnchor
                              iosHelpAnchor:(nullable NSString *)iosHelpAnchor
                                    okTitle:(nullable NSString *)okTitle
                                cancelTitle:(nullable NSString *)cancelTitle
                                 suppressId:(nullable NSString *)suppressId {
    self = [super initWithName:name
           umlStateDescription:umlStateDescription
                 operationType:operationType
               stateCursorType:SMStateCursorTypeNone
              stateCursorScope:SMStateCursorScopeNone
                assistantClear:NO];
    if (!self) {
        return nil;
    }

    self.osxMessage = osxMessage;
    self.iosMessage = iosMessage;
    self.osxHelpAnchor = osxHelpAnchor;
    self.iosHelpAnchor = iosHelpAnchor;
    self.okTitle = okTitle;
    self.cancelTitle = cancelTitle;
    self.suppressId = suppressId;
    return self;
}


- (void) setEntryBlock:(SMActionBlock)entryBlock {
    self.entry = [SMAction actionWithBlock:entryBlock];
}

- (void) setExitBlock:(SMActionBlock)exitBlock {
    self.exit = [SMAction actionWithBlock:exitBlock];
}

- (void)_postEvent:(NSString *)event withContext:(SMStateMachineExecuteContext *)context withPiggyback:(NSDictionary *)piggyback {
    
    SMTransition *curTr = [self _getTransitionForEvent:event];
    
    if ([context.monitor respondsToSelector:@selector(receiveEvent:forState:foundTransition:piggyback:)]) {
        [context.monitor receiveEvent:event forState:self foundTransition:curTr piggyback:piggyback];
    }
    if ([context.monitor respondsToSelector:@selector(receiveEvent:forState:foundTransition:)]) {
        [context.monitor receiveEvent:event forState:self foundTransition:curTr];
    }
    
    if ([context.monitor respondsToSelector:@selector(stateMachine:receiveEvent:forState:foundTransition:piggyback:)]) {
        [context.monitor stateMachine:context.stateMachine receiveEvent:event forState:self foundTransition:curTr piggyback:piggyback];
    }
    if ([context.monitor respondsToSelector:@selector(stateMachine:receiveEvent:forState:foundTransition:)]) {
        [context.monitor stateMachine:context.stateMachine receiveEvent:event forState:self foundTransition:curTr];
    }
    
    if (curTr != nil) {
        const BOOL shouldChangeStates = (nil != curTr.to);
        
        // Exit the old state.
        if (shouldChangeStates) {
            [self _exitWithContext:context withPiggyback:piggyback];
            context.curState = curTr.to;
        }
        
        // Execute the transition action.
        [[curTr action] executeWithPiggyback:piggyback];
        
        // Enter the new state.
        if (shouldChangeStates) {
            [context.curState _entryWithContext:context withPiggyback:piggyback];
        }
        
        // Inform the monitor.
        if ([context.monitor respondsToSelector:@selector(didExecuteTransitionFrom:to:withEvent:piggyback:)]) {
            [context.monitor didExecuteTransitionFrom:curTr.from to:context.curState withEvent:event piggyback:piggyback];
        }
        if ([context.monitor respondsToSelector:@selector(didExecuteTransitionFrom:to:withEvent:)]) {
            [context.monitor didExecuteTransitionFrom:curTr.from to:context.curState withEvent:event];
        }
        
        if ([context.monitor respondsToSelector:@selector(stateMachine:didExecuteTransitionFrom:to:withEvent:piggyback:)]) {
            [context.monitor stateMachine: context.stateMachine didExecuteTransitionFrom:curTr.from to:context.curState withEvent:event piggyback:piggyback];
        }
        if ([context.monitor respondsToSelector:@selector(stateMachine:didExecuteTransitionFrom:to:withEvent:)]) {
            [context.monitor stateMachine: context.stateMachine didExecuteTransitionFrom:curTr.from to:context.curState withEvent:event];
        }
    }

}

- (void)_entryWithContext:(SMStateMachineExecuteContext *)context withPiggyback:(NSDictionary *)piggyback {
    [self.entry executeWithPiggyback:piggyback];
}

- (void)_exitWithContext:(SMStateMachineExecuteContext *)context withPiggyback:(NSDictionary *)piggyback {
    [self.exit executeWithPiggyback:piggyback];
}


@end
