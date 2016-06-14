//
//  FirstViewController.m
//  JDYBLE
//
//  Created by zqf on 16/6/13.
//  Copyright © 2016年 zengqingfu. All rights reserved.
//

#import "FirstViewController.h"
#import "JDYBLEManager.h"
#import "DataViewController.h"

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableDictionary *dic;

@property (weak, nonatomic) IBOutlet UIView *acView;

@property (nonatomic, strong)JDYBLEManager *jdyBLEmanager;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArr = [NSMutableArray array];
    self.dic = [NSMutableDictionary dictionary];
    
    self.jdyBLEmanager = [JDYBLEManager shareInstance];
    [_jdyBLEmanager setCBCentralStatusChangeBlock:^(CBCentralManagerState status) {
        NSLog(@"蓝牙状态改变= %ld", (long)status);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startScanAction:(id)sender {
    [[JDYBLEManager shareInstance] scanWithTimeOut:30 discoverPeripheral:^(CBPeripheral *peripheral) {
        NSLog(@"%@", peripheral);
        [self dataArrAddobject:peripheral];
        
    } complete:^{
        NSLog(@"扫描结束");
    }];
}

- (void)dataArrAddobject:(id)object {
    
    if ([_dataArr indexOfObject:object] == NSNotFound) {
        [_myTableView beginUpdates];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dataArr.count inSection:0];
        [_dataArr addObject:object];
        [_myTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [_myTableView endUpdates];
    }
    

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *idStr = @"defaultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idStr];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idStr];
    }
    
    CBPeripheral *peripheral = _dataArr[indexPath.row];
    NSString *name = peripheral.name;
    if (name == nil) {
        name = @"Unknown";
    }
    cell.textLabel.text = name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.acView.hidden = NO;
    
    [_jdyBLEmanager stopScanning];
    
    CBPeripheral *peripheral = _dataArr[indexPath.row];
    __weak __typeof(self)weakSelf = self;
    JDYBLEMessage *jdyMessage = [_jdyBLEmanager connectPerpheral:peripheral connectStateChangeBlock:^(PeripheralConnectState state, NSError *error) {
        NSLog(@"连接状态：%ld", (long)state);
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.acView.hidden = YES;
        
        if (state == PeripheralConnectStateDidConnectPeripheral){
            
            JDYBLEMessage *jdyMessage = [strongSelf.dic objectForKey:peripheral];
            DataViewController *vc = [[DataViewController alloc] init];
            vc.jdyMessage = jdyMessage;
            [strongSelf.navigationController pushViewController:vc animated:YES];
            
        }else if (state == PeripheralConnectStateDidDisconnectPeripheral){
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
    [self.dic setObject:jdyMessage forKey:peripheral];
}


@end
