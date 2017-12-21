//
//  OaTableViewCell.m
//  duoxuan
//
//  Created by Ranmou on 2017/11/15.
//  Copyright © 2017年 Ranmou. All rights reserved.
//

#import "OaTableViewCell.h"
#import "Oamodel.h"

@interface OaTableViewCell ()

/**  model  Oamodel  model对象 */
@property (nonatomic, strong) Oamodel *tempModel;

@end

@implementation OaTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.titleL = [[UILabel alloc]init];
        self.selectBtn = [[UIButton alloc]init];
        NSArray *views = @[self.titleL,self.selectBtn];
        [self.contentView sd_addSubviews:views];
        
        self.titleL.sd_layout
        .topSpaceToView(self.contentView,10)
        .leftSpaceToView(self.contentView,10)
        .autoHeightRatio(0);
        [self.titleL setSingleLineAutoResizeWithMaxWidth:kScreenWidth-60];
        
        self.selectBtn.sd_layout
        .rightSpaceToView(self.contentView,10)
        .centerYEqualToView(self.contentView)
        .widthIs(25)
        .heightIs(25);
        
        self.titleL.text = @"";
        [self.selectBtn setImage:[UIImage imageNamed:@"unselect"] forState:UIControlStateNormal];
        [self.selectBtn setImage:[UIImage imageNamed:@"select"] forState:UIControlStateSelected];
        
        [self.selectBtn addTarget:self action:@selector(selectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.selectBtn.selected = NO;
    }
    return self;
}
#pragma mark---赋值
- (void)setModel:(Oamodel *)model{
    self.tempModel = model;
    //最后一级不加点击效果
    if (model.isDept) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }else{
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    self.titleL.sd_resetLayout
    .leftSpaceToView(self.contentView,10+model.level*20)
    .topSpaceToView(self.contentView,10)
    .autoHeightRatio(0);
    [self.titleL setSingleLineAutoResizeWithMaxWidth:kScreenWidth-60];
    if (model.isDept) {
        if (model.isOpen) {
            self.titleL.text = [NSString stringWithFormat:@"- %@",model.name];
        }else{
            self.titleL.text = [NSString stringWithFormat:@"+ %@",model.name];
        }
    }else{
        self.titleL.text = [NSString stringWithFormat:@"  %@",model.name];
    }
    if (model.isSelect) {
        self.selectBtn.selected = YES;
    }else{
        self.selectBtn.selected = NO;
    }
}
#pragma mark---点击 按钮
-(void)selectBtnClicked:(UIButton *)btn{
    Oamodel *modelN = self.tempModel;
    if (self.selectBtnClickedBlock) {
        if (btn.selected) {//取消 选中
            self.selectBtnClickedBlock(modelN,true);
        }else{//选中
            self.selectBtnClickedBlock(modelN,false);
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//- (void)layoutSubviews{
//    
//    
//}
//
//- (void)didMoveToSuperview{
//    [super didMoveToSuperview];
//    
//    
//    
//}
@end
