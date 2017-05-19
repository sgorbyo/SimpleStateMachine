//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "SMStateMachineExecuteContext.h"


@interface SMNode : NSObject
@property(nonatomic, readonly, strong) NSString *name;
@property(nonatomic, weak) SMNode *parent;

@property (nonatomic, nullable, strong) NSMutableDictionary *localProperties;

- (id)initWithName:(NSString *)name;

- (void)_postEvent:(NSString *)event withContext:(SMStateMachineExecuteContext *)context withPiggyback: (NSDictionary *) piggyback;
- (void)_entryWithContext:(SMStateMachineExecuteContext *)context withPiggyback: (NSDictionary *) piggyback;
- (void)_exitWithContext:(SMStateMachineExecuteContext *)context withPiggyback: (NSDictionary *) piggyback;

- (void)_addTransition:(SMTransition *)transition;
- (SMTransition *)_getTransitionForEvent:(NSString *)event;

- (NSString *) transitionsPlantuml;

@end
