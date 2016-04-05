//
//  BXAutoRollLabel.h
//  Pods
//
//  Created by 张逸 on 16/4/5.
//
//

#import <UIKit/UIKit.h>

@class BXAutoRollLabel;

@protocol BXAutoRollLabelDataSource <NSObject>
- (NSInteger)numberOfLabelsInAutoRollLabel:(BXAutoRollLabel *)autoRollLabel;
- (NSString *)titleForLabelsInAutoRollLabel:(BXAutoRollLabel *)autoRollLabel atIndex:(NSInteger)index;
@optional
- (UIColor *)backgroundColorForLabel:(BXAutoRollLabel *)autoRollLabel atIndex:(NSInteger)index;
@end

@protocol BXAutoRollLabelDelegate <NSObject>
- (void)labelTappedAtIndex:(NSInteger)index;
@end


@interface BXAutoRollLabel : UIView
@property (nonatomic) NSTimeInterval interval;
@property (nonatomic) NSInteger visibleAmount;
@property (nonatomic, weak) id<BXAutoRollLabelDataSource> dataSource;
@property (nonatomic, weak) id<BXAutoRollLabelDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)startAutoRoll;
- (void)stopAutoScroll;
@end