//
//  MNCustomAlertView.m
//  Meiningjia-Shopkeeper
//
//  Created by 刘轩博 on 17/1/3.
//  Copyright © 2017年 Baosight. All rights reserved.
//

#import "JMCustomAlertView.h"
#import "JMCustomAlertCell.h"
#import "Masonry.h"

#define CellHeight 46
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define RgbColor(r, g, b, a) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:a]
#define Font(s) [UIFont systemFontOfSize:s]

@interface JMCustomAlertView ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, CAAnimationDelegate, UIGestureRecognizerDelegate>
{
    NSNumber *_mainViewBottom;
    BOOL _selectedSign;  // cell右边是否有标识
}
@property (nonatomic, assign) AlertStyle style;

@property (nonatomic, strong) JMCustomAlertConfig *styleConfig;

@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) UIImageView *customImageView;

@property (nonatomic, strong) UIImageView *titleImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) NSArray *buttonTitles;


@end

@implementation JMCustomAlertView
 
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 构造器
+ (JMCustomAlertView *)alertWithStyle:(AlertStyle)style title:(NSString *)title message:(NSString *)message delegate:(id)delegate buttonTitles:(NSArray<NSString *> *)buttonTitles styleConfig:(JMCustomAlertConfig *)styleConfig {
    JMCustomAlertView *alertView = [[JMCustomAlertView alloc] initWithStyle:style title:title message:message delegate:delegate buttonTitles:buttonTitles styleConfig:styleConfig];
    return alertView;
}

- (instancetype)initWithStyle:(AlertStyle)style title:(NSString *)title message:(NSString *)message delegate:(id)delegate buttonTitles:(NSArray<NSString *> *)buttonTitles styleConfig:(JMCustomAlertConfig *)styleConfig {
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (self) {
        self.styleConfig = styleConfig;
        if (!self.styleConfig) {
            self.styleConfig = [JMCustomAlertConfig share];
        }
        self.style = style;
        self.title = title;
        self.message = message;
        self.delegate = delegate;
        self.buttonTitles = buttonTitles;
        // 初始化默认属性值
        [self initialDefaultValue];
        // 根据类型创建视图
        [self createMainView];
    }
    return self;
}

- (void)initialDefaultValue {
    // 初始化属性值
    self.superView = [[UIApplication sharedApplication].delegate window];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    _autoDismissWhenConfirm = YES;
    _dismissWhenTouchMask = !_buttonTitles.count;
    _logoImgSize = CGSizeMake(75, 75);
    _customImgSize = CGSizeMake(100, 100);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskTapAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

#pragma mark - 创建alertView
- (void)createMainView {
    // normal类型的视图懒加载创建
    if (_style == AlertStyleTextField) {
        [self.mainView addSubview:self.textField];
    } else if (_style == AlertStyleTextView) {
        [self.mainView addSubview:self.textView];
    } else if (_style == AlertStyleSelection) {
        [self.mainView addSubview:self.tableView];
        UIView *topLine = [[UIView alloc] init];
        topLine.backgroundColor = _styleConfig.lineColor;
        [self.mainView addSubview:topLine];
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.mainView);
            make.bottom.equalTo(self.tableView.mas_top).offset(-0.5);
            make.height.equalTo(@0.5);
        }];
    } else if (_style == AlertStyleCustom) {
        self.customBackView = [[UIView alloc] init];
        _customBackView.layer.cornerRadius = self.mainView.layer.cornerRadius;
        [self.mainView addSubview:_customBackView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskTapAction:)];
        tap.delegate = self;
        [_customBackView addGestureRecognizer:tap];
    }
    [self createBottomButton];
}

