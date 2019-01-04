//
//  ViewController.m
//  Demo
//
//  Created by print on 2019/1/4.
//  Copyright © 2019年 liuxuanbo. All rights reserved.
//

#import "ViewController.h"
#import "JMCustomAlertView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    JMCustomAlertView *alert = [JMCustomAlertView alertWithStyle:AlertStyleNormal title:@"提示" message:@"哈哈哈哈哈" delegate:self buttonTitles:@[@"取消", @"确定"] styleConfig:nil];
    [alert show:YES];
}


@end
