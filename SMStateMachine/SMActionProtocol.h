//
// Created by est1908 on 3/30/14.
//


#import <Foundation/Foundation.h>

@protocol SMActionProtocol <NSObject>

- (void) executeWithPiggyback: (NSDictionary *) piggyback;

@end
