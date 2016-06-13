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


@property (nonatomic, strong)JDYBLEManager *jdyBLEmanager;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArr = [NSMutableArray array];
    
    self.jdyBLEmanager = [JDYBLEManager shareInstance];
    [_jdyBLEmanager setCBCentralStatusChangeBlock:^(CBCentralManagerState status) {
        NSLog(@"蓝牙状态改变= %ld", status);
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
    [_myTableView beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dataArr.count inSection:0];
    [_dataArr addObject:object];
    [_myTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [_myTableView endUpdates];
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
    CBPeripheral *peripheral = _dataArr[indexPath.row];
    
    JDYBLEMessage *jdyMessage = [_jdyBLEmanager connectPerpheral:peripheral connectStateChangeBlock:^(PeripheralConnectState state, NSError *error) {
        NSLog(@"连接状态：%ld", state);
    }];
    
    [_jdyBLEmanager stopScanning];
    
    DataViewController *vc = [[DataViewController alloc] init];
    vc.jdyMessage = jdyMessage;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)nextVC {
    
}

@end
