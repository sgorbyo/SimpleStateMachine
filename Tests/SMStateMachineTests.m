//
//  SMStateMachineTests.m
//  SimpleStateMachineTests
//
//  Created by Artem Kireev on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SMStateMachineTests.h"
#import "SMStateMachine.h"

@implementation SMStateMachineTests {
    __block NSInteger _counter;
    __block NSMutableString * _string;
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testEmpty
{
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    XCTAssertNotNil(sm, @"sm is nil");
}

- (void)testSimpleState
{
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *state1 = [sm createState:@"state1"];
    XCTAssertEqualObjects(state1.name, @"state1", @"Invalid state name");
}

- (void)testInitial
{
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"Initial"];
    SMState *state1 = [sm createState:@"state1"];
    sm.initialState = initial;
    [sm transitionFrom:initial to:state1 forEvent:@"event1"];
}

- (void)testSimpleSM
{
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"initial"];
    sm.initialState =  initial;
    SMState *state1 = [sm createState:@"state1"];
    [sm transitionFrom:initial to:state1 forEvent:@"event1"];
    [sm post:@"event1" withPiggyback:nil];
    XCTAssertEqualObjects(sm.curState.name, @"state1", @"Invalid current state");
}

- (void)testValidateNoStates
{
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    XCTAssertThrows([sm validate], @"Check for no initial state");
}

- (void)testValidateNoInitialState
{
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *state1 = [sm createState:@"state1"];
    XCTAssertNotNil(state1, @"state1 is nil");
    XCTAssertThrows([sm validate], @"Check for no initial state");
}

-(void)simpleMethod {
    _counter++;
}

- (void)testEntryExecute
{
    _counter = 0;
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"initial"];
    sm.initialState = initial;
    SMState *state1 = [sm createState:@"state1"];
    [state1 setEntryBlock:^(NSDictionary *piggyback) {
        [self simpleMethod];
    }];
    [sm transitionFrom:initial to:state1 forEvent:@"event1"];
    [sm post:@"event1" withPiggyback:nil];
    XCTAssertEqual(_counter, 1, @"Entry action not executed");
}

- (void)testExitExecute
{
    _counter = 0;
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"initial"];
    sm.initialState = initial;
    SMState *state1 = [sm createState:@"state1"];
    SMState *state2 = [sm createState:@"state2"];
    [state1 setExitBlock:^(NSDictionary *piggyback) {
        [self simpleMethod];
    }];
    [sm transitionFrom:initial to:state1 forEvent:@"event1"];
    [sm transitionFrom:state1 to:state2 forEvent:@"event2"];
    [sm post:@"event1" withPiggyback:nil];
    [sm post:@"event2" withPiggyback:nil];
    XCTAssertEqual(_counter, 1, @"Exit action not executed");
}

- (void)testExecuteActionOnTransition
{
    _counter = 0;
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"initial"];
    sm.initialState = initial;
    SMState *state1 = [sm createState:@"state1"];
    [sm transitionFrom:initial to:state1 forEvent:@"event1" withBlock:^(NSDictionary *piggyback) {
        [self simpleMethod];
    }];
    
    [sm post:@"event1" withPiggyback:nil];
    XCTAssertEqual(_counter, 1, @"Transition action not executed");
}


-(void)State1Entry{
    [_string appendString:@"State1Entry;"];
}
-(void)State1Exit{
    [_string appendString:@"State1Exit;"];
}
-(void)TransAction{
    [_string appendString:@"TransAction;"];
}


-(void)State2Entry{
    [_string appendString:@"State2Entry;"];
}

- (void)testExecuteSequence
{
    _string = [[NSMutableString alloc] init];
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"initial"];
    sm.initialState = initial;
    SMState *state1 = [sm createState:@"state1"];
    SMState *state2 = [sm createState:@"state2"];
    [state1 setExitBlock:^(NSDictionary *piggyback) {
        [self State1Exit];
    }];
    [state2 setEntryBlock:^(NSDictionary *piggyback) {
        [self State2Entry];
    }];
    [sm transitionFrom:initial to:state1 forEvent:@"event1"];
    [sm transitionFrom:state1 to:state2 forEvent:@"event2" withBlock:^(NSDictionary *piggyback) {
        [self TransAction];
    }];
    [sm post:@"event1" withPiggyback:nil];
    [sm post:@"event2" withPiggyback:nil];
    XCTAssertEqualObjects(_string, @"State1Exit;TransAction;State2Entry;", @"Invalid calling sequence");
}

