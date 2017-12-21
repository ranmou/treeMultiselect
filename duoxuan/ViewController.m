//
//  ViewController.m
//  duoxuan
//
//  Created by Ranmou on 2017/11/15.
//  Copyright © 2017年 Ranmou. All rights reserved.
//

#import "ViewController.h"
#import "OaTableViewCell.h"
#import "Oamodel.h"

#define WeakSelf(type)   __weak typeof(type) weak##type = type;
#define kOaTableViewCellId @"OaTableViewCell"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
/** 表视图 */
@property (nonatomic,strong) UITableView *tableView;
/** 提交按钮 */
@property (nonatomic,strong) UIButton *submitBtn;
/** 数据 */
@property (nonatomic,strong) Oamodel *model;
/** 数据 数组 */
@property (nonatomic,strong) NSMutableArray *dataArray;
/** 列表 数组 */
@property (nonatomic,strong) NSMutableArray *tableArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载数据
    NSData *jsonData = [self dataWithPath:@"xx"];
    Oamodel *model = [Oamodel yy_modelWithJSON:jsonData];
    NSLog(@"数据加载完成");
    //临时数据
    model.isOpen = true;
    [self.tableArray addObject:model];
    NSMutableArray *nextNodeArray = [NSMutableArray arrayWithArray:model.nextNode];
    for (Oamodel *nextModel in nextNodeArray) {
        [self.tableArray addObject:nextModel];
    }
    
    [self loadSubmitBtn];
    //初始化TableView
    [self loadTableView];
    
}
#pragma mark--行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableArray.count;
}
#pragma mark--行内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    OaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kOaTableViewCellId];
    if (!cell) {
       cell = [[OaTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kOaTableViewCellId];
    }
    Oamodel *model = self.tableArray[indexPath.row];
    //cell赋值
    [cell setModel:model];
    //选择btn Block
    if (!cell.selectBtnClickedBlock) {
        WeakSelf(self)
        [cell setSelectBtnClickedBlock:^(Oamodel *selectModel, BOOL isSelect) {
            if (isSelect) {//取消 选择
                [weakself deleteDataModel:selectModel];
            }else{//选择
                [weakself addDataModel:selectModel];
                NSLog(@"选择");
            }
            [weakself.tableView reloadData];
        }];
    }
    return cell;
}

//循环遍历父节点修改 取消选中 状态 改为 选中
- (void)addParentCodeType:(Oamodel *)model{
    //判断是否有子节点
    if (model.hasParent) {//有  判断他的 父节点 所有的子是否全为选中状态  是-->选中 不是-->不做处理
        //他的父节点的选中状态
        NSArray *tArray = [NSArray arrayWithArray:self.tableArray];
        for (int i=0; i<tArray.count; i++) {
            Oamodel *tableModel = tArray[i];
            if ([tableModel.code isEqualToString:model.parentCode]) {
                //判断他的 父节点 所有的子是否全为选中状态
                BOOL selse = YES;
                for (Oamodel *subModel in tableModel.nextNode) {
                    
                    if (!subModel.isSelect) {
                        selse = NO;
                    }
                }
                if (selse) {
                    tableModel.isSelect = YES;
                }
                //替换一下
                [self.tableArray replaceObjectAtIndex:i withObject:tableModel];
                [self addParentCodeType:tableModel];
            }
        }
    }else{//没有 不做处理
        
    }
}

#pragma mark---点击 按钮选择
- (void)addDataModel:(Oamodel *)model{
    
    if (model.isDept) {//是 部门
        if (model.hasChild) {//有子节点
            for (Oamodel *nextModel in model.nextNode) {
                [self addDataModel:nextModel];
            }
        }
    }else{//不是 部门
        NSMutableArray *temp = [NSMutableArray arrayWithArray:self.dataArray];
        BOOL nn = NO;
        for (Oamodel *mm in temp) {
            if (mm==model) {
                nn = YES;
            }
        }
        if (!nn) {
            [self.dataArray addObject:model];
        }
    }
    
    //改变本model的isSelect
    NSMutableArray *tablesArray = [NSMutableArray arrayWithArray:self.tableArray];
    for (int i=0; i<tablesArray.count; i++) {
        Oamodel *mm = tablesArray[i];
        if (mm.code==model.code) {
            model.isSelect = YES;
            [tablesArray replaceObjectAtIndex:i withObject:model];
        }
    }
    
    [self.tableArray removeAllObjects];
    [self.tableArray addObjectsFromArray:tablesArray];
    //改变model子节点的isSelect
    [self unSelectModel:model];
    
    //循环遍历父节点修改选中状态
    [self addParentCodeType:model];
    
    
    
}

