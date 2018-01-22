//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates
//


#import <Foundation/Foundation.h>
#import "SMNode.h"


#define SM_EVENT_TRUE @"SM_TRUE"
#define SM_EVENT_FALSE @"SM_FALSE"

typedef BOOL (^SMBoolDecisionBlock)(NSDictionary * _Nullable piggyback);
typedef NSString * _Nullable (^SMDecisionBlock)(NSDictionary * _Nullable piggyback);

@interface SMDecision : SMNode

@property (strong, nonatomic, nullable) SMDecisionBlock block;

- (nullable instancetype) initWithName:(nonnull NSString *)name
                   umlStateDescription: (nullable NSString *) umlStateDescription
                         operationType: (IGenogramOperation) operationType
                              andBlock:(SMDecisionBlock _Nullable )block;

- (nullable instancetype) initWithName:(nonnull NSString *)name
                   umlStateDescription: (nullable NSString *) umlStateDescription
                         operationType: (IGenogramOperation) operationType
                          andBoolBlock:(SMBoolDecisionBlock _Nullable )block;

@end