- (void)receiveEvent:(NSString *)event forState:(SMNode *)curState foundTransition:(SMTransition *)transition {
    _counter++;
}

-(void)testMonitorReceiveEventFoundTransition {
    _counter = 0;
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    sm.monitor = self;
    SMState *initial = [sm createState:@"initial"];
    sm.initialState =  initial;
    SMState *state1 = [sm createState:@"state1"];
    [sm transitionFrom:initial to:state1 forEvent:@"event1"];
    [sm post:@"event1" withPiggyback:nil];
    XCTAssertEqual(_counter, 2, @"Monitor willExecuteTransitionFrom not executed");
}

-(void)testMonitorReceiveEventFoundTransition_NoTransitionsFound {
    _counter = 0;
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    sm.monitor = self;
    SMState *initial = [sm createState:@"initial"];
    sm.initialState =  initial;
    SMState *state1 = [sm createState:@"state1"];
    [sm transitionFrom:initial to:state1 forEvent:@"event1"];
    [sm post:@"unknown" withPiggyback:nil];
    [sm post:@"unknown" withPiggyback:nil];
    [sm post:@"unknown" withPiggyback:nil];
    XCTAssertEqual(_counter, 3, @"Monitor receiveEvent not executed");
}


- (void)didExecuteTransitionFrom:(SMNode *)from to:(SMNode *)to withEvent:(NSString *)event {
    _counter++;
    XCTAssertEqualObjects(from.name, @"initial", @"Invalid from state");
    XCTAssertEqualObjects(to.name, @"state1", @"Invalid to state");
    XCTAssertEqualObjects(event, @"event1", @"Invalid event");
}

-(void)testMonitorDidExecuteTransitionFrom {
    _counter = 0;
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    sm.monitor = self;
    SMState *initial = [sm createState:@"initial"];
    sm.initialState =  initial;
    SMState *state1 = [sm createState:@"state1"];
    [sm transitionFrom:initial to:state1 forEvent:@"event1"];
    [sm post:@"event1" withPiggyback:nil];
    XCTAssertEqual(_counter, 2, @"Monitor willExecuteTransitionFrom not executed");
}

-(void)testDecision1{
    _string = [[NSMutableString alloc] init];
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"initial"];
    sm.initialState =  initial;
    sm.globalExecuteIn = self;
    SMDecision *decision = [sm createDecision:@"decicson" withPredicateBlock:^NSString*(NSDictionary *piggyback) {
        return @"decisionEvent1";
    }];
    SMState *state1 = [sm createState:@"state1"];
    SMState *state2 = [sm createState:@"state2"];
    [state1 setEntryBlock:^(NSDictionary *piggyback) {
        [self State1Entry];
    }];
    [state2 setEntryBlock:^(NSDictionary *piggyback) {
        [self State2Entry];
    }];
    [sm transitionFrom:initial to:decision forEvent:@"event1"];
    [sm transitionFrom:decision to:state1 forEvent:@"decisionEvent1"];
    [sm transitionFrom:decision to:state2 forEvent:@"decisionEvent2"];
    [sm post:@"event1" withPiggyback:nil];
    XCTAssertEqualObjects(_string, @"State1Entry;", @"Invalid calling sequence");
}