//循环遍历父节点修改选中状态
- (void)deleteParentCodeType:(Oamodel *)model{
    //判断是否有父节点
    if (model.hasParent) {//有
        //取消他的父节点的选中状态
        NSArray *tArray = [NSArray arrayWithArray:self.tableArray];
        for (int i=0; i<tArray.count; i++) {
            Oamodel *tableModel = tArray[i];
            if ([tableModel.code isEqualToString:model.parentCode]) {
                //替换一下
                tableModel.isSelect = NO;
                [self.tableArray replaceObjectAtIndex:i withObject:tableModel];
                [self deleteParentCodeType:tableModel];
            }
        }
    }else{//没有
        
    }
}
#pragma mark---点击 按钮 取消 全选 改变tableArray的model的isSelect为NO 删除dataArray中的model
- (void)deleteDataModel:(Oamodel *)model{
    //循环遍历父节点修改选中状态
    [self deleteParentCodeType:model];
    if (model.isDept) {//是 部门
        if (model.hasChild) {//有子节点  递归
            for (Oamodel *nextModel in model.nextNode) {
                [self deleteDataModel:nextModel];
            }
        }
    }else{//不是 部门
        [self.dataArray removeObject:model];
    }
    //改变当前cell
    NSMutableArray *tablesArray = [NSMutableArray arrayWithArray:self.tableArray];
    for (int i=0; i<tablesArray.count; i++) {
        Oamodel *mm = tablesArray[i];
        if (mm.code==model.code) {
            model.isSelect = NO;
            [tablesArray replaceObjectAtIndex:i withObject:model];
        }
    }
    [self.tableArray removeAllObjects];
    [self.tableArray addObjectsFromArray:tablesArray];
    //改变model子节点
    [self selectModel:model];
}
#pragma mark---改名model的isSelect为Yes
- (void)unSelectModel:(Oamodel *)model{
    if (model.hasChild) {
        for (Oamodel *ff in model.nextNode) {
            ff.isSelect = YES;
            model = ff;
            [self unSelectModel:ff];
        }
    }else{
        Oamodel *ss = model;
        ss.isSelect = YES;
        model = ss;
    }
}
#pragma mark---改名model的isSelect为NO
- (void)selectModel:(Oamodel *)model{
    if (model.hasChild) {
        for (Oamodel *ff in model.nextNode) {
            ff.isSelect = NO;
            model = ff;
            [self selectModel:ff];
        }
    }else{
        Oamodel *ss = model;
        ss.isSelect = NO;
        model = ss;
    }
}
#pragma maerk - 点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Oamodel *model = self.tableArray[indexPath.row];
    if (!model.isDept||!model.hasChild) {//不是 部门 和 没有 子节点
        return;
    }
    if (model.isOpen) {//是否被打开-->收起
        model.isOpen = !model.isOpen;
        //替换指定下标的元素
        [self.tableArray replaceObjectAtIndex:indexPath.row withObject:model];
        //获取model里的数组
        //删除数据
        [self deleteTableModel:model];
    }else{//打开
        //获取model里的数组
        //插入此cell后
        model.isOpen = !model.isOpen;
        [self.tableArray replaceObjectAtIndex:indexPath.row withObject:model];
        
        for (int i=0; i<model.nextNode.count; i++) {
            Oamodel *nnModel = model.nextNode[i];
            nnModel.isOpen = NO;
            
            [self.tableArray insertObject:nnModel atIndex:indexPath.row+i+1];
        }
        //对比 tableArray和dataArray
        //改变tableArray中model的isSelect为YES
        NSMutableArray *tArray = [NSMutableArray arrayWithArray:self.tableArray];
        NSMutableArray *dArray = [NSMutableArray arrayWithArray:self.dataArray];
        for (int i=0; i<tArray.count; i++) {
            Oamodel *tt = tArray[i];
            for (int j=0; j<dArray.count; j++) {
                Oamodel *dd = dArray[j];
                if (tt.code == dd.code) {
                    tt.isSelect = YES;
                    [self.tableArray replaceObjectAtIndex:i withObject:tt];
                }
            }
        }
    }
    [self.tableView reloadData];
}
#pragma mark---收起 删除
- (void)deleteTableModel:(Oamodel *)model{
    if (model.isDept) {//是部门
        if (!model.hasChild) {//没有子节点 进行 对比 删除
            return;
        }
        //有子节点  分解
        for (Oamodel *nextModel in model.nextNode) {
            [self deleteTableModel:nextModel];
            [self.tableArray removeObject:nextModel];
        }
    }else{//不是 部门
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.tableArray];
        for (Oamodel *nModel in tempArray) {
            if (model == nModel) {
                [self.tableArray removeObject:model];
            }
        }
    }
}
#pragma mark--初始化TableView
- (void)loadTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    //表视图
    _tableView.sd_layout
    .topSpaceToView(self.view,0)
    .leftSpaceToView(self.view,0)
    .rightSpaceToView(self.view,0)
    .bottomSpaceToView(self.submitBtn,20);
}
#pragma mark---初始化提交按钮
- (void)loadSubmitBtn{
    self.submitBtn = [[UIButton alloc]init];
    [self.view addSubview:self.submitBtn];
    self.submitBtn.sd_layout
    .leftSpaceToView(self.view, 40)
    .rightSpaceToView(self.view, 40)
    .bottomSpaceToView(self.view, 20)
    .heightIs(44);
    [self.submitBtn setTitle:@"提交" forState:UIControlStateNormal];
//    [self.submitBtn.titleLabel setTextColor:[UIColor blackColor]];
    [self.submitBtn setBackgroundColor:[UIColor blueColor]];
    [self.submitBtn addTarget:self action:@selector(submitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)submitBtnClicked:(UIButton *)btn{
    NSLog(@"点击提交按钮%ld",self.dataArray.count);
    if (self.dataArray.count==0) {
        return;
    }
    NSString *message = [NSString stringWithFormat:@"您选择的人员是："];
    
    for (int i=0; i<self.dataArray.count; i++) {
        Oamodel *model = self.dataArray[i];
        if (i==0||i==self.dataArray.count) {
            message = [message stringByAppendingString:model.name];
        }else{
            message = [message stringByAppendingString:[NSString stringWithFormat:@",%@",model.name]];
        }
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击确定");
    }];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:^{
        NSLog(@"提交完成");
    }];
    
}
#pragma mark--行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
#pragma mark--头高
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}
#pragma mark--尾高
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}
#pragma mark--加载本地数据
- (NSData *)dataWithPath:(NSString *)path{
    NSString *pathIn = [[NSBundle mainBundle] pathForResource:path ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:pathIn];
    return data;
}
- (NSMutableArray *)tableArray{
    if (!_tableArray) {
        _tableArray = [NSMutableArray array];
    }
    return _tableArray;
}
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
