//
//  SMStateWithUserMessage.h
//  iGenogram
//
//  Created by Danilo Marinucci on 13/07/17.
//  Copyright © 2017 iLogoTec. All rights reserved.
//

#import "SMState.h"

typedef NS_ENUM(NSUInteger, ILTMessageType) {
    ILTM_NONE,
    ILTM_WARNING,
    ILTM_INFORMATION,
    ILTM_CRITICAL
};

typedef NS_ENUM(NSUInteger, ILTMessageReturnType) {
    ILTR_OK,
    ILTR_HELP,
    ILTR_CANCEL
};

@interface SMStateWithUserMessage : SMState

- (nullable instancetype) initWithName:(nonnull NSString *)name
                  umlStateDescription : (nullable NSString *) umlStateDescription
                           messageType: (ILTMessageType) messageType
                                 title: (nullable NSString *) title
                            messageOsx: (nullable NSString *) messageOsx
                            messageIos: (nullable NSString *) messageIos
                             helpTitle: (nullable NSString *) helpTitle
                          helpResource: (nullable NSString *) helpResource
                            suppressId: (nullable NSString *) suppressId
                               okTitle: (nullable NSString *) okTitle
                           cancelTitle: (nullable NSString *) cancelTitle;

@property (nonatomic, assign) ILTMessageType messageType;
@property (nonatomic, nullable, strong) NSString *title;
@property (nonatomic, nullable, strong) NSString *messageOsx;
@property (nonatomic, nullable, strong) NSString *messageIos;
@property (nonatomic, nullable, strong) NSString *helpTitle;
@property (nonatomic, nullable, strong) NSString *helpResource;
@property (nonatomic, nullable, strong) NSString *suppressId;
@property (nonatomic, nullable, strong) NSString *okTitle;
@property (nonatomic, nullable, strong) NSString *cancelTitle;
@property (nonatomic, nonnull, readonly) NSString *messageTypeDescription;

@end