-(void)testDecision2{
    _string = [[NSMutableString alloc] init];
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"initial"];
    sm.initialState =  initial;
    sm.globalExecuteIn = self;

    SMDecision *decision = [sm createDecision:@"decicson" withPredicateBlock:^NSString *(NSDictionary *piggyback) {
        return @"decisionEvent2";
    }];
    
    SMState *state1 = [sm createState:@"state1"];
    SMState *state2 = [sm createState:@"state2"];
    [state1 setEntryBlock:^(NSDictionary *piggyback) {
        [self State1Entry];
    }];
    [state2 setEntryBlock:^(NSDictionary *piggyback) {
        [self State2Entry];
    }];
    [sm transitionFrom:initial to:decision forEvent:@"event1"];
    [sm transitionFrom:decision to:state1 forEvent:@"decisionEvent1"];
    [sm transitionFrom:decision to:state2 forEvent:@"decisionEvent2"];
    [sm post:@"event1"withPiggyback:nil];
    XCTAssertEqualObjects(_string, @"State2Entry;", @"Invalid calling sequence");
}

-(void)testDecision3{
    _string = [[NSMutableString alloc] init];
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"initial"];
    sm.initialState =  initial;
    sm.globalExecuteIn = self;
    
    SMDecision *decision = [sm createDecision:@"decision" withPredicateBlock:^NSString *(NSDictionary *piggyback) {
        if (piggyback) {
            return piggyback[@"switch"];
        }
        return @"Nulla";
    }];
    
    SMState *state1 = [sm createState:@"state1"];
    SMState *state2 = [sm createState:@"state2"];
    [state1 setEntryBlock:^(NSDictionary *piggyback) {
        [self State1Entry];
    }];
    [state2 setEntryBlock:^(NSDictionary *piggyback) {
        [self State2Entry];
    }];
    [sm transitionFrom:initial to:decision forEvent:@"event1"];
    [sm transitionFrom:decision to:state1 forEvent:@"decisionEvent1"];
    [sm transitionFrom:decision to:state2 forEvent:@"decisionEvent2"];
    NSDictionary *dict = @{@"switch" : @"decisionEvent2"};
    [sm post:@"event1"withPiggyback:dict];
    XCTAssertEqualObjects(_string, @"State2Entry;", @"Invalid calling sequence");
}

- (void)testDecision4{
    _string = [[NSMutableString alloc] init];
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"initial"];
    sm.initialState =  initial;
    sm.globalExecuteIn = self;
    
    SMDecision *decision = [sm createDecision:@"decision" withPredicateBlock:^NSString *(NSDictionary *piggyback) {
        if (piggyback) {
            return piggyback[@"switch"];
        }
        return @"Nulla";
    }];
    
    SMState *state1 = [sm createState:@"state1"];
    SMState *state2 = [sm createState:@"state2"];
    [state1 setEntryBlock:^(NSDictionary *piggyback) {
        [self State1Entry];
    }];
    [state2 setEntryBlock:^(NSDictionary *piggyback) {
        [self State2Entry];
    }];
    [sm transitionFrom:initial to:decision forEvent:@"event1"];
    [sm transitionFrom:decision to:state1 forEvent:@"decisionEvent1"];
    [sm transitionFrom:decision to:state2 forEvent:@"decisionEvent2"];
    NSDictionary *dict = @{@"switch" : @"decisionEvent1"};
    [sm post:@"event1"withPiggyback:dict];
    XCTAssertNotEqualObjects(_string, @"State2Entry;", @"Invalid calling sequence");
    XCTAssertEqualObjects(_string, @"State1Entry;", @"Invalid calling sequence");
}

- (void)testDecision5{
    _string = [[NSMutableString alloc] init];
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"initial"];
    sm.initialState =  initial;
    sm.globalExecuteIn = self;
    
    SMDecision *decision = [sm createDecision:@"decision" withPredicateBlock:^NSString *(NSDictionary *piggyback) {
        if (piggyback) {
            return piggyback[@"switch"];
        }
        return @"Nulla";
    }];
    
    SMState *state1 = [sm createState:@"state1"];
    SMState *state2 = [sm createState:@"state2"];
    [state1 setEntryBlock:^(NSDictionary *piggyback) {
         [_string appendString:piggyback[@"Message1"]];
    }];
    [state2 setEntryBlock:^(NSDictionary *piggyback) {
        [_string appendString:piggyback[@"Message2"]];
    }];
    [sm transitionFrom:initial to:decision forEvent:@"event1"];
    [sm transitionFrom:decision to:state1 forEvent:@"decisionEvent1"];
    [sm transitionFrom:decision to:state2 forEvent:@"decisionEvent2"];
    NSDictionary *dict = @{@"switch" : @"decisionEvent2", @"Message1" : @"State1Entry;", @"Message2" : @"State2Entry;"};
    [sm post:@"event1"withPiggyback:dict];
    XCTAssertEqualObjects(_string, @"State2Entry;", @"Invalid calling sequence");
    XCTAssertNotEqualObjects(_string, @"State1Entry;", @"Invalid calling sequence");
}

