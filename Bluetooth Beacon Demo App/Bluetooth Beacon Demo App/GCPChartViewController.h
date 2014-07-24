//
//  GCPChartViewController.h
//  Bluetooth Beacon Demo App
//
//  Created by Joseph Pecoraro on 7/24/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCPChartViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *xValues;
@property (nonatomic, strong) NSMutableArray *yValues;

-(instancetype)initWithXValues:(NSArray *)xValues YValues:(NSArray *)yValues;

@end
