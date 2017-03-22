//
// Created by est1908 on 12/28/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SMTurnstileTests.h"
#import "SMMonitorNSLog.h"


@interface  SMTurnstileTests()
@property (nonatomic) NSInteger returnCoinsCounter;
@property (nonatomic) BOOL isWorkTime;

@end

@implementation SMTurnstileTests
@synthesize returnCoinsCounter = _returnCoinsCounter;
@synthesize isWorkTime = _isWorkTime;


-(void)returnCoin{
    self.returnCoinsCounter++;
}

-(void)greenLightOn{

}

-(void)redLightOn{

}


-(void)testTurnstileWithDecision{
    //Create structure
    __weak id weakSelf = self;
    SMMonitorNSLog *nsLogMonitor =[[SMMonitorNSLog alloc] initWithSmName:@"Turnstile"];
    SMStateMachine *sm = [[SMStateMachine alloc] init];
    sm.globalExecuteIn = self; //execute all selectors on self object
    //log to NSLog
    sm.monitor = nsLogMonitor;
    SMState *opened = [sm createState:@"open"];
    SMState *closed = [sm createState:@"closed"];
    SMDecision *isWorkTime = [sm createDecision:@"isWorkTime" withPredicateBoolBlock:^BOOL(NSDictionary *piggyback) {
        return [weakSelf isWorkTime];
    }];
    sm.initialState = closed;
    [opened setEntryBlock:^(NSDictionary *piggyback) {
        [self greenLightOn];
    }];
    [closed setEntryBlock:^(NSDictionary *piggyback) {
        [self redLightOn];
    }];
    [sm transitionFrom:closed to:isWorkTime forEvent:@"coin"];
    [sm trueTransitionFrom:isWorkTime to:opened];
    [sm falseTransitionFrom:isWorkTime to:closed withBlock:^(NSDictionary *piggyback) {
        [self returnCoin];
    }];
    [sm transitionFrom:opened to:closed forEvent:@"pass"];
    [sm transitionFrom:opened to:closed forEvent:@"timeout"];
    [sm transitionFrom:opened to:opened forEvent:@"coin" withBlock:^(NSDictionary *piggyback) {
        [self returnCoin];
    }];
    [sm validate];

    //Usage
    self.isWorkTime = NO;
    self.returnCoinsCounter = 0;
    [sm post:@"coin" withPiggyback:nil];
    XCTAssertEqual(1, self.returnCoinsCounter);
    self.isWorkTime = YES;
    [sm post:@"coin" withPiggyback:nil];
    XCTAssertEqual(1, self.returnCoinsCounter);
    [sm post:@"coin" withPiggyback: nil];
    XCTAssertEqual(2, self.returnCoinsCounter);
}

@end
