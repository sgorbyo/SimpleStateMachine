//
//  MyStateMachineTest.m
//  MyStateMachineTest
//
//  Created by Danilo Marinucci on 06/03/17.
//  Copyright © 2017 Codemasters International. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SMStateMachineAsync.h"


@interface MyStateMachineTest : XCTestCase

@end

@implementation MyStateMachineTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testCreate{
    
    dispatch_queue_t q = dispatch_queue_create("q", NULL);
    SMStateMachineAsync *fsm =[[SMStateMachineAsync alloc] init];
    fsm.serialQueue = q;
    
}

@end
