//
// Created by est1908 on 11/20/12.
//
// To change the template use AppCode | Preferences | File Templates
//


#import "SMNode.h"
#import "SMTransition.h"
#import "SMStateMachine.h"

@interface SMNode()
@property(strong, nonatomic) NSMutableArray *transitions;
@end

@implementation SMNode
@synthesize name = _name;
@synthesize transitions = _transitions;
@synthesize parent = _parent;

- (instancetype) initWithName:(NSString *)name
          umlStateDescription:(NSString *)umlStateDescription
                operationType:(IGenogramOperation)operationType
              stateCursorType:(SMStateCursorType)stateCursorType
             stateCursorScope:(SMStateCursorScope)stateCursorScope
               assistantClear:(BOOL)assistantClear{

    self = [super init];
    if (self) {
        _name = name;
        _localProperties = [NSMutableDictionary new];
        _umlStateDescription = umlStateDescription;
        _operationType = operationType;
        _stateCursorType = stateCursorType;
        _stateCursorScope = stateCursorScope;
        _messageType = assistantClear ? SMMessageTypeAssistant : SMMessageTypeNone;
        _osxAssistantOptions = assistantClear ? SMStateAssistantOptionsRemoveAssistant : SMStateAssistantOptionsNoButtons;
    }
    return self;
}

- (void)_entryWithContext:(SMStateMachineExecuteContext *)context withPiggyback: (NSDictionary *) piggyback {

}

- (void)_exitWithContext:(SMStateMachineExecuteContext *)context withPiggyback: (NSDictionary *) piggyback {

}

- (void) _postEvent:(NSString *)event withContext:(SMStateMachineExecuteContext *)context withPiggyback:(NSDictionary *)piggyback {
    
}

- (void)_addTransition:(SMTransition *)transition {
    [self.transitions addObject:transition];
}

- (SMTransition *)_getTransitionForEvent:(NSString *)event {
    for (SMTransition *curTr in self.transitions) {
        if ([curTr.event isEqualToString:event]) {
            return curTr;
        }
    }
    for (SMTransition *curTr in self.transitions) {
        if ([curTr.event isEqualToString:SMDEFAULT]) {
            return curTr;
        }
    }
    if (self.parent) {
        return [self.parent _getTransitionForEvent:event];
    }
    return nil;
}


- (NSMutableArray *)transitions {
    if (_transitions == nil) {
        _transitions = [[NSMutableArray alloc] init];
    }
    return _transitions;
}

#pragma mark - Operations Classification and Description

- (NSString *) osxTitle {
    switch (self.operationType) {
        case IGenogramOperationUndefined:
            return @"UNASSIGNED OPERATION!";
            break;
        case IGenogramOperationIdle:
            return @"IDLE!";
            break;
        case IGenogramOperationAddHousehold:
            return NSLocalizedString(@"Adding group/household", nil);
            break;
        case IGenogramOperationEditHouseholdComponents:
            return NSLocalizedString(@"Modifyng group/household members", nil);
            break;
        case IGenogramOperationAddIndividual:
            return NSLocalizedString(@"Adding a new individual", nil);
            break;
        case IGenogramOperationMoveIndividual:
            return NSLocalizedString(@"Moving an individual", nil);
            break;
        case IGenogramOperationAddRelationship:
            return NSLocalizedString(@"Adding an emotional relationship", nil);
            break;
        case IGenogramOperationAddCouple:
            return NSLocalizedString(@"Adding a couple relationship", nil);
            break;
        case IGenogramOperationMoveCouple:
            return NSLocalizedString(@"Moving a couple relationship", nil);
            break;
        case IGenogramOperationAddBirthAdoption:
            return NSLocalizedString(@"Adding a parents/child relationship", nil);
            break;
        case IGenogramOperationAddTwin:
            return NSLocalizedString(@"Adding a twin to a parents/child relationship", nil);
            break;
        case IGenogramOperationAddingObject:
            return @"ADDING_OBJECT!";
            break;
        case IGenogramOperationEditingObject:
            return @"EDITING_OBJECT!";
            break;
        case IGenogramOperationAddingTwin:
            return @"ADDING_TWIN!";
            break;
        default:
            return @"UNKNOWN!";
    }
}

- (NSString *) iosTitle {
    return self.osxTitle;
}

- (NSString *)operationTypeCode {
    switch (self.operationType) {
        case IGenogramOperationUndefined:
            return @"UNA";
            break;
        case IGenogramOperationIdle:
            return @"IDL";
            break;
        case IGenogramOperationAddHousehold:
            return @"HHL_ADD";
            break;
        case IGenogramOperationEditHouseholdComponents:
            return @"HHL_EDT_COM";
            break;
        case IGenogramOperationAddIndividual:
            return @"IND_ADD";
            break;
        case IGenogramOperationMoveIndividual:
            return @"IND_MOV";
            break;
        case IGenogramOperationAddRelationship:
            return @"REL_ADD";
            break;
        case IGenogramOperationAddCouple:
            return @"CPL_ADD";
            break;
        case IGenogramOperationMoveCouple:
            return @"CPL_MOV";
            break;
        case IGenogramOperationAddBirthAdoption:
            return @"BAD_ADD";
            break;
        case IGenogramOperationAddTwin:
            return @"BAD_ADD_TWN";
            break;
        case IGenogramOperationAddingObject:
            return @"MVI_ADD_OBJ";
            break;
        case IGenogramOperationEditingObject:
            return @"MVI_EDT_OBJ";
            break;
        case IGenogramOperationAddingTwin:
            return @"MVI_ADD_TWN";
            break;
        default:
            return @"UNK";
    }
}

