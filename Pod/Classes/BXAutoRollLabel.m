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
        self.timeInterval = 2.0;
        self.visibleAmount = 1;
        self.isPaused = NO;
        self.direction = BXAutoRollDirectionUp;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)tapped:(UITapGestureRecognizer *)tap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(labelTapped:index:)]) {
        UIView* view = tap.view;
        CGPoint location = [tap locationInView:view];
        UILabel* touchedSubview = [view hitTest:location withEvent:nil];
        if (touchedSubview) {
            [self.delegate labelTapped:self index:touchedSubview.tag];
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
        CGFloat rowHeight = oldFirstLabel.bounds.size.height;

        //scroll up
        if (-oldFirstLabelY >= rowHeight) {
            NSLog(@"first become last");
            [self moveFirstToLast:0];
            self.previousPoint = currentPoint;
        } else {
            if (diffY == 0) {
                return;
            }
            if (diffY < 0) {
                [oldFirstLabel mas_remakeConstraints:^(MASConstraintMaker *make){
                    make.left.equalTo(self.mas_left).with.offset(8);
                    make.top.equalTo(self.mas_top).with.offset(diffY);
                    make.right.equalTo(self.mas_right).with.offset(-8);
                    make.height.equalTo(self.mas_height).with.multipliedBy(self.heightMultiplyNumber);
                }];
            } else {
                if (oldFirstLabelY >= 0 && diffY != 0) {
                    NSLog(@"old1STY >= 0, diffY: %f", diffY);
                    //move last to first
                    [self moveLastToFirst:1.0];
                    self.previousPoint = currentPoint;
                } else {
                    if (oldFirstLabelY <= rowHeight) {
                        NSLog(@"firstLabel above: %f", oldFirstLabelY);
                        [oldFirstLabel mas_remakeConstraints:^(MASConstraintMaker *make){
                            make.left.equalTo(self.mas_left).with.offset(8);
                            make.bottom.equalTo(self.mas_top).with.offset(diffY);
                            make.right.equalTo(self.mas_right).with.offset(-8);
                            make.height.equalTo(self.mas_height).with.multipliedBy(self.heightMultiplyNumber);
                        }];
                    } else {
                        NSLog(@"firstLabel too low: %f", oldFirstLabelY);
                        [oldFirstLabel mas_remakeConstraints:^(MASConstraintMaker *make){
                            make.left.equalTo(self.mas_left).with.offset(8);
                            make.top.equalTo(self.mas_top).with.offset(diffY);
                            make.right.equalTo(self.mas_right).with.offset(-8);
                            make.height.equalTo(self.mas_height).with.multipliedBy(self.heightMultiplyNumber);
                        }];
                    }
                }
            }
        }
        [self layoutIfNeeded];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    CGPoint currentPoint = [[touches anyObject] locationInView:self];
    CGFloat diffY = currentPoint.y - self.previousPoint.y;
    self.previousPoint = currentPoint;
    if (self.labels.firstObject.frame.origin.y > 0) {
        [self moveLastToFirst:self.labels.firstObject.frame.origin.y];
    }
    [self animateToProperplace:diffY];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    CGPoint currentPoint = [[touches anyObject] locationInView:self];
    CGFloat diffY = currentPoint.y - self.previousPoint.y;
    self.previousPoint = currentPoint;
    [self animateToProperplace:diffY];
}

- (void)animateToProperplace:(CGFloat)direction
{
    //direction > 0 down, < 0 up
    [self.timer invalidate];
    [self restartTimer];
    self.isPaused = NO;
    if (direction < 0) {
        [self rollUp:self.timer];
    } else if (direction > 0) {
        [self rollDown:self.timer];
    }
}

- (void)moveLastToFirst:(CGFloat)offset
{
    UILabel *oldFirstLabel = self.labels.firstObject;
    UILabel *newFirstLabel = self.labels.lastObject;
    [self.labels removeLastObject];
    [self.labels insertObject:newFirstLabel atIndex:0];
    [newFirstLabel mas_remakeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.mas_left).with.offset(8);
        make.bottom.equalTo(self.mas_top).with.offset(offset);
        make.right.equalTo(self.mas_right).with.offset(-8);
        make.height.equalTo(self.mas_height).with.multipliedBy(self.heightMultiplyNumber);
    }];
    [oldFirstLabel mas_remakeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.mas_left).with.offset(8);
        make.top.equalTo(newFirstLabel.mas_bottom);
        make.right.equalTo(self.mas_right).with.offset(-8);
        make.height.equalTo(self.mas_height).with.multipliedBy(self.heightMultiplyNumber);
    }];
    [self layoutIfNeeded];
}

