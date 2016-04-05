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
- (NSInteger)numberOfNewsInAutoRollLabel:(BXAutoRollLabel *)autoRollLabel;
- (NSString *)titleForNewsInAutoRollLabel:(BXAutoRollLabel *)autoRollLabel atIndex:(NSInteger)index;
@end

@protocol BXAutoRollLabelDelegate <NSObject>
- (void)tapped:(UITapGestureRecognizer *)tap;
@end


@interface BXAutoRollLabel : UIView
@property (nonatomic) NSTimeInterval interval;
@property (nonatomic) NSInteger visibleAmount;
@property (nonatomic, weak) id<BXAutoRollLabelDataSource> dataSource;
@property (nonatomic, weak) id<BXAutoRollLabelDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame interval:(NSTimeInterval)interval visibleAmount:(NSInteger)amount;
- (void)startAutoRoll;
- (void)stopAutoScroll;
@end
