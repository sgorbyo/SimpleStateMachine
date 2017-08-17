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
#import "SMStateWithUserMessage.h"
#import "SMAction.h"
#import "SMTransition.h"
#import "SMDecision.h"

#define SMDEFAULT @"_default_"


@interface SMStateMachine : NSObject

/**
 The process events serialQueue. If `NULL` (default), the main serialQueue is used.
 */
@property (nonatomic, strong, nullable) dispatch_queue_t serialQueue;

- (nullable SMState *) createState:(nonnull NSString *)name umlStateDescription: (nullable NSString *) umlStateDescription;

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
                                                    cancelTitle: (nullable NSString *) cancelTitle;

- (nullable SMDecision *)createDecision:(nonnull NSString *)name umlStateDescription: (nullable NSString *) umlStateDescription withPredicateBoolBlock:(nullable SMBoolDecisionBlock)block;
- (nullable SMDecision *)createDecision:(nonnull NSString *)name umlStateDescription: (nullable NSString *) umlStateDescription withPredicateBlock:(nullable SMDecisionBlock)block;

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





