//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "SMAction.h"
#import "SMNode.h"

@class SMTransition;

@interface SMState : SMNode

- (void) setEntryBlock:(nullable SMActionBlock)entryBlock;

- (void) setExitBlock:(nullable SMActionBlock)exitBlock;

@property(nonatomic, strong, nullable) id<SMActionProtocol> entry;
@property(nonatomic, strong, nullable) id<SMActionProtocol> exit;

@end

