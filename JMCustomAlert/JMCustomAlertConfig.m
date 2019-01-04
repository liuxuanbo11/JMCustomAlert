//
//  MNCustomAlertConfig.m
//  Meiningjia-Shopkeeper
//
//  Created by 刘轩博 on 2017/11/24.
//  Copyright © 2017年 Baosight. All rights reserved.
//

#import "JMCustomAlertConfig.h"

@implementation JMCustomAlertConfig

+ (JMCustomAlertConfig *)share {
    return [[JMCustomAlertConfig alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.lineColor = [UIColor colorWithRed:225 / 255.0 green:225 / 255.0 blue:225 / 255.0 alpha:1];
        self.themeColor = [UIColor blackColor];
        self.contentColor = [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1];
        self.placeholderColor = [UIColor colorWithRed:153 / 255.0 green:153 / 255.0 blue:153 / 255.0 alpha:1];
        self.edge = 35;
        self.offsetY = 0;
        self.cornerRadius = 5;
        self.arrowImg = [UIImage imageNamed:@"xuanze-diao"];
        
        self.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize:18.0]};
        self.messageTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:50 / 255.0 green:50 / 255.0 blue:50 / 255.0 alpha:1], NSFontAttributeName: [UIFont systemFontOfSize:15.0]};
    }
    return self;
}
@end
