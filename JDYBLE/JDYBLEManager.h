//
//  JDYBLEManager.h
//  JDYBLE
//
//  Created by zqf on 16/6/13.
//  Copyright © 2016年 zengqingfu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "JDYBLEMessage.h"

typedef NS_ENUM(NSInteger, PeripheralConnectState) {
    PeripheralConnectStateDidConnectPeripheral = 0,
    PeripheralConnectStateDidFailToConnectPeripheral,
    PeripheralConnectStateDidDisconnectPeripheral,
};

@interface JDYBLEManager : NSObject
+ (NSString *)sdkVersion;

//蓝牙状态
@property (readonly)CBCentralManagerState state;

//以下初始化方法二选一
//初始化之后蓝牙需要两秒左右进行初始化，请间隔两秒调用扫描功能
+ (instancetype)shareInstance;
- (instancetype)initWithQueue:(dispatch_queue_t)queue;

//==============蓝牙相关=============

//监控蓝牙状态改变
//注意：初始化方法调用的时候，会立即触发一次蓝牙状态的反馈
//如果此方法 没 和初始化方法一块使用的话，很可能收不到首次反馈
- (void)setCBCentralStatusChangeBlock:(void (^)(CBCentralManagerState status))block;

//扫描
- (void)scanWithTimeOut:(NSTimeInterval)ti discoverPeripheral:(void (^)(CBPeripheral *peripheral))discoverPeripheralBlock complete:(void (^)(void))scanCompleteBlock;
//停止扫描
-(void)stopScanning;

//连接
- (JDYBLEMessage *)connectPerpheral:(CBPeripheral *)peripheral connectStateChangeBlock:(void (^)(PeripheralConnectState state, NSError *error)) block;
//断开连接
- (void)disConnectBT:(CBPeripheral *)peripheral;

@end
