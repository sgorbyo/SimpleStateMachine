//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates
//


#import <Foundation/Foundation.h>
#import "SMStateMachineExecuteContext.h"
#import "iltStateClassification.h"

@interface SMNode : NSObject
@property(nonatomic, readonly, strong, nonnull) NSString *name;
@property(nonatomic, weak, nullable) SMNode *parent;

@property(nonatomic, strong, nullable) NSString *umlStateDescription;

@property (nonatomic, nullable, strong) NSMutableDictionary *localProperties;

@property (nonatomic, assign) iltStateClassificationType stateClassificationType;
@property (nonatomic, assign) iltStateClassificationScope stateClassificationScope;

- (nullable instancetype) initWithName:(nonnull NSString *)name umlStateDescription : (nullable NSString *) umlDescription;

- (void)_postEvent:(nonnull NSString *)event withContext:(nullable SMStateMachineExecuteContext *)context withPiggyback: (nullable NSDictionary *) piggyback;
- (void)_entryWithContext:(nullable SMStateMachineExecuteContext *)context withPiggyback: (nullable NSDictionary *) piggyback;
- (void)_exitWithContext:(nullable SMStateMachineExecuteContext *)context withPiggyback: (nullable NSDictionary *) piggyback;

- (void)_addTransition:(nonnull SMTransition *)transition;
- (nullable SMTransition *)_getTransitionForEvent:(nonnull NSString *)event;

- (nullable NSString *) transitionsPlantuml;

@property(nonatomic, nullable) NSString *assistantOsxMessage;
@property(nonatomic, nullable) NSString *assistantOsxSubMessage;
@property(nonatomic, nullable) NSNumber *assistantOsxMessageType;
@property(nonatomic, nullable) NSString *assistantOsxHelpAnchor;
@property(nonatomic, nullable) NSString *assistantIosMessage;
@property(nonatomic, nullable) NSString *assistantIosSubMessage;
@property(nonatomic, nullable) NSNumber *assistantIosMessageType;
@property(nonatomic, nullable) NSString *assistantIosHelpAnchor;

@end
