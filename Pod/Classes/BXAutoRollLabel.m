//
//  BXAutoRollLabel.m
//  Pods
//
//  Created by 张逸 on 16/4/5.
//
//

#import "BXAutoRollLabel.h"
#import "Masonry.h"

@interface BXAutoRollLabel ()
@property (nonatomic) NSMutableArray<UILabel *> *labels;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic) BOOL isPaused;
@property (nonatomic) CGPoint previousPoint;

@end

@implementation BXAutoRollLabel


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.interval = 2.0;
        self.visibleAmount = 1;
        self.isPaused = NO;

        //self.currentDisplayingIndex = 0;
        //[self addSubview:self.currentDisplayingLabel];
        //[self addSubview:self.nextLabel];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)tapped:(UITapGestureRecognizer *)tap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapped:)]) {
        UIView* view = tap.view;
        CGPoint location = [tap locationInView:view];
        UILabel* touchedSubview = [view hitTest:location withEvent:nil];
        if (touchedSubview) {
            [self.delegate labelTappedAtIndex:touchedSubview.tag];
        } else {
            [self.delegate labelTappedAtIndex:-1];
        }
    }
}

#pragma mark - touch events

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.previousPoint = [[touches anyObject] locationInView:self];
    self.isPaused = YES;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    self.isPaused = YES;
    UITouch *touch = touches.anyObject;
    if (touch) {
        CGPoint currentPoint = [touch locationInView:self];
        CGFloat diffY = currentPoint.y - self.previousPoint.y;

        UILabel *oldFirstLabel = self.labels.firstObject;
        CGFloat oldFirstLabelY = oldFirstLabel.frame.origin.y;
        if (diffY == 0) {
            return;
        }

        if (-oldFirstLabelY >= oldFirstLabel.bounds.size.height) {
            NSLog(@"diffY: %f, firstLabelY: %f", diffY, oldFirstLabel);
            [self.labels removeObjectAtIndex:0];
            UILabel *newFirstLabel = self.labels.firstObject;
            UILabel *lastLabel = self.labels.lastObject;
            [self.labels addObject:oldFirstLabel];

            [newFirstLabel mas_remakeConstraints:^(MASConstraintMaker *make){
                make.left.equalTo(self.mas_left).with.offset(8);
                make.top.equalTo(self.mas_top);
                make.right.equalTo(self.mas_right).with.offset(-8);
                make.height.equalTo(self.mas_height).with.multipliedBy(self.heightMultiplyNumber);
            }];

            [oldFirstLabel mas_remakeConstraints:^(MASConstraintMaker *make){
                make.top.equalTo(lastLabel.mas_bottom);
                make.left.equalTo(self.mas_left).with.offset(8);
                make.right.equalTo(self.mas_right).with.offset(-8);
                make.height.equalTo(self.mas_height).with.multipliedBy(self.heightMultiplyNumber);
            }];
            [self layoutIfNeeded];
            self.previousPoint = currentPoint;
        } else {
            [oldFirstLabel mas_remakeConstraints:^(MASConstraintMaker *make){
                make.left.equalTo(self.mas_left).with.offset(8);
                make.top.equalTo(self.mas_top).with.offset(diffY);
                make.right.equalTo(self.mas_right).with.offset(-8);
            }];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    self.isPaused = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    self.isPaused = NO;
}

#pragma mark - privates -
- (void)setupLayoutConstraints
{
    UILabel *preLabel;
    [self configureLabels];
    for (NSInteger i = 0; i < [self amountOfAll]; i += 1) {
        [self.labels[i] mas_makeConstraints:^(MASConstraintMaker *make){
            if (preLabel != nil) {
                make.top.equalTo(preLabel.mas_bottom);
                make.left.equalTo(self.mas_left).with.offset(8);
                make.right.equalTo(self.mas_right).with.offset(-8);
            } else {
                make.left.equalTo(self.mas_left).with.offset(8);
                make.top.equalTo(self.mas_top);
                make.right.equalTo(self.mas_right).with.offset(-8);
            }
            make.height.equalTo(self.mas_height).with.multipliedBy(self.heightMultiplyNumber);
        }];
        preLabel = self.labels[i];
    }
}


- (void)startAutoRoll
{
    if (self.timer) {
        return;
    }

    [self setupLayoutConstraints];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(scrollToNext:) userInfo:nil repeats:YES];
}

