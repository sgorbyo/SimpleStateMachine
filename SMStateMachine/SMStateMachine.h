//
//  SMStateMachine.h
//  Simple State Machine
//
//  Created by Artem Kireev on 6/26/12.
//  Copyright (c) 2012 Artem Kireev. All rights reserved.
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/est1908/SimpleStateMachine
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution
//

#import <Foundation/Foundation.h>
#import "SMState.h"
#import "SMAction.h"
#import "SMTransition.h"
#import "SMDecision.h"

#define SMDEFAULT @"_default_"


/**
 This is a modified version of the original SMStateMachine. it contains special states adapted to the need of iGenogram so states are available to display message box and activate an Assistant.
 Furthermore the support for blocks has been added for transitions and enter/exit states and as documentation tool the production of UmlPlant State Chart is supported.
 */
@interface SMStateMachine : NSObject

/**
 The process events serialQueue. If `NULL` (default), the main serialQueue is used.
 */
@property (nonatomic, strong, nullable) dispatch_queue_t serialQueue;


/**
 An ordinary (no Messagebox or Asistant) state is created, added to the FSM and returned.

 @see IGenogramOperation
 
 @param name Used internally to identify the state. Usually, as a conventions, it has assigned the same name of the corresponding SMState* variable.
 @param umlStateDescription Describes the state in the PlantUML diagram.
 @param operationType Operation group. Each state participate of a group devoted to a particular operation (i.e. Adding Individual, Deleting Relationship, etc..) and it is useful to group states using the same color in PlantUML Diagram and to dispay a title in Assistant States using a decode function.
 @param stateCursorType <#stateCursorType description#>
 @param stateCursorScope <#stateCursorScope description#>
 @param assistantClear <#assistantClear description#>
 @return <#return value description#>
 */
- (nullable SMState *) createState:(nonnull NSString *)name
               umlStateDescription: (nullable NSString *) umlStateDescription
                     operationType:(IGenogramOperation) operationType
                   stateCursorType:(SMStateCursorType) stateCursorType
                  stateCursorScope:(SMStateCursorScope) stateCursorScope
                    assistantClear:(BOOL) assistantClear;

- (nullable SMState *)createAssistantStateWithName:(nonnull NSString *)name
                              umlStateDescription : (nullable NSString *) umlStateDescription
                                     operationType: (IGenogramOperation) operationType
                                   stateCursorType:(SMStateCursorType) stateCursorType
                                  stateCursorScope:(SMStateCursorScope) stateCursorScope
                                        osxMessage: (nullable NSString *) osxMessage
                                        iosMessage: (nullable NSString *) iosMessage
                                     osxHelpAnchor: (nullable NSString *) osxHelpAnchor
                                     iosHelpAnchor: (nullable NSString *) iosHelpAnchor
                                  osxAssistantType: (SMStateAssistantOptions) osxAssistantType
                                  iosAssistantType: (SMStateAssistantOptions) iosAssistantType;

- (nullable SMState *)createAssistantStateWithName:(nonnull NSString *)name
                              umlStateDescription : (nullable NSString *) umlStateDescription
                                     operationType: (IGenogramOperation) operationType
                                   stateCursorType:(SMStateCursorType) stateCursorType
                                  stateCursorScope:(SMStateCursorScope) stateCursorScope
                                        osxMessage: (nullable NSString *) osxMessage
                                        iosMessage: (nullable NSString *) iosMessage
                                     osxHelpAnchor: (nullable NSString *) osxHelpAnchor
                                     iosHelpAnchor: (nullable NSString *) iosHelpAnchor
                                  osxAssistantType: (SMStateAssistantOptions) osxAssistantType
                                  iosAssistantType: (SMStateAssistantOptions) iosAssistantType
                                            parent: (nullable SMState *) parent;

- (nullable SMState *)createMessageBoxStateWithName:(nonnull NSString *)name
                               umlStateDescription : (nullable NSString *) umlStateDescription
                                      operationType: (IGenogramOperation) operationType
                                        messageType: (SMMessageType) messageType
                                         osxMessage: (nullable NSString *) osxMessage
                                 osxInformativeText: (nullable NSString *) osxInformativeText
                                         iosMessage: (nullable NSString *) iosMessage
                                 iosInformativeText: (nullable NSString *) iosInformativeText
                                      osxHelpAnchor: (nullable NSString *) osxHelpAnchor
                                      iosHelpAnchor: (nullable NSString *) iosHelpAnchor
                                            okTitle: (nullable NSString *) okTitle
                                        cancelTitle: (nullable NSString *) cancelTitle
                                         suppressId: (nullable NSString *) suppressId
                                             parent: (nullable SMState *) parent;

- (nullable SMState *)createMessageBoxStateWithName:(nonnull NSString *)name
                               umlStateDescription : (nullable NSString *) umlStateDescription
                                      operationType: (IGenogramOperation) operationType
                                        messageType: (SMMessageType) messageType
                                         osxMessage: (nullable NSString *) osxMessage
                                 osxInformativeText: (nullable NSString *) osxInformativeText
                                         iosMessage: (nullable NSString *) iosMessage
                                 iosInformativeText: (nullable NSString *) iosInformativeText
                                      osxHelpAnchor: (nullable NSString *) osxHelpAnchor
                                      iosHelpAnchor: (nullable NSString *) iosHelpAnchor
                                            okTitle: (nullable NSString *) okTitle
                                        cancelTitle: (nullable NSString *) cancelTitle
                                         suppressId: (nullable NSString *) suppressId;

- (nullable SMDecision *)createDecision:(nonnull NSString *)name
                    umlStateDescription: (nullable NSString *) umlStateDescription
                          operationType: (IGenogramOperation) operationType
                 withPredicateBoolBlock:(nullable SMBoolDecisionBlock)block;

- (nullable SMDecision *)createDecision:(nonnull NSString *)name
                    umlStateDescription: (nullable NSString *) umlStateDescription
                          operationType: (IGenogramOperation) operationType
                     withPredicateBlock:(nullable SMDecisionBlock)block;

- (void)transitionFrom:(nonnull SMNode *)fromState to:(nonnull SMNode *)toState forEvent:(nonnull NSString *)event;
- (void)transitionFrom:(nonnull SMNode *)fromState to:(nonnull SMNode *)toState forEvent:(nonnull NSString *)event withBlock:(nullable SMActionBlock) actionBlock;

- (void)trueTransitionFrom:(nonnull SMDecision *)fromState to:(nonnull SMNode *)toState;
- (void)trueTransitionFrom:(nonnull SMDecision *)fromState to:(nonnull SMNode *)toState withBlock:(nullable SMActionBlock)actionBlock;
- (void)falseTransitionFrom:(nonnull SMDecision *)fromState to:(nonnull SMNode *)toState;
- (void)falseTransitionFrom:(nonnull SMDecision *)fromState to:(nonnull SMNode *)toState withBlock:(nullable SMActionBlock)actionBlock;
- (void)internalTransitionFrom:(nonnull SMNode *)fromState forEvent:(nonnull NSString *)event;
- (void)internalTransitionFrom:(nonnull SMNode *)fromState forEvent:(nonnull NSString *)event withBlock:(nullable SMActionBlock)actionBlock;

- (void) post:(nonnull NSString *)event withPiggyback: (nullable NSDictionary *) piggyback;
- (void) postAsync:(nonnull NSString *)event withPiggyback: (nullable NSDictionary *) piggyback;
- (nonnull NSString *) postAsync:(nonnull NSString *)event withPiggyback: (nullable NSDictionary *) piggyback after:(NSUInteger)milliseconds;
- (void) dropTimingEvent:(nonnull NSString *)eventUuid;

- (void)validate;

@property (nonatomic, nullable, strong) NSString *stateMachineName;

- (nullable NSString *) plantUml;
- (nullable NSMutableDictionary *) statesTreeFrom: (nullable NSString *) parent;

@property(nonatomic, weak, nullable) NSObject *globalExecuteIn;
@property(nonatomic, readonly, nullable) SMNode *curState;
@property(nonatomic, nullable) SMNode *initialState;
@property(nonatomic, weak, nullable) id <SMMonitorDelegate> monitor;

@property(nonatomic, readonly, nullable) NSArray *allStates;

@end





