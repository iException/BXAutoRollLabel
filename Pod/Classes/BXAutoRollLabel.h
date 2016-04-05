//
//  BXAutoRollLabel.h
//  Pods
//
//  Created by 张逸 on 16/4/5.
//
//

#import <UIKit/UIKit.h>

@interface BXAutoRollLabel : UIView
@property (nonatomic, strong) NSArray<NSString *> *texts;
@property (nonatomic, assign) NSTimeInterval interval;

- (instancetype)initWithFrame:(CGRect)frame andTexts: (NSArray<NSString *> *)texts interval:(NSTimeInterval)interval;
- (void)startAutoScroll;
- (void)stopAutoScroll;
@end