- (void)stopAutoScroll
{
    [self.timer invalidate];
}

- (void)scrollToNext:(NSTimer *)timer
{
    if (self.isPaused == YES) {
        return;
    }
    UILabel *oldFirstLabel = self.labels.firstObject;
    [self.labels removeObjectAtIndex:0];
    UILabel *newFirstLabel = self.labels.firstObject;
    UILabel *lastLabel = self.labels.lastObject;
    [self.labels addObject:oldFirstLabel];


    [UIView animateWithDuration:1.0f animations:^{
        [oldFirstLabel mas_remakeConstraints:^(MASConstraintMaker *make){
            make.bottom.equalTo(self.mas_top);
            make.left.equalTo(self.mas_left).with.offset(8);
            make.right.equalTo(self.mas_right).with.offset(-8);
            make.height.equalTo(self.mas_height).with.multipliedBy(self.heightMultiplyNumber);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [newFirstLabel mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.mas_left).with.offset(8);
            make.top.equalTo(self.mas_top);
            make.right.equalTo(self.mas_right).with.offset(-8);
            make.height.equalTo(self.mas_height).with.multipliedBy(self.heightMultiplyNumber);
        }];
        [oldFirstLabel mas_remakeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(lastLabel.mas_bottom);
            make.left.equalTo(self.mas_left).with.offset(8);
            make.right.equalTo(self.mas_right).with.offset(-8);
            make.height.equalTo(self.mas_height).with.multipliedBy(self.heightMultiplyNumber);
        }];
    }];
}

- (NSInteger)amountOfAll
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfLabelsInAutoRollLabel:)]) {
        return [self.dataSource numberOfLabelsInAutoRollLabel:self];
    } else {
        return 0;
    }

}

- (NSString *)labelStringAtIndex:(NSInteger)index
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(titleForLabelsInAutoRollLabel:atIndex:)]) {
        return [self.dataSource titleForLabelsInAutoRollLabel:self atIndex:index];
    }
    return @"";
}

- (UIColor *)backgroundColorAtIndex:(NSInteger)index
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(backgroundColorForLabel:atIndex:)]) {
        return [self.dataSource backgroundColorForLabel:self atIndex:index];
    }
    return [UIColor clearColor];
}

- (void)configureLabels
{
    NSLog(@"configureLabels");
    for (NSInteger index = 0; index < [self amountOfAll]; index += 1) {
        NSString *text = [self labelStringAtIndex:index];
        NSLog(@"text: %@", text);
        self.labels[index].text = text;
    }
}

- (NSMutableArray<UILabel *> *)labels
{
    if (!_labels) {
        _labels = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < [self amountOfAll]; i += 1) {
            UILabel *label = [self textScrollLabel];
            label.tag = i;
            label.backgroundColor = [self backgroundColorAtIndex:i];
            [self addSubview:label];
            [_labels addObject:label];
        }
    }
    return _labels;
}
/*
- (UILabel *)currentDisplayingLabel
{
    if (!_currentDisplayingLabel) {
        _currentDisplayingLabel = [self textScrollLabel];
    }

    return _currentDisplayingLabel;
}

- (UILabel *)nextLabel
{
    if (!_nextLabel) {
        _nextLabel = [self textScrollLabel];
    }

    return _nextLabel;
}
*/

- (CGFloat)heightMultiplyNumber
{
    return 1 / (CGFloat)self.visibleAmount;
}

- (UILabel *)textScrollLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.userInteractionEnabled = YES;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:14];
    return label;
}

@end