- (void)testDefault{
    _string = [[NSMutableString alloc] init];
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"initial"];
    sm.initialState =  initial;
    SMState *state1 = [sm createState:@"state1"];
    SMState *state2 = [sm createState:@"state2"];
    [state1 setEntryBlock:^(NSDictionary *piggyback) {
        [_string appendString:@"State1Entry;"];
    }];
    [state2 setEntryBlock:^(NSDictionary *piggyback) {
        [_string appendString:@"State2Entry;"];
    }];
    [sm transitionFrom:initial to:state1 forEvent:@"event1"];
    [sm transitionFrom:state1 to:state2 forEvent:SMDEFAULT];
    [sm post:@"event1" withPiggyback:nil];
    [sm post:@"eventNotRecognized" withPiggyback:nil];
    XCTAssertEqualObjects(_string, @"State1Entry;State2Entry;", @"Invalid calling sequence");
}

- (void)testSuperState{
    _string = [[NSMutableString alloc] init];
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"initial"];
    sm.initialState =  initial;
    SMState *state1 = [sm createState:@"state1"];
    SMState *state2 = [sm createState:@"state2"];
    [state1 setEntryBlock:^(NSDictionary *piggyback) {
        [_string appendString:@"State1Entry;"];
    }];
    [state1 setExitBlock:^(NSDictionary *piggyback) {
        [_string appendString:@"State1Exit;"];
    }];
    [state2 setExitBlock:^(NSDictionary *piggyback) {
        [_string appendString:@"State2Exit;"];
    }];
    [initial setEntryBlock:^(NSDictionary *piggyback) {
        [_string appendString:@"InitialEntry;"];
    }];
    [sm transitionFrom:initial to:state1 forEvent:@"event1"];
    [sm transitionFrom:state2 to:initial forEvent:@"event2"];
    state1.parent = state2;
    [sm post:@"event1" withPiggyback:nil];
    [sm post:@"event2" withPiggyback:nil];
    XCTAssertEqualObjects(_string, @"State1Entry;State1Exit;InitialEntry;", @"Invalid calling sequence");
}

- (void)testStatesTree{
    _string = [[NSMutableString alloc] init];
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"initial"];
    sm.initialState =  initial;
    SMState *state1 = [sm createState:@"state1"];
    SMState *state2 = [sm createState:@"state2"];
    SMState *state1_1 = [sm createState:@"state1.1"];
    state1_1.parent = state1;
    SMState *state1_2 = [sm createState:@"state1.2"];
    state1_2.parent = state1;
    SMState *state1_3 = [sm createState:@"state1.3"];
    state1_3.parent = state1;
    SMState *state1_3_1 = [sm createState:@"state1.3.1"];
    state1_3_1.parent = state1_3;
    SMState *state1_3_2 = [sm createState:@"state1.3.2"];
    state1_3_2.parent = state1_3;
    NSDictionary *test = [[sm statesTreeFrom:nil] copy];
    NSDictionary *base = @{@"initial" : @{},
                           @"state1" : @{@"state1.1" : @{},
                                         @"state1.2" : @{},
                                         @"state1.3" : @{@"state1.3.1" : @{},
                                                         @"state1.3.2" : @{}
                                                         }
                                         },
                           @"state2" : @{}
                           };
    state2 = nil;
    XCTAssertEqualObjects(test, base, @"Invalid states tree");
}