#pragma mark - 创建底部按钮 确定, 取消
- (void)createBottomButton {
    UIView *lastView;
    for (int i = 0; i < _buttonTitles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:[_buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:_buttonTitles.count == 1 || (_buttonTitles.count > 2 && i == 0) || (_buttonTitles.count == 2 && i == 1) ? _styleConfig.themeColor : _styleConfig.contentColor forState:UIControlStateNormal];
        button.titleLabel.font = Font(16);
        button.adjustsImageWhenHighlighted = NO;
        button.tag = i + 1;
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = _mainView.layer.cornerRadius;
        [button addTarget:self action:@selector(operationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:button];
        if (i != 0) {
            // 分割线
            UIView *splitLine = [[UIView alloc] init];
            splitLine.backgroundColor = _styleConfig.lineColor;
            [self.mainView addSubview:splitLine];
            if (_buttonTitles.count > 2) {
                // 竖排显示
                [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.equalTo(button);
                    make.height.equalTo(@0.5);
                    make.bottom.equalTo(button.mas_top);
                }];
            } else {
                // 横排显示
                [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.bottom.equalTo(button);
                    make.width.equalTo(@0.5);
                    make.right.equalTo(button.mas_left);
                }];
            }
        }
        lastView = button;
    }
    if (_buttonTitles.count > 0 && _style != AlertStyleSelection) {
        UIView *buttonTopLine = [[UIView alloc] init];
        buttonTopLine.backgroundColor = _styleConfig.lineColor;
        [self.mainView addSubview:buttonTopLine];
        UIButton *topButton = (UIButton *)[self.mainView viewWithTag:1];
        [buttonTopLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.mainView);
            make.bottom.equalTo(topButton.mas_top).offset(-0.5);
            make.height.equalTo(@0.5);
        }];
    }
}

#pragma mark - 自定义弹框样式, 更新customView的高
- (void)updateCustomViewHeight:(NSNumber *)height bottomView:(UIView *)bottomView offsetY:(CGFloat)offsetY {
    if (bottomView) {
        [_customBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.mainView);
            make.bottom.equalTo(bottomView.mas_bottom).offset(offsetY);
            if (self->_titleLabel) {
                make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
            } else {
                make.top.equalTo(self.mainView);
            }
        }];
    } else if (height) {
        [_customBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(height);
        }];
    }
}

