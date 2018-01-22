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
@property (nonatomic, nullable, strong) NSMutableDictionary *localProperties;

#pragma mark - Operations Classification and Description
@property(nonatomic, assign) IGenogramOperation operationType;
@property(nonatomic, nonnull, readonly) NSString *operationTypeCode;
@property(nonatomic, nonnull, readonly) NSString *osxTitle;
@property(nonatomic, nonnull, readonly) NSString *iosTitle;

@property (nonatomic, assign) SMMessageType messageType;

@property(nonatomic, nullable, strong) NSString *osxMessage;
@property(nonatomic, nullable, strong) NSString *osxInformativeText;
@property(nonatomic, assign) SMStateAssistantOptions osxAssistantOptions;
@property(nonatomic, nullable, strong) NSString *osxHelpAnchor;

@property (nonatomic, assign) SMStateCursorType stateCursorType;
@property (nonatomic, assign) SMStateCursorScope stateCursorScope;

@property(nonatomic, nullable, strong) NSString *iosMessage;
@property(nonatomic, nullable, strong) NSString *iosInformativeText;
@property(nonatomic, assign) SMStateAssistantOptions iosAssistantOptions;
@property(nonatomic, nullable, strong) NSString *iosHelpAnchor;

@property (nonatomic, nullable, strong) NSString *suppressId;
@property (nonatomic, nullable, strong) NSString *okTitle;
@property (nonatomic, nullable, strong) NSString *cancelTitle;

//idle.osxAssistantType = @(AMO_Clear);
//idle.stateClassificationScope = SMStateCursorTypeNormal;
//idle.stateClassificationType = SMStateCursorTypeConnectingWaitingStart;

- (nullable instancetype) initWithName:(nonnull NSString *)name
                  umlStateDescription :(nullable NSString *) umlStateDescription
                         operationType:(IGenogramOperation) operationType
                       stateCursorType:(SMStateCursorType) stateCursorType
                      stateCursorScope:(SMStateCursorScope) stateCursorScope
                        assistantClear:(BOOL) assistantClear;

- (void)_postEvent:(nonnull NSString *)event
       withContext:(nullable SMStateMachineExecuteContext *)context
     withPiggyback: (nullable NSDictionary *) piggyback;

- (void)_entryWithContext:(nullable SMStateMachineExecuteContext *)context
            withPiggyback: (nullable NSDictionary *) piggyback;

- (void)_exitWithContext:(nullable SMStateMachineExecuteContext *)context
           withPiggyback: (nullable NSDictionary *) piggyback;

- (void)_addTransition:(nonnull SMTransition *)transition;

- (nullable SMTransition *)_getTransitionForEvent:(nonnull NSString *)event;

#pragma mark - PlantUml service functions

@property(nonatomic, strong, nullable) NSString *umlStateDescription;
- (nullable NSString *) transitionsPlantuml;
@property(nonatomic, nonnull, readonly) NSString *stateColor;

@property (nonatomic, nonnull, readonly) NSString *messageTypeDescription;

@end
