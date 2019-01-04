//
//  MNCustomAlertView.h
//  Meiningjia-Shopkeeper
//
//  Created by 刘轩博 on 17/1/3.
//  Copyright © 2017年 Baosight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMCustomAlertConfig.h"
@class JMCustomAlertView;
typedef NS_ENUM(NSInteger, AlertStyle) {
    AlertStyleNormal,       // 普通文字类型
    AlertStyleTextField,    // TextField类型
    AlertStyleTextView,     // TextView类型
    AlertStyleSelection,    // tableView选择类型
    AlertStyleCustom    // 自定义类型
};
@protocol JMCustomAlertViewDelegate <NSObject>

@optional
// 点击底部按钮
- (void)customAlertView:(JMCustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
// 点击tableViewCell
- (void)customAlertView:(JMCustomAlertView *)alertView didSelectIndex:(NSInteger)selectedIndex;

/**
 AlertViewStyleSelection 类型l时, 自定义cell代理方法
 @param alertView alertView
 @param indexPath indexPath
 
 @return 返回一个自定义的cell对象
 */
- (UITableViewCell *)customAlertView:(JMCustomAlertView *)alertView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface JMCustomAlertView : UIView

@property (nonatomic, weak) id<JMCustomAlertViewDelegate> delegate;

@property (nonatomic, strong) UIView *mainView;

/// titleIcon
@property (nonatomic, strong) UIImage *titleImage;
/// 标题
@property (nonatomic, strong) NSString *title;
/// 文字
@property (nonatomic, strong) NSString *message;
/// 带输入框
@property (nonatomic, strong) UITextField *textField;
/// 文本域
@property (nonatomic, strong) UITextView *textView;
/// UITextView的placeHolder
@property (nonatomic, strong) UILabel *placeholderLabel;
/// selection类型的tableView
@property (nonatomic, strong) UITableView *tableView;
/// customStyle的背景视图
@property (nonatomic, strong) UIView *customBackView;

/// 当为AlertStyleSelection类型时, 默认数据源
@property (nonatomic, strong) NSArray<NSString *> *selections;

/// 设置alert的superView, 默认为window
@property (nonatomic, strong) UIView *superView;


/// 当为AlertViewStyleSelection类型时, 上一次选中的index
@property (nonatomic, assign) NSInteger selectedIndex;

/// 设置显示特殊颜色的底部按钮的index
@property (nonatomic, assign) NSInteger specificButtonIndex;

/// 是否使用自定义的cell, default is NO
@property (nonatomic, assign) BOOL useCustomTableViewCell;

/// 点击确定按钮弹框是否自动消失, default is YES
@property (nonatomic, assign) BOOL autoDismissWhenConfirm;

/// 点击遮罩是否自动消失, default is NO
@property (nonatomic, assign) BOOL dismissWhenTouchMask;

/// 无底部按钮时一段时间后自动消失
@property (nonatomic, assign) BOOL autoDismissWhenNoButton;

/// alertView消失后的回调block
@property (nonatomic, copy) void (^didAutoDismissed)(void);

/// logoImage
@property (nonatomic, strong) UIImage *logoImage;
/// 自定义图片
@property (nonatomic, strong) UIImage *customImage;
@property (nonatomic, assign) CGSize logoImgSize;
@property (nonatomic, assign) CGSize customImgSize;


/// 构造方法
+ (JMCustomAlertView *)alertWithStyle:(AlertStyle)style title:(NSString *)title message:(NSString *)message delegate:(id)delegate buttonTitles:(NSArray<NSString *> *)buttonTitles styleConfig:(JMCustomAlertConfig *)styleConfig;


- (void)show:(BOOL)animated;

- (void)dismiss:(BOOL)animated;

/**
 自定义弹框样式, 更新customView的高

 @param height      customView height
 @param bottomView  约束的参照视图
 @param offsetY     离参照视图的间距
 */
- (void)updateCustomViewHeight:(NSNumber *)height bottomView:(UIView *)bottomView offsetY:(CGFloat)offsetY;

/**
 如果有输入框, 调用此方法来使键盘弹出时alertView自动上移
 */
- (void)addKeyboardNotification;



@end
