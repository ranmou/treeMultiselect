//
//  Oamodel.h
//  duoxuan
//
//  Created by Ranmou on 2017/11/15.
//  Copyright © 2017年 Ranmou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Oamodel : NSObject
/**  */
@property (nonatomic,copy) NSString *aliasName;
/**  */
@property (nonatomic,copy) NSString *code;
/** 是否 有 子数组 */
@property (nonatomic,assign) BOOL hasChild;
/**  */
@property (nonatomic,assign) BOOL hasParent;
/** 是否 是部门 */
@property (nonatomic,assign) BOOL isDept;
/** 等级 */
@property (nonatomic,assign) NSInteger level;
/** 名字 */
@property (nonatomic,copy) NSString *name;
/** 下一级 Oamodel 数组 */
@property (nonatomic,strong) NSMutableArray<Oamodel *> *nextNode;
/**  */
@property (nonatomic,copy) NSString *parentCode;

/** 是否 展开 */
@property (nonatomic,assign) BOOL isOpen;
/** 是否 选中 */
@property (nonatomic,assign) BOOL isSelect;


@end
