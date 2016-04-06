//
//  BXAutoRollLabel.h
//  Pods
//
//  Created by 张逸 on 16/4/5.
//
//

#import <UIKit/UIKit.h>

@class BXAutoRollLabel;
enum BXAutoRollDirection
{
    BXAutoRollDirectionUp,
    BXAutoRollDirectionDown
};
typedef enum BXAutoRollDirection BXAutoRollDirection;

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
@property (nonatomic) NSTimeInterval timeInterval;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) NSInteger visibleAmount;
@property (nonatomic) BXAutoRollDirection direction;
@property (nonatomic, weak) id<BXAutoRollLabelDataSource> dataSource;
@property (nonatomic, weak) id<BXAutoRollLabelDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)startAutoRoll;
- (void)stopAutoScroll;
@end