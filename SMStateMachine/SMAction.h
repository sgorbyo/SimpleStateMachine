//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "SMActionProtocol.h"

typedef void (^SMActionBlock)(NSDictionary *piggyback);

@interface SMAction : NSObject<SMActionProtocol>

+ (SMAction *)actionWithBlock:(SMActionBlock)actionBlock;

- (id)initWithBlock:(SMActionBlock)actionBlock;

- (void)executeWithPiggyback: (NSDictionary *) piggyback;

@property (nonatomic, copy) SMActionBlock actionBlock;

@end
