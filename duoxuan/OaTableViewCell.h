//
//  OaTableViewCell.h
//  duoxuan
//
//  Created by Ranmou on 2017/11/15.
//  Copyright © 2017年 Ranmou. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Oamodel;

@interface OaTableViewCell : UITableViewCell
/**  titleL  UILabel  标题 */
@property (nonatomic, strong) UILabel *titleL;
/**  selectBtn  UILabel  选择按钮 */
@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) Oamodel *model;

/** 点击 选择 按钮 返回 model */
@property(nonatomic,copy) void (^selectBtnClickedBlock)(Oamodel *selectModel ,BOOL isSelect);

@end
