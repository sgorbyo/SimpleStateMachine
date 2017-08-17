//
//  SMStateWithUserMessage.m
//  iGenogram
//
//  Created by Danilo Marinucci on 13/07/17.
//  Copyright © 2017 iLogoTec. All rights reserved
//

#import "SMStateWithUserMessage.h"

@implementation SMStateWithUserMessage

@dynamic messageTypeDescription;

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
                           cancelTitle: (nullable NSString *) cancelTitle {
    
    self = [super initWithName:name umlStateDescription:umlStateDescription];
    
    if (!self) return nil;
    
    _messageType = messageType;
    _title = title;
    _messageOsx = messageOsx;
    _messageIos = messageIos;
    _helpTitle = helpTitle;
    _helpResource = helpResource;
    _suppressId = suppressId;
    _okTitle = okTitle;
    _cancelTitle = cancelTitle;
    
    return self;
}

- (NSString *) messageTypeDescription {
    switch (self.messageType) {
        case ILTM_NONE:
            return @"None";
            break;
        case ILTM_WARNING:
            return @"Warning";
            break;
        case ILTM_INFORMATION:
            return @"Information";
            break;
        case ILTM_CRITICAL:
            return @"Critical";
            break;
        default:
            return @"";
            break;
    }
}

@end
