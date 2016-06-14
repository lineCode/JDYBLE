//
//  JDYBLEManager.m
//  JDYBLE
//
//  Created by zqf on 16/6/13.
//  Copyright © 2016年 zengqingfu. All rights reserved.
//
//sdk版本号
#define JDYBLE_VERSION @"0.0.2";

#import "JDYBLEManager.h"

@interface JDYBLEModel : NSObject
@property (nonatomic, strong)JDYBLEMessage *message;
@property (nonatomic, copy)void (^connectStateChangeBlock)(PeripheralConnectState state, NSError *error);
- (void)connectStateChangeWithState:(PeripheralConnectState) state error:(NSError *)error;
@end
@implementation JDYBLEModel
- (void)connectStateChangeWithState:(PeripheralConnectState) state error:(NSError *)error {
    if (_connectStateChangeBlock) {
        _connectStateChangeBlock(state, error);
    }
}
@end


@interface JDYBLEManager()<CBCentralManagerDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSMutableDictionary *per2messageDic;

//---state----
@property (nonatomic) BOOL isScanning;

//----block----
@property (nonatomic, copy)void (^centralStatusChangeBlock)(CBCentralManagerState status);
@property (nonatomic, copy)void (^scanCompleteBlock)(void);
@property (nonatomic, copy)void (^discoverPeripheralBlock)(CBPeripheral *peripheral);
@end


@implementation JDYBLEManager

- (CBCentralManagerState)state {
    return self.centralManager.state;
}
+ (NSString *)sdkVersion {
    return  JDYBLE_VERSION;
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static id shareInstance = nil;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
        [shareInstance setupVarWithQueue:nil];
    });
    return shareInstance;
}

- (instancetype)initWithQueue:(nullable dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        [self setupVarWithQueue:queue];
    }
    return self;
}

- (void)setupVarWithQueue:(nullable dispatch_queue_t)queue {
    self.per2messageDic = [NSMutableDictionary dictionary];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue];
}

- (void)setCBCentralStatusChangeBlock:(void (^)(CBCentralManagerState status))block {
    self.centralStatusChangeBlock = block;
}

- (void)scanWithTimeOut:(NSTimeInterval)ti discoverPeripheral:(void (^)(CBPeripheral *peripheral))discoverPeripheralBlock complete:(void (^)(void))scanCompleteBlock{
    self.discoverPeripheralBlock = discoverPeripheralBlock;
    self.scanCompleteBlock = scanCompleteBlock;
    [self startScanning];
    if (ti > 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopScanning) object:nil];
        [self performSelector:@selector(stopScanning) withObject:nil afterDelay:ti];
    }
}

- (void)startScanning {
    BOOL isBTPoweredOn = (self.centralManager.state == CBCentralManagerStatePoweredOn);
    if (!isBTPoweredOn || _isScanning) return;
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    self.isScanning = YES;
}

-(void)stopScanning {
    if(!_isScanning) return;
    [self.centralManager stopScan];
    self.isScanning = NO;
    if (_scanCompleteBlock) {
        _scanCompleteBlock();
    }
}

//连接
- (JDYBLEMessage *)connectPerpheral:(CBPeripheral *)peripheral connectStateChangeBlock:(void (^)(PeripheralConnectState state, NSError *error)) block {
    if (!peripheral) {
        return nil;
    }
    static NSString *peripheralStr = @"peripheral";
    JDYBLEModel *model = [_per2messageDic objectForKey:peripheral];
    JDYBLEMessage *message = nil;
    if (!model) {
        model = [[JDYBLEModel alloc] init];
        message = [[JDYBLEMessage alloc] init];
        [message setValue:peripheral forKey:peripheralStr];
        model.message = message;
        [_per2messageDic setObject:model forKey:peripheral];
    } else {
        message = model.message;
    }
    model.connectStateChangeBlock = block;
    [_centralManager connectPeripheral:peripheral options:nil];
    return message;
}

- (void)disConnectBT:(CBPeripheral *)peripheral {
    [_centralManager cancelPeripheralConnection:peripheral];
}

#pragma mark --delegate--
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (_centralStatusChangeBlock) {
        _centralStatusChangeBlock(central.state);
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (_discoverPeripheralBlock) {
        _discoverPeripheralBlock(peripheral);
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    JDYBLEModel *model = [_per2messageDic objectForKey:peripheral];
    [model connectStateChangeWithState:PeripheralConnectStateDidConnectPeripheral error:nil];
    JDYBLEMessage *message = model.message;
    peripheral.delegate = message;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL foundService = NSSelectorFromString(@"foundService");
    [message performSelector:foundService];
#pragma clang diagnostic pop
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    JDYBLEModel *model = [_per2messageDic objectForKey:peripheral];
    [model connectStateChangeWithState:PeripheralConnectStateDidFailToConnectPeripheral error:error];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    JDYBLEModel *model = [_per2messageDic objectForKey:peripheral];
    [model connectStateChangeWithState:PeripheralConnectStateDidDisconnectPeripheral error:error];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL whenDisconnectBT = NSSelectorFromString(@"whenDisconnectBT");
    [model.message performSelector:whenDisconnectBT];
#pragma clang diagnostic pop
}


@end



