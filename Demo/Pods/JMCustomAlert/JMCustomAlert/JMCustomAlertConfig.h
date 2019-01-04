//
//  MNCustomAlertConfig.h
//  Meiningjia-Shopkeeper
//
//  Created by 刘轩博 on 2017/11/24.
//  Copyright © 2017年 Baosight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JMCustomAlertConfig : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, strong) UIColor *themeColor;

@property (nonatomic, strong) UIColor *contentColor;

@property (nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic, assign) CGFloat edge;

@property (nonatomic, assign) CGFloat offsetY;

@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, strong) UIImage *arrowImg;

@property (nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *titleTextAttributes;
@property (nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *messageTextAttributes;


+ (JMCustomAlertConfig *)share;



@end
