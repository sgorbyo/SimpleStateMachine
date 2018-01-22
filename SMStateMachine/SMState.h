//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates
//


#import <Foundation/Foundation.h>
#import "SMAction.h"
#import "SMNode.h"

@class SMTransition;

@interface SMState : SMNode

- (nullable instancetype) initAssistantStateWithName:(nonnull NSString *)name
                                umlStateDescription : (nullable NSString *) umlStateDescription
                                       operationType: (IGenogramOperation) operationType
                                          osxMessage: (nullable NSString *) osxMessage
                                          iosMessage: (nullable NSString *) iosMessage
                                       osxHelpAnchor: (nullable NSString *) osxHelpAnchor
                                       iosHelpAnchor: (nullable NSString *) iosHelpAnchor
                                    osxAssistantType: (SMStateAssistantOptions) osxAssistantType
                                    iosAssistantType: (SMStateAssistantOptions) iosAssistantType;

- (nullable instancetype) initMessageBoxStateWithName:(nonnull NSString *)name
                                 umlStateDescription : (nullable NSString *) umlStateDescription
                                        operationType: (IGenogramOperation) operationType
                                           osxMessage: (nullable NSString *) osxMessage
                                           iosMessage: (nullable NSString *) iosMessage
                                        osxHelpAnchor: (nullable NSString *) osxHelpAnchor
                                        iosHelpAnchor: (nullable NSString *) iosHelpAnchor
                                              okTitle: (nullable NSString *) okTitle
                                          cancelTitle: (nullable NSString *) cancelTitle
                                           suppressId: (nullable NSString *) suppressId;

- (void) setEntryBlock:(nullable SMActionBlock)entryBlock;

- (void) setExitBlock:(nullable SMActionBlock)exitBlock;

@property(nonatomic, strong, nullable) id<SMActionProtocol> entry;
@property(nonatomic, strong, nullable) id<SMActionProtocol> exit;

@end

