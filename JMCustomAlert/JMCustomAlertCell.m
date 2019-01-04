//
//  MNCustomAlertCell.m
//  Meiningjia-Shopkeeper
//
//  Created by 刘轩博 on 2017/11/27.
//  Copyright © 2017年 Baosight. All rights reserved.
//

#import "JMCustomAlertCell.h"
#import "Masonry.h"
@implementation JMCustomAlertCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.leftLabel = [[UILabel alloc] init];
        self.leftLabel.textColor = [UIColor colorWithRed:50 / 255.0 green:50 / 255.0 blue:50 / 255.0 alpha:1];
        self.leftLabel.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:self.leftLabel];
        
        self.rightImg = [[UIImageView alloc] init];
        _rightImg.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_rightImg];
        
        [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(15);
            make.top.bottom.equalTo(self.contentView);
        }];
        
        [self.rightImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-15);
            make.centerY.equalTo(self.contentView);
            make.width.height.equalTo(@17);
        }];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
