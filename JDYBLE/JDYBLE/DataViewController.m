//
//  DataViewController.m
//  JDYBLE
//
//  Created by zqf on 16/6/13.
//  Copyright © 2016年 zengqingfu. All rights reserved.
//

#import "DataViewController.h"
#import "JDYBLEManager.h"

@interface DataViewController ()
@property (weak, nonatomic) IBOutlet UITextField *myTextField;
@property (weak, nonatomic) IBOutlet UITextView *myTextView;

@property (nonatomic, strong) NSMutableString *showStr;
@end

@implementation DataViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showStr = [NSMutableString string];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"断开连接" style:UIBarButtonItemStylePlain target:self action:@selector(disConnectBT)];
    self.navigationItem.rightBarButtonItem = item;
    
    __weak __typeof(self)weakSelf = self;
    [_jdyMessage setReceiveMessageBlock:^(NSData *data, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"接收到消息%@", str);
        [strongSelf.showStr appendString:@"\n"];
        [strongSelf.showStr appendString:str];
        strongSelf.myTextView.text = strongSelf.showStr;
    }];
}

- (void)disConnectBT {
    [[JDYBLEManager shareInstance] disConnectBT:_jdyMessage.peripheral];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendDataAction:(id)sender {
    
    NSString *str = _myTextField.text;
    _myTextField.text = @"";
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    if (_jdyMessage.canSendData) {
        [self.jdyMessage sendData:data type:CBCharacteristicWriteWithoutResponse sendMessageCompleteBlock:^(NSError *error) {
            NSLog(@"发送完成");
        }];
    }

}


@end
