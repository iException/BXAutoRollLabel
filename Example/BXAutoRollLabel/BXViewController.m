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
    [self.view addSubview:self.autoRollLabel];
    [self.autoRollLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(@200);
    }];
    [self.autoRollLabel startAutoRoll];
	// Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)numberOfLabelsInAutoRollLabel:(BXAutoRollLabel *)autoRollLabel
{
    return 4;
}

- (NSString *)titleForLabelsInAutoRollLabel:(BXAutoRollLabel *)autoRollLabel atIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"new new new %ld", (long)index];
}

- (void)tapped:(UITapGestureRecognizer *)tap
{
    UIView* view = tap.view;
    CGPoint location = [tap locationInView:view];
    UILabel* touchedSubview = [view hitTest:location withEvent:nil];
    NSLog(@"tapped: %@", touchedSubview.text);
}

- (void)labelTappedAtIndex:(NSInteger)index
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Label Index" message:[NSString stringWithFormat:@"%ld", (long)index] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    }]];
    [self presentViewController:alertController animated:true completion:nil];
}

- (UIColor *)backgroundColorForLabel:(BXAutoRollLabel *)autoRollLabel atIndex:(NSInteger)index
{
    if (index % 2 == 0) {
        return [UIColor yellowColor];
    } else {
        return [UIColor redColor];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