#pragma mark - PlantUml service functions

- (NSString *) transitionsPlantuml {
    NSString *result = @"";
    NSString *arrowType = nil;
    NSString *arrowColor = nil;

    for (SMTransition *transition in self.transitions) {
        if ([transition.event isEqualToString:@"SM_TRUE"]) {
            arrowType = @"-[#green,bold]->";
            arrowColor = @"<color:Green>";
        } else if ([transition.event isEqualToString:@"SM_FALSE"]) {
            arrowType = @"-[#red,bold]->";
            arrowColor = @"<color:Red>";
        } else if ([transition.event isEqualToString:@"dragTouchStart"]) {
            arrowType = @"-[#Blue,bold]->";
            arrowColor = @"<color:Blue>";
        } else if ([transition.event isEqualToString:@"dragTouchContinue"]) {
            arrowType = @"-[#Magenta,bold]->";
            arrowColor = @"<color:Magenta>";
        } else if ([transition.event isEqualToString:@"dragTouchEnd"]) {
            arrowType = @"-[#Violet,bold]->";
            arrowColor = @"<color:Violet>";
        } else if ([transition.event isEqualToString:@"touch"]) {
            arrowType = @"-[#DarkSeaGreen,bold]->";
            arrowColor = @"<color:DarkSeaGreen>";
        } else if ([transition.event isEqualToString:@"cmdTouch"]) {
            arrowType = @"-[#BlueViolet,bold]->";
            arrowColor = @"<color:BlueViolet >";
        } else if ([transition.event isEqualToString:@"userChooseOk"]) {
            arrowType = @"-[#green,bold]->";
            arrowColor = @"<color:green >";
        } else if ([transition.event isEqualToString:@"userChooseCancel"]) {
            arrowType = @"-[#red,bold]->";
            arrowColor = @"<color:red >";
        } else if ([transition.event isEqualToString:@"userChooseVideo"]) {
            arrowType = @"-[#BlueViolet,bold]->";
            arrowColor = @"<color:BlueViolet >";
        } else if ([transition.event isEqualToString:@"userCloseVideo"]) {
            arrowType = @"-[#green,bold]->";
            arrowColor = @"<color:green >";
        } else if ([transition.event isEqualToString:@"_default_"]) {
            arrowType = @"-[#black,bold]->";
            arrowColor = @"<color:black >";
        } else if ([transition.event isEqualToString:@"doubleTouch"]) {
            arrowType = @"-[#Darkorange,bold]->";
            arrowColor = @"<color:Darkorange>";
        } else {
            arrowType = @"-->";
            arrowColor = @"<color:Black>";
        }
        result = [result stringByAppendingFormat:@"%@ %@ %@ : %@%@\n", transition.from.name, arrowType, transition.to.name ?: transition.from.name, arrowColor, transition.event];
    }
    return result;
}

- (NSString *)stateColor {
    switch (self.operationType) {
        case IGenogramOperationUndefined:
            return @"Fuchsia";
            break;
        case IGenogramOperationIdle:
            return @"GreenYellow";
            break;
        case IGenogramOperationAddHousehold:
            return @"Azure";
            break;
        case IGenogramOperationEditHouseholdComponents:
            return @"Gold";
            break;
        case IGenogramOperationAddIndividual:
            return @"Azure";
            break;
        case IGenogramOperationMoveIndividual:
            return @"Yellow";
            break;
        case IGenogramOperationAddRelationship:
            return @"Salmon";
            break;
        case IGenogramOperationAddCouple:
            return @"Azure";
            break;
        case IGenogramOperationMoveCouple:
            return @"Yellow";
            break;
        case IGenogramOperationAddBirthAdoption:
            return @"Azure";
            break;
        case IGenogramOperationAddTwin:
            return @"Orange";
            break;
        case IGenogramOperationAddingObject:
            return @"Azure";
            break;
        case IGenogramOperationEditingObject:
            return @"Gold";
            break;
        case IGenogramOperationAddingTwin:
            return @"Orange";
            break;
        default:
            return @"DeepPink";
    }
}

- (NSString *) messageTypeDescription {
    switch (self.messageType) {
        case SMMessageTypeInformation:
            return @"MessageBox Information";
            break;
        case SMMessageTypeCritical:
            return @"MessageBox Critical";
            break;
        case SMMessageTypeWarning:
            return @"MessageBox Warning";
            break;
        case SMMessageTypeAssistant:
            return @"Assistant";
            break;
        default:
            return @"No Message";
            break;
    }
}

@end
