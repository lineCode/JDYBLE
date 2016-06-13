//
//  DataViewController.m
//  JDYBLE
//
//  Created by zqf on 16/6/13.
//  Copyright © 2016年 zengqingfu. All rights reserved.
//

#import "DataViewController.h"

@interface DataViewController ()
@property (weak, nonatomic) IBOutlet UITextField *myTextField;
@property (weak, nonatomic) IBOutlet UITextView *myTextView;

@property (nonatomic, strong) NSMutableString *showStr;
@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    __weak __typeof(self)weakSelf = self;
    
    self.showStr = [NSMutableString string];
    [_jdyMessage setReceiveMessageBlock:^(NSData *data, NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"接收到消息%@", str);
        [strongSelf.showStr appendString:@"\n"];
        [strongSelf.showStr appendString:str];
        strongSelf.myTextView.text = strongSelf.showStr;
    }];
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
        [self.jdyMessage sendData:data type:CBCharacteristicWriteWithResponse sendMessageCompleteBlock:^(NSError *error) {
            NSLog(@"发送完成");
        }];
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
