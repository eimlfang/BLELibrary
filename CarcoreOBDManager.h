//
//  CarcoreOBD.h
//  CarcoreBTTest
//
//  Created by Besprout's Mac Mini on 15/5/19.
//  Copyright (c) 2015年 Fang Zijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CarcoreOBDPrefix.h"
#import "OBDConfig.h"
#import <UIKit/UIKit.h>
#import "CarCheckUpItem.h"

extern NSString *const OBD_INIT_DONE;
extern NSString *const OBD_DISCONNECT;

@protocol CarcoreOBDManagerDelegate <NSObject>
@optional
- (void)carcoreScanningOBDDevice;
- (void)carcoreDidDiscoverOBDDevice;
- (void)carcoreDidConnectOBDDevice;
- (void)carcoreDidDisconnectOBDDevice;
- (void)carcoreDidDiscoverCharacteristicsForService:(CBService *)service;
- (void)carcoreDidUpdateCharacteristicsValue:(CBCharacteristic *)characteristic;
/// OBD行为日志
- (void)carcoreActionLog:(NSString *)log;
/// OBD连接状态改变
- (void)carcoreOBDStateChanged:(OBDConnectState)state;
/// OBD动作错误返回
- (void)carcoreOBDError:(NSString *)error errorCode:(OBDError)errorCode;

- (void)carcoreOBDReceiveValue:(id)value command:(NSString *)command;

//- (void)carcoreDidFindOBDDevice;
@end

/// CarcoreOBD管理类
@interface CarcoreOBDManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate,UIAlertViewDelegate>
{
    BOOL _isConnected;
    dispatch_source_t _carParameterTimer;
    NSMutableString *_bleTempString;
    BOOL _unableToConnectCount;
    NSString *_currentSendCode;
    
    NSUserDefaults *_userDefault;
}

@property (assign, nonatomic) int obdConnectFailCount;

@property (assign, nonatomic) BOOL isBluetoothAvaliable;

@property (nonatomic, strong) NSString *tempCode;
@property (assign, nonatomic) BOOL haveFaultCode;
@property (assign, nonatomic) BOOL readFaultDetail;
@property (assign, nonatomic) BOOL needReadFaultDetail;
@property (assign, nonatomic) BOOL isReadFaultDetailEnd;
@property (assign, nonatomic) BOOL isSentFaultCode;
@property (assign, nonatomic) BOOL readFaultAgreement;
@property (assign, nonatomic) BOOL is15765Agreement;
@property (strong, nonatomic) NSMutableString *tempErrorCodeString;

@property (nonatomic, strong) NSTimer *transferTimeoutTimer;

@property (nonatomic, strong) NSThread *obdTransferThread;
@property (nonatomic, strong) NSCondition *obdTransferCondition;
@property (nonatomic, readonly) NSMutableArray *tempCommands;
@property (nonatomic, readonly) OBDConfig *obdConfig;
@property (nonatomic, readonly) NSInteger sendInitCommand;
@property (nonatomic, readonly) NSInteger sendTransferCommandIdx;
@property (assign, nonatomic) id<CarcoreOBDManagerDelegate> delegate;
@property (readonly, nonatomic) OBDActionType actionType;
@property (readonly, nonatomic) OBDConnectState connectState;
@property (readonly, nonatomic) BOOL transferReady;
@property (readonly, nonatomic) BOOL isInitializeDone;

@property (assign, nonatomic) BOOL isCustomItemChecking;

// 车辆是否支持进气流量表示
@property (assign, nonatomic) BOOL isNoSupportIntaskFlow;

@property (strong, readonly, nonatomic) CBCentralManager *centralManager;
@property (strong, readonly, nonatomic) CBPeripheral *discoveredPeripheral;
@property (strong, readonly, nonatomic) CBService *targetService;
@property (strong, readonly, nonatomic) CBCharacteristic *targetCharacteristic;
@property (strong, nonatomic) CBCharacteristic *rxCharacteristic;
@property (strong, nonatomic) CBCharacteristic *txCharacteristic;
@property (strong, nonatomic) CBCharacteristic *airCharacteristic;
@property (strong, nonatomic) CBCharacteristic *updateCharacteristic;

/// OBD服务
@property (strong, nonatomic) CBService *obdService;

+ (instancetype)sharedManager;

/// 所有体检项目
- (NSArray *)allCheckUpItems;
/// 体检项目
- (NSArray *)carCheckUpCommands;
/// 重设体检项目
- (void)setCarCheckUpItems:(NSString *)itemsStr;
/// 重新连接OBD
- (void)reconnect;
/// 扫描OBD设备
- (void)scanOBDDevice;
/// 断开设备连接
- (void)cancelConnectDevice;
/// 重新开始发送数据
- (void)restartTransfer;
/// 写入数据到OBD
- (BOOL)writeValue:(NSString *)code;

#pragma mark - OBD方法
// 修改命令内容
- (void)setTransferCommandType:(OBDCommandContain)contain;

/// 初始化OBD
- (void)OBDDriverInitialize;
/// 接收失败后重新初始化设备
- (void)OBDDriverReInitialize;
///// 获得车速
//- (void)getSpeed;
///// 获得引擎负荷
//- (void)getEngineLoad;
///// 获得进气流量
//- (void)getIntakeFlow;
@end


