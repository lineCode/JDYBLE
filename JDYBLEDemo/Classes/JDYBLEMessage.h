//
//  JDYBLEMessage.h
//  JDYBLE
//
//  Created by zqf on 16/6/13.
//  Copyright © 2016年 zengqingfu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface JDYBLEMessage : NSObject<CBPeripheralDelegate>
@property (nonatomic,strong, readonly)CBPeripheral *peripheral;

@property (nonatomic, assign, readonly)BOOL canReceiveData;//是否可以接收消息
@property (nonatomic, assign, readonly)BOOL canSendData;//是否可以发送消息

//如果type的类型是CBCharacteristicWriteWithResponse ，消息发送完成之后block会执行，否则block不执行
//实际发送数据过程中发现data超过60个字节之后蓝牙会产生异常，建议超过50个字节的数据进行拆包分批次发送
- (void)sendData:(NSData *)data type:(CBCharacteristicWriteType) type sendMessageCompleteBlock:(void (^)(NSError * error))block;

//监控蓝牙外设发过来的消息
- (void)setReceiveMessageBlock:(void (^)(NSData *data, NSError *error))block;

@end
