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

@interface BXViewController () <BXAutoRollLabelDataSource, BXAutoRollLabelDelegate>
@property (nonatomic) BXAutoRollLabel *autoRollLabel;
@end

@implementation BXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.autoRollLabel = [[BXAutoRollLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.autoRollLabel.visibleAmount = 3;
    self.autoRollLabel.dataSource = self;
    self.autoRollLabel.delegate = self;
    self.autoRollLabel.backgroundColor = [UIColor clearColor];
    self.autoRollLabel.direction = BXAutoRollDirectionUp;
    [self.view addSubview:self.autoRollLabel];
    [self.autoRollLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(@200);
    }];
    [self.autoRollLabel startAutoRoll];
}

- (NSInteger)numberOfLabelsInAutoRollLabel:(BXAutoRollLabel *)autoRollLabel
{
    return 8;
}

- (NSString *)titleForLabelsInAutoRollLabel:(BXAutoRollLabel *)autoRollLabel atIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"new new new %ld", (long)index];
}

- (void)labelTapped:(BXAutoRollLabel *)autoRollLabel index:(NSInteger)index
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Label Index" message:[NSString stringWithFormat:@"%ld", (long)index] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    }]];
    [self presentViewController:alertController animated:true completion:nil];
}

- (UILabel *)labelStyle:(BXAutoRollLabel *)autoRollLabel index:(NSInteger)index
{
    UILabel *patternLabel = [[UILabel alloc] init];
    patternLabel.textColor = [UIColor redColor];
    patternLabel.textAlignment = NSTextAlignmentCenter;
    return patternLabel;
}

@end
