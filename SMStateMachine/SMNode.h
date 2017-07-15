//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "SMStateMachineExecuteContext.h"



@interface SMNode : NSObject
@property(nonatomic, readonly, strong, nonnull) NSString *name;
@property(nonatomic, weak, nullable) SMNode *parent;

@property(nonatomic, strong, nullable) NSString *umlStateDescription;

@property (nonatomic, nullable, strong) NSMutableDictionary *localProperties;

- (nullable instancetype) initWithName:(nonnull NSString *)name umlStateDescription : (nullable NSString *) umlDescription;

- (void)_postEvent:(nonnull NSString *)event withContext:(nullable SMStateMachineExecuteContext *)context withPiggyback: (nullable NSDictionary *) piggyback;
- (void)_entryWithContext:(nullable SMStateMachineExecuteContext *)context withPiggyback: (nullable NSDictionary *) piggyback;
- (void)_exitWithContext:(nullable SMStateMachineExecuteContext *)context withPiggyback: (nullable NSDictionary *) piggyback;

- (void)_addTransition:(nonnull SMTransition *)transition;
- (nullable SMTransition *)_getTransitionForEvent:(nonnull NSString *)event;

- (nullable NSString *) transitionsPlantuml;

@end
