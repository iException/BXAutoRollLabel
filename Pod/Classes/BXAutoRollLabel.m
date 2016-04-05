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
@property (nonatomic, strong) UILabel *currentDisplayingLabel;
@property (nonatomic, strong) UILabel *nextLabel;
@property (nonatomic) NSInteger currentDisplayingIndex;
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation BXAutoRollLabel


- (instancetype)initWithFrame:(CGRect)frame interval:(NSTimeInterval)interval visibleAmount:(NSInteger)visibleAmount
{
    self = [super initWithFrame:frame];

    if (self) {
        self.clipsToBounds = YES;
        self.interval = interval;
        self.visibleAmount = visibleAmount;
        self.currentDisplayingIndex = 0;
        [self addSubview:self.currentDisplayingLabel];
        [self addSubview:self.nextLabel];

        [self setupLayoutConstraints];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)tapped:(UITapGestureRecognizer *)tap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapped:)]) {
        [self.delegate tapped:tap];
    }
}

#pragma mark - privates -
- (void)setupLayoutConstraints
{
    [self.currentDisplayingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(8);
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).with.offset(-8);
    }];

    [self.nextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left).with.offset(8);
        make.right.equalTo(self.mas_right).with.offset(-8);
    }];
}


- (void)startAutoRoll
{
    if (self.timer) {
        return;
    }

    if (self.dataSource && [self.dataSource respondsToSelector:@selector(titleForNewsInAutoRollLabel:atIndex:)]) {
        self.currentDisplayingLabel.text = [self.dataSource titleForNewsInAutoRollLabel:self atIndex:self.currentDisplayingIndex];
    }

    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(scrollToNext:) userInfo:nil repeats:YES];
}

- (void)stopAutoScroll
{
    [self.timer invalidate];
}

- (void)scrollToNext:(NSTimer *)timer
{
    NSInteger nextIndex = [self nextDisplayingIndex];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(titleForNewsInAutoRollLabel:atIndex:)]) {
        self.nextLabel.text = [self.dataSource titleForNewsInAutoRollLabel:self atIndex:nextIndex];
    }

    [self animateNextLabelToVisibleCompletion:^{
        UILabel *tmpLabel = self.currentDisplayingLabel;
        self.currentDisplayingLabel = self.nextLabel;
        self.nextLabel = tmpLabel;
        self.currentDisplayingIndex = nextIndex;

        [self putNextLabelBackToBottom];
    }];
}

- (void)animateNextLabelToVisibleCompletion:(void (^)())completion
{
    [UIView animateWithDuration:0.3f animations:^{
        [self.currentDisplayingLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).with.offset(8);
            make.bottom.equalTo(self.mas_top);
            make.right.equalTo(self.mas_right).with.offset(-8);
        }];

        [self.nextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).with.offset(8);
            make.centerY.equalTo(self);
            make.right.equalTo(self.mas_right).with.offset(-8);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)putNextLabelBackToBottom
{
    [self.nextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(8);
        make.top.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right).with.offset(8);
    }];
}


- (NSInteger)nextDisplayingIndex
{
    NSInteger totalCount = 0;
    NSInteger nextIndex = self.currentDisplayingIndex + 1;

    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfNewsInAutoRollLabel:)]) {
        totalCount = [self.dataSource numberOfNewsInAutoRollLabel:self];
    }

    if (nextIndex >= totalCount) {
        nextIndex = 0;
    }
    return nextIndex;
}

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

- (UILabel *)textScrollLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:14];
    return label;
}

@end