-(void)testBoolDecision{
    _string = [[NSMutableString alloc] init];
    SMStateMachine *  sm = [[SMStateMachine alloc] init];
    SMState *initial = [sm createState:@"initial"];
    sm.initialState =  initial;
    sm.globalExecuteIn = self;
    SMDecision *decision = [sm createDecision:@"decicson" withPredicateBoolBlock:^BOOL(NSDictionary *piggyback) {
        return NO;
    }];
    
    SMState *state1 = [sm createState:@"state1"];
    SMState *state2 = [sm createState:@"state2"];
    [state1 setEntryBlock:^(NSDictionary *piggyback) {
        [self State1Entry];
    }];
    [state2 setEntryBlock:^(NSDictionary *piggyback) {
        [self State2Entry];
    }];
    [sm transitionFrom:initial to:decision forEvent:@"event1"];
    [sm trueTransitionFrom:decision to:state1];
    [sm falseTransitionFrom:decision to:state2];
    [sm post:@"event1" withPiggyback:nil];
    XCTAssertEqualObjects(_string, @"State2Entry;", @"Invalid calling sequence");
}

-(void)beep{
    NSLog(@"Beep");
}

-(void)greenLightOn{
    NSLog(@"greenLightOn");
}

-(void)redLightOn{
    NSLog(@"redLightOn");
}

//turnstile
-(void)testFowWiKi{
    //Create
    SMStateMachine *sm = [[SMStateMachine alloc] init];
    sm.globalExecuteIn = self; //execute all selectors on self object
    SMState *opened = [sm createState:@"open"];
    SMState *closed = [sm createState:@"closed"];
    sm.initialState = closed;
    [opened setEntryBlock:^(NSDictionary *piggyback) {
        [self greenLightOn];
    }];
    [closed setEntryBlock:^(NSDictionary *piggyback) {
        [self redLightOn];
    }];
    
    [sm transitionFrom:closed to:opened forEvent:@"coin"];
    [sm transitionFrom:opened to:closed forEvent:@"pass"];
    [sm transitionFrom:opened to:closed forEvent:@"timeout"];
    [sm transitionFrom:opened to:opened forEvent:@"coint" withBlock:^(NSDictionary *piggyback) {
        [self beep];
    }];

    //Usage
    [sm validate];
    [sm post:@"coin" withPiggyback:nil];
    [sm post:@"pass" withPiggyback:nil];
}

// An internal loopback "transition" does not change the state, but does execute the transition action.
-(void)testInternalLoopbackTransition{
    NSString* const kEventLoopback = @"loopback";
    _string = [[NSMutableString alloc] init];
    SMStateMachine* sm = [[SMStateMachine alloc] init];
    sm.globalExecuteIn = self;
    SMState* state = [sm createState:@"state"];
    sm.initialState = state;
    [state setEntryBlock:^(NSDictionary *piggyback) {
        [self State1Entry];
    }];
    [state setExitBlock:^(NSDictionary *piggyback) {
        [self State1Exit];
    }];
    [sm internalTransitionFrom:state forEvent:kEventLoopback withBlock:^(NSDictionary *piggyback) {
        [self TransAction];
    }];
    [sm post:kEventLoopback withPiggyback:nil];
    XCTAssertEqualObjects(_string, @"TransAction;", @"Only the transition action should execute");
}

// An external loopback transition leaves the current state, only to return to the same state.
// This executes the state's exit action, followed by the transition action, and finally the state's entry action.
-(void)testExternalLoopbackTransition{
    NSString* const kEventLoopback = @"loopback";
    _string = [[NSMutableString alloc] init];
    SMStateMachine* sm = [[SMStateMachine alloc] init];
    sm.globalExecuteIn = self;
    SMState* state = [sm createState:@"state"];
    sm.initialState = state;
    [state setEntryBlock:^(NSDictionary *piggyback) {
        [self State1Entry];
    }];
    [state setExitBlock:^(NSDictionary *piggyback) {
        [self State1Exit];
    }];
    [sm transitionFrom:state to:state forEvent:kEventLoopback withBlock:^(NSDictionary *piggyback) {
        [self TransAction];
    }];
    
    [sm post:kEventLoopback withPiggyback:nil];
    XCTAssertEqualObjects(_string, @"State1Exit;TransAction;State1Entry;", @"Invalid calling sequence");
}


@end
