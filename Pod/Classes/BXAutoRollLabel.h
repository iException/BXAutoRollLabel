//
//  BXAutoRollLabel.h
//  Pods
//
//  Created by 张逸 on 16/4/5.
//
//

#import <UIKit/UIKit.h>

@class BXAutoRollLabel;

typedef NS_ENUM (NSInteger, BXAutoRollDirection) {
    BXAutoRollDirectionUp,
    BXAutoRollDirectionDown
};

@protocol BXAutoRollLabelDataSource <NSObject>
- (NSInteger)numberOfLabelsInAutoRollLabel:(BXAutoRollLabel *)autoRollLabel;
- (NSString *)titleForLabelsInAutoRollLabel:(BXAutoRollLabel *)autoRollLabel atIndex:(NSInteger)index;
@end

@protocol BXAutoRollLabelDelegate <NSObject>
- (void)labelTapped:(BXAutoRollLabel *)autoRollLabel index:(NSInteger)index;
- (UILabel *)labelStyle:(BXAutoRollLabel *)autoRollLabel index:(NSInteger)index;
@end


@interface BXAutoRollLabel : UIView
@property (nonatomic) NSTimeInterval timeInterval;
@property (nonatomic) NSInteger visibleAmount;
@property (nonatomic) BXAutoRollDirection direction;
@property (nonatomic, weak) id<BXAutoRollLabelDataSource> dataSource;
@property (nonatomic, weak) id<BXAutoRollLabelDelegate> delegate;
@property (nonatomic) UILabel *patternLabel;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)startAutoRoll;
- (void)stopAutoScroll;
@end