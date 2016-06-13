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

@property (nonatomic, assign, readonly)BOOL canReceiveData;
@property (nonatomic, assign, readonly)BOOL canSendData;

- (void)sendData:(NSData *)data type:(CBCharacteristicWriteType) type sendMessageCompleteBlock:(void (^)(NSError * error))block;
- (void)setReceiveMessageBlock:(void (^)(NSData *data, NSError *error))block;

@end