- (void)moveFirstToLast:(CGFloat)offset
{
    UILabel *oldFirstLabel = self.labels.firstObject;
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
}

#pragma mark - privates -
- (void)setupLayoutConstraints
{
    UILabel *preLabel;
    [self configureLabels];
    for (NSInteger i = 0; i < [self amountOfAll]; i += 1) {
        [self.labels[i] mas_remakeConstraints:^(MASConstraintMaker *make){
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
    [self restartTimer];
}

- (void)restartTimer
{
    switch (self.direction) {
        case BXAutoRollDirectionUp:
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(rollUp:) userInfo:nil repeats:YES];
            break;
        case BXAutoRollDirectionDown:
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(rollDown:) userInfo:nil repeats:YES];
            break;
    }
}

- (void)stopAutoScroll
{
    [self.timer invalidate];
}

- (void)rollUp:(NSTimer *)timer
{
    if (self.isPaused == YES) {
        return;
    }

    UILabel *oldFirstLabel = self.labels.firstObject;
    NSTimeInterval interval = 1.0f;
    if (oldFirstLabel.frame.origin.y < 0) {
        interval = 0.5f;
    }
    [self.labels removeObjectAtIndex:0];
    UILabel *newFirstLabel = self.labels.firstObject;
    UILabel *lastLabel = self.labels.lastObject;
    [self.labels addObject:oldFirstLabel];


    [UIView animateWithDuration:interval animations:^{
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

- (void)rollDown:(NSTimer *)timer
{
    if (self.isPaused == YES) {
        return;
    }

    UILabel *oldFirstLabel = self.labels.firstObject;
    if (oldFirstLabel.frame.origin.y < 0) {
        [UIView animateWithDuration:0.5f animations:^{
            [oldFirstLabel mas_remakeConstraints:^(MASConstraintMaker *make){
                make.top.equalTo(self.mas_top);
                make.left.equalTo(self.mas_left).with.offset(8);
                make.right.equalTo(self.mas_right).with.offset(-8);
                make.height.equalTo(self.mas_height).with.multipliedBy(self.heightMultiplyNumber);
            }];
            [self layoutIfNeeded];
        } completion:nil];
    } else {
        UILabel *lastLabel = self.labels.lastObject;
        [self.labels removeLastObject];
        [self.labels insertObject:lastLabel atIndex:0];
        [lastLabel mas_remakeConstraints:^(MASConstraintMaker *make){
            make.bottom.equalTo(self.mas_top);
            make.left.equalTo(self.mas_left).with.offset(8);
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
        [UIView animateWithDuration:1.0f animations:^{
            [lastLabel mas_remakeConstraints:^(MASConstraintMaker *make){
                make.top.equalTo(self.mas_top);
                make.left.equalTo(self.mas_left).with.offset(8);
                make.right.equalTo(self.mas_right).with.offset(-8);
                make.height.equalTo(self.mas_height).with.multipliedBy(self.heightMultiplyNumber);
            }];
            [self layoutIfNeeded];
        } completion:nil];
    }
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

- (UILabel *)patternLabelAtIndex:(NSInteger)index
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(labelStyle:index:)]) {
        return [self.delegate labelStyle:self index:index];
    } else {
        return nil;
    }
}

- (void)configureLabels
{
    NSLog(@"configureLabels");
    for (NSInteger index = 0; index < [self amountOfAll]; index += 1) {
        NSString *text = [self labelStringAtIndex:index];
        NSLog(@"text: %@", text);
        UILabel *patternLabel = [self patternLabelAtIndex:index];
        self.labels[index].text = text;
        if (patternLabel != nil) {
            self.labels[index].textColor = patternLabel.textColor;
            self.labels[index].textAlignment = patternLabel.textAlignment;
            self.labels[index].font = patternLabel.font;
            self.labels[index].backgroundColor = patternLabel.backgroundColor;
        }
    }
}

- (NSMutableArray<UILabel *> *)labels
{
    if (!_labels) {
        _labels = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < [self amountOfAll]; i += 1) {
            UILabel *label = [self textScrollLabel];
            label.tag = i;
            [self addSubview:label];
            [_labels addObject:label];
        }
    }
    return _labels;
}

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
