//
//  GCPChartViewController.m
//  Bluetooth Beacon Demo App
//
//  Created by Joseph Pecoraro on 7/24/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "GCPChartViewController.h"
#import "BEMSimpleLineGraphView.h"

@interface GCPChartViewController () <BEMSimpleLineGraphDelegate>

@end

@implementation GCPChartViewController

-(instancetype)initWithXValues:(NSArray *)xValues YValues:(NSArray *)yValues {
    self = [super init];
    if (self) {
        self.xValues = [xValues mutableCopy];
        self.yValues = [yValues mutableCopy];
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    BEMSimpleLineGraphView *myGraph = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    myGraph.delegate = self;
    [self.view addSubview:myGraph];
}

#pragma mark Line Graph Delegate

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return [self.xValues count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[self.yValues objectAtIndex:index] floatValue];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
