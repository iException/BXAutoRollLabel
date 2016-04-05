//
//  BXViewController.m
//  BXAutoRollLabel
//
//  Created by monzy613 on 04/05/2016.
//  Copyright (c) 2016 monzy613. All rights reserved.
//

#import "BXViewController.h"
#import "Masonry.h"
#import <BXAutoRollLabel/BXAutoRollLabel.h>

@interface BXViewController ()
@property (nonatomic) BXAutoRollLabel *autoRollLabel;
@end

@implementation BXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.autoRollLabel = [[BXAutoRollLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0) andTexts:@[@"text1", @"text2", @"text3", @"text4"] interval:1];
    [self.view addSubview:self.autoRollLabel];
    [self.autoRollLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(@50);
    }];
    [self.autoRollLabel startAutoScroll];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
