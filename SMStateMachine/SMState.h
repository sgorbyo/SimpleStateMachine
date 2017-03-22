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

- (id)initWithName:(NSString *)name;

- (void) setEntryBlock:(SMActionBlock)entryBlock;

- (void) setExitBlock:(SMActionBlock)exitBlock;

@property(nonatomic, strong) id<SMActionProtocol> entry;
@property(nonatomic, strong) id<SMActionProtocol> exit;

@end