- (void)setConstraints {
    if (_logoImageView.superview) {
        [_logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mainView);
            make.centerY.equalTo(self.mainView.mas_top);
            make.width.equalTo(@(self.logoImgSize.width));
            make.height.equalTo(@(self.logoImgSize.height));
        }];
    }
    if (_customImageView.superview) {
        [_customImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mainView);
            make.width.equalTo(@(self.customImgSize.width));
            make.height.equalTo(@(self.customImgSize.height));
            if (self->_logoImageView) {
                make.top.equalTo(self.logoImageView.mas_bottom).offset(15);
            } else {
                make.top.equalTo(self.mainView.mas_top).offset(15);
            }
        }];
    }

    if (_titleLabel.superview) {
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mainView).offset(self->_titleImageView ? 10 : 0);
            if (self->_customImageView) {
                make.top.equalTo(self.customImageView.mas_bottom).offset(15);
            } else if (self->_logoImageView) {
                make.top.equalTo(self.logoImageView.mas_bottom).offset(15);
            } else if (self.style == AlertStyleSelection || self.style == AlertStyleCustom) {
                make.top.equalTo(self.mainView.mas_top).offset(15);
            } else {
                make.top.equalTo(self.mainView.mas_top).offset(25);
            }
        }];
        if (_titleImageView.superview) {
            [_titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.titleLabel);
                make.right.equalTo(self.titleLabel.mas_left).offset(-5);
                make.width.height.equalTo(@18.5);
            }];
        }
    } else {
        if (_titleImageView) {
            [_titleImageView removeFromSuperview];
            _titleImageView = nil;
        }
    }
    if (_messageLabel.superview) {
        [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(20);
            make.right.offset(-20);
            if (self->_titleLabel) {
                make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
            } else if (self->_customImageView) {
                make.top.equalTo(self.customImageView.mas_bottom).offset(20);
            } else if (self->_logoImageView) {
                make.top.equalTo(self.logoImageView.mas_bottom).offset(self.style == AlertStyleNormal ? 20 : 15);
            } else {
                make.top.equalTo(self.mainView.mas_top).offset(self.style == AlertStyleNormal ? 40 : 22);
            }
        }];
    }
    if (_style == AlertStyleTextField && _textField.superview) {
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(15);
            make.right.offset(-15);
            make.height.equalTo(@44);
            if (self->_messageLabel) {
                make.top.equalTo(self.messageLabel.mas_bottom).offset(20);
            } else if (self->_titleLabel) {
                make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
            } else if (self->_customImageView) {
                make.top.equalTo(self.customImageView.mas_bottom).offset(20);
            } else if (self->_logoImageView) {
                make.top.equalTo(self.logoImageView.mas_bottom).offset(30);
            } else {
                make.top.equalTo(self.mainView.mas_top).offset(30);
            }
        }];
    }
    if (_style == AlertStyleTextView && _textView.superview) {
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(15);
            make.right.offset(-15);
            make.height.equalTo(@80);
            if (self->_messageLabel) {
                make.top.equalTo(self.messageLabel.mas_bottom).offset(20);
            } else if (self->_titleLabel) {
                make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
            } else if (self->_customImageView) {
                make.top.equalTo(self.customImageView.mas_bottom).offset(20);
            } else if (self->_logoImageView) {
                make.top.equalTo(self.logoImageView.mas_bottom).offset(30);
            } else {
                make.top.equalTo(self.mainView.mas_top).offset(30);
            }
        }];
    }
    if (_style == AlertStyleSelection && _tableView.superview) {
        NSInteger rowCount = MIN(self.selections.count, 5);
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.mainView);
            if (self->_titleLabel) {
                make.top.equalTo(self.titleLabel.mas_bottom).offset((CellHeight - self.titleLabel.font.pointSize) / 2);
            } else {
                make.top.equalTo(self.mainView);
            }
            make.height.equalTo(@(rowCount * CellHeight));
        }];
    }
    if (_style == AlertStyleCustom && _customBackView.superview && !_customBackView.constraints) {
        [_customBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.mainView);
            make.height.equalTo(@100);
            if (self->_titleLabel) {
                make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
            } else {
                make.top.equalTo(self.mainView);
            }
        }];
    }
    
    UIView *bottomView;
    CGFloat offsetY = 0;
    if (_style == AlertStyleNormal) {
        offsetY = 25;
        if (_messageLabel) {
            bottomView = _messageLabel;
        } else if (_titleLabel) {
            bottomView = _titleLabel;
        } else if (_customImageView) {
            bottomView = _customImageView;
        } else if (_logoImageView) {
            bottomView = _logoImageView;
            offsetY = 30;
        } else {
            bottomView = _mainView;
            offsetY = 80;
        }
    } else if (_style == AlertStyleTextField) {
        bottomView = _textField;
        offsetY = 25;
    } else if (_style == AlertStyleTextView) {
        bottomView = _textView;
        offsetY = 25;
    } else if (_style == AlertStyleSelection) {
        bottomView = _tableView;
    } else {
        bottomView = _customBackView;
    }

    UIView *lastView;
    for (int i = 0; i < _buttonTitles.count; i++) {
        UIButton *button = (UIButton *)[self.mainView viewWithTag:i + 1];
        if (_buttonTitles.count > 2) {
            // 竖排显示
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.mainView);
                make.height.equalTo(@(CellHeight));
                if (!lastView) {
                    make.top.equalTo(bottomView.mas_bottom).offset(offsetY);
                } else {
                    make.top.equalTo(lastView.mas_bottom).offset(0.5);
                }
            }];
        } else {
            // 横排显示
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(bottomView.mas_bottom).offset(offsetY);
                make.height.equalTo(@(CellHeight));
                if (!lastView) {
                    make.left.offset(0);
                } else {
                    make.left.equalTo(lastView.mas_right).offset(0.5);
                    make.width.equalTo(lastView);
                }
                if (i == self.buttonTitles.count - 1) {
                    make.right.offset(0);
                }
            }];
        }
        lastView = button;
    }
    [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (lastView) {
            make.bottom.equalTo(lastView.mas_bottom);
        }  else {
            make.bottom.equalTo(bottomView.mas_bottom).offset(offsetY);
        }
    }];
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _selections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_useCustomTableViewCell && [self.delegate respondsToSelector:@selector(customAlertView:cellForRowAtIndexPath:)]) {
        // 自定义cell
        UITableViewCell *cell = [self.delegate customAlertView:self cellForRowAtIndexPath:indexPath];
        return cell ? cell : [UITableViewCell new];
    } else {
        // 默认cell
        static NSString *identifier = @"SelectOptionsCell";
        JMCustomAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[JMCustomAlertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        NSString *leftText = [_selections objectAtIndex:indexPath.row];
        cell.leftLabel.text = leftText;
        
        if (_selectedSign) {
            // 初始没有图片, 选择了之后才有图片
            cell.rightImg.image = indexPath.row == _selectedIndex ? _styleConfig.arrowImg : nil;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(customAlertView:didSelectIndex:)]) {
        [self.delegate customAlertView:self didSelectIndex:indexPath.row];
    }
    if (_buttonTitles.count == 0) {
        if (_autoDismissWhenConfirm) {
            [self dismiss:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - 点击事件
// 底部按钮点击事件
- (void)operationButtonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(customAlertView:clickedButtonAtIndex:)]) {
        [self.delegate customAlertView:self clickedButtonAtIndex:sender.tag - 1];
    }
    if (_autoDismissWhenConfirm) {
        [self dismiss:YES];
    }
}

// 背景遮罩点击事件
- (void)maskTapAction:(UIGestureRecognizer *)rec {
    [self endEditing:YES];
    if (_dismissWhenTouchMask) {
        [self dismiss:YES];
    }
}

#pragma mark - 显示alertView
- (void)show:(BOOL)animated {
    [self setConstraints];
    if (_style == AlertStyleSelection) {
        [_tableView reloadData];
    }
    [self.superView addSubview:self];
    
    if (!animated) {
        // 直接显示
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.mainView.alpha = 1;
    } else {
        // 添加动画
        [UIView animateWithDuration:0.1 animations:^{
            self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        }];
        [UIView animateWithDuration:0.15 animations:^{
            self.mainView.alpha = 1;
        }];
        [self showAnimationFromValue:@1.1 toValue:@1 duration:0.15 keyPath:nil];
    }
    // 3秒后自动消失
    if (self.autoDismissWhenNoButton && !self.buttonTitles.count) {
        __weak typeof(self) weakSelf = self;
        [NSTimer scheduledTimerWithTimeInterval:3 target:weakSelf selector:@selector(timerAction:) userInfo:nil repeats:NO];
    }
}

#pragma mark - 消失alertView
- (void)dismiss:(BOOL)animated {
    [self endEditing:YES];
    if (animated) {
        [UIView animateWithDuration:0.15 animations:^{
            self.mainView.alpha = 0;
            self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
}

#pragma mark - 3秒钟后响应block
- (void)timerAction:(NSTimer *)timer {
    [self dismiss:YES];
    if (self.didAutoDismissed) {
        self.didAutoDismissed();
    }
    [timer invalidate];
}

#pragma mark - 显示的动画效果
- (void)showAnimationFromValue:(NSNumber *)fromVlaue toValue:(NSNumber *)toValue duration:(CGFloat)duration keyPath:(NSString *)keyPath {
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.scale";
    animation.fromValue = fromVlaue;
    animation.toValue = toValue;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = duration;
    [self.mainView.layer addAnimation:animation forKey:keyPath];
}

#pragma mark - 系统代理事件
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]] || [NSStringFromClass(touch.view.class) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""] && range.location == 0) {
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
    return YES;
}

#pragma mark - 键盘弹出通知
- (void)addKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notify {
    CGFloat keyboardHeight = [[[notify userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    if (!_mainViewBottom) {
        _mainViewBottom = @(CGRectGetMaxY(self.mainView.frame));
    }
    CGFloat hiddenHeight = [_mainViewBottom floatValue] + keyboardHeight - SCREEN_HEIGHT;
    if (hiddenHeight > 0) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self).offset(-(hiddenHeight));
            }];
            [self layoutIfNeeded];
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notify {
    [UIView animateWithDuration:0.25 animations:^{
        [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(0);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self->_mainViewBottom = nil;
    }];
}

#pragma mark - setter method
- (void)setLogoImage:(UIImage *)logoImage {
    _logoImage = logoImage;
    if (_logoImage) {
        self.logoImageView.image = _logoImage;
        [self.mainView addSubview:self.logoImageView];
    } else if (_logoImageView) {
        [_logoImageView removeFromSuperview];
        _logoImageView = nil;
    }
}

- (void)setCustomImage:(UIImage *)customImage {
    _customImage = customImage;
    if (_customImage) {
        if (_style < 3) {
            self.customImageView.image = _customImage;
            [self.mainView addSubview:self.customImageView];
        }
    } else if (_customImageView) {
        [_customImageView removeFromSuperview];
        _customImageView = nil;
    }
}

- (void)setTitleImage:(UIImage *)titleImage {
    _titleImage = titleImage;
    if (_titleImage) {
        self.titleImageView.image = _titleImage;
        [self.mainView addSubview:self.titleImageView];
    } else if (_titleImageView) {
        [_titleImageView removeFromSuperview];
        _titleImageView = nil;
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    if (_title && ![_title isEqualToString:@""]) {
        self.titleLabel.text = _title;
        [self.mainView addSubview:self.titleLabel];
    } else if (_titleLabel) {
        [_titleLabel removeFromSuperview];
        _titleLabel = nil;
    }
}

- (void)setMessage:(NSString *)message {
    _message = message;
    if (_message && ![_message isEqualToString:@""]) {
        if (_style < 3) {
            self.messageLabel.text = _message;
            [self.mainView addSubview:self.messageLabel];
        }
    } else if (_messageLabel) {
        [_messageLabel removeFromSuperview];
        _messageLabel = nil;
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    _selectedSign = YES;
}

- (void)setSpecificButtonIndex:(NSInteger)specificButtonIndex {
    _specificButtonIndex = specificButtonIndex;
    if (_specificButtonIndex < _buttonTitles.count) {
        for (int i = 0; i < _buttonTitles.count; i++) {
            UIButton *bottomButton = (UIButton *)[self.mainView viewWithTag:i + 1];
            [bottomButton setTitleColor:i == _specificButtonIndex ? _styleConfig.themeColor : _styleConfig.contentColor forState:UIControlStateNormal];
        }
    }
}

#pragma mark - gette method
- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] init];
        _mainView.backgroundColor = _styleConfig.backgroundColor;
        _mainView.layer.cornerRadius = _styleConfig.cornerRadius;
        _mainView.alpha = 0.5;
        [self addSubview:_mainView];
        [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(self.styleConfig.edge);
            make.right.offset(-self.styleConfig.edge);
            make.centerY.equalTo(self).offset(self.styleConfig.offsetY);
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskTapAction:)];
        tap.delegate = self;
        [_mainView addGestureRecognizer:tap];
    }
    return _mainView;
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _logoImageView;
}

