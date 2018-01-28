//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates
//


#import <Foundation/Foundation.h>
#import "IgTypes.h"

@class SMTransition;
@class SMNode;
@class SMStateMachine;

#define SMEXCEPTION @"SMEXCEPTION"

typedef void (^SMIndividualOntheFlyBlock)(NSValue * _Nonnull point,
                                          NT_TYPE chosenType,
                                          NSString * _Nullable chosenName);

typedef void (^SMCoupleOntheFlyBlock)(NSValue * _Nonnull point,
                                      GU_TYPE cancelAddCoupleBlock,
                                      NT_TYPE chosenInvidivualType,
                                      NT_TYPE chosenInvidivual2Type,
                                      NSString * _Nullable chosenIndividual1Name,
                                      NSString * _Nullable chosenIndividual2Name);

NS_ASSUME_NONNULL_BEGIN
@protocol SMMonitorDelegate <NSObject>
@optional
- (void) receiveEvent:(NSString *)event forState:(SMNode *)curState foundTransition:(SMTransition*)transition;
- (void) receiveEvent:(NSString *)event forState:(SMNode *)curState foundTransition:(SMTransition*)transition piggyback: (nullable NSDictionary *) piggyback;
- (void) didExecuteTransitionFrom:(SMNode *)from to:(SMNode *)to withEvent:(NSString *)event;
- (void) didExecuteTransitionFrom:(SMNode *)from to:(SMNode *)to withEvent:(NSString *)event piggyback: (nullable NSDictionary *) piggyback;

- (void) stateMachine: (SMStateMachine *) stateMachine receiveEvent:(NSString *)event forState:(SMNode *)curState foundTransition:(SMTransition*)transition;
- (void) stateMachine: (SMStateMachine *) stateMachine receiveEvent:(NSString *)event forState:(SMNode *)curState foundTransition:(SMTransition*)transition piggyback: (nullable NSDictionary *) piggyback;
- (void) stateMachine: (SMStateMachine *) stateMachine didExecuteTransitionFrom:(SMNode *)from to:(SMNode *)to withEvent:(NSString *)event;
- (void) stateMachine: (SMStateMachine *) stateMachine didExecuteTransitionFrom:(SMNode *)from to:(SMNode *)to withEvent:(NSString *)eventt piggyback: (nullable NSDictionary *) piggyback;
@end
NS_ASSUME_NONNULL_END