- (UIImageView *)customImageView {
    if (!_customImageView) {
        _customImageView = [[UIImageView alloc] init];
        _customImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _customImageView;
}

- (UIImageView *)titleImageView {
    if (!_titleImageView) {
        _titleImageView = [[UIImageView alloc] init];
        _titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _titleImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = _styleConfig.titleTextAttributes[NSFontAttributeName];
        _titleLabel.textColor = _styleConfig.titleTextAttributes[NSForegroundColorAttributeName];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = _styleConfig.messageTextAttributes[NSFontAttributeName];
        _messageLabel.textColor = _styleConfig.messageTextAttributes[NSForegroundColorAttributeName];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
    }
    return _messageLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.delegate = self;
        _textField.font = Font(16);
        _textField.textColor = _styleConfig.messageTextAttributes[NSForegroundColorAttributeName];
        _textField.layer.cornerRadius = 4;
        _textField.layer.borderColor = _styleConfig.lineColor.CGColor;
        _textField.layer.borderWidth = 0.5;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _textField;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.delegate = self;
        _textView.font = Font(16);
        _textView.textColor = _styleConfig.messageTextAttributes[NSForegroundColorAttributeName];
        _textView.returnKeyType = UIReturnKeyNext;
        _textView.layer.cornerRadius = 4;
        _textView.layer.borderColor = _styleConfig.lineColor.CGColor;
        _textView.layer.borderWidth = 0.5;
        [_textView addSubview:self.placeholderLabel];
        [_placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(5);
            make.right.offset(-5);
            make.top.offset(8);
        }];
    }
    return _textView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.layer.cornerRadius = _mainView.layer.cornerRadius;
        _tableView.layer.masksToBounds = YES;
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        if ([_tableView respondsToSelector:@selector(setSeparatorColor:)]) {
            [_tableView setSeparatorColor:_styleConfig.lineColor];
        }
    }
    return _tableView;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.textColor = _styleConfig.placeholderColor;
        _placeholderLabel.font = _textView.font;
        _placeholderLabel.numberOfLines = 0;
    }
    return _placeholderLabel;
}


@end
