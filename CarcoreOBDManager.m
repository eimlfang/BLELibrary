//
//  CarcoreOBD.m
//  CarcoreBTTest
//
//  Created by Besprout's Mac Mini on 15/5/19.
//  Copyright (c) 2015年 Fang Zijian. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CarcoreOBDManager.h"
#import "CarcoreDataManager.h"
#import "NSString+BPCategory.h"

NSString *const OBD_INIT_DONE = @"OBD_INIT_DONE";
NSString *const OBD_DISCONNECT = @"OBD_DISCONNECT";

const dispatch_source_t timer = nil;

static int tAlert_BluetoothSetting = 1101;

@interface CarcoreDataManager()
{
}
@end

@implementation CarcoreOBDManager

- (void)dealloc
{
}

+ (instancetype)sharedManager {
    static CarcoreOBDManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //        _tempCommands = [[NSMutableArray alloc] init];
        //        _obdConfig = [[OBDConfig alloc] init];
        //        _obdTransferThread = [[NSThread alloc] initWithTarget:self selector:@selector(obdTransferAction) object:nil];
        //        _obdTransferCondition = [[NSCondition alloc] init];
        //        _bleTempString = [[NSMutableString alloc] init];
        //        [self initVar];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogoutAction) name:kUsersLogout object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginAction) name:kUsersLogin object:nil];
    }
    return self;
}


- (void)initVar
{
    if (_tempCommands) {
        [_tempCommands removeAllObjects];
        _tempCommands = nil;
    }
    _tempCommands = [[NSMutableArray alloc] init];
    if (_obdConfig) {
        _obdConfig = nil;
    }
    _obdConfig = [[OBDConfig alloc] init];
    if (_obdTransferThread) {
        _obdTransferThread = nil;
    }
    _obdTransferThread = [[NSThread alloc] initWithTarget:self selector:@selector(obdTransferAction) object:nil];
    if (_obdTransferCondition) {
        _obdTransferCondition = nil;
    }
    _obdTransferCondition = [[NSCondition alloc] init];
    if (_bleTempString) {
        _bleTempString = nil;
    }
    _bleTempString = [[NSMutableString alloc] init];
}

- (BOOL)receiveDataType:(NSString *)header equalTo:(NSString *)command
{
    return ([header rangeOfString:command].location != NSNotFound);
    
    //    OBDActionType receiveDataType = OBDActionTypeNone;
    //    if ([header rangeOfString:C_CAR_SPEED].location != NSNotFound) {
    //        receiveDataType = OBDActionTypeGetSpeed;
    //    }else if ([header rangeOfString:C_ENGINE_LOAD].location != NSNotFound) {
    //        receiveDataType = OBDActionTypeGetEngineLoad;
    //    }
    //    else if ([header rangeOfString:C_INTAKE_FLOW].location != NSNotFound) {
    //        receiveDataType = OBDActionTypeIntakeFlow;
    //    }
    
    /*
     else if ([header rangeOfString:C_FUEL_CONSUMPTION].location != NSNotFound) {
     receiveDataType = OBDActionTypeGetFuelConsumption;
     }
     */
    //    return receiveDataType;
}

- (NSArray *)allCheckUpItems
{
    NSMutableArray *arr = [NSMutableArray array];
    
    [arr addObjectsFromArray:[self.obdConfig vehicleInspectionItemsLibrary]];
    return arr;}

- (NSArray *)carCheckUpCommands
{
    NSMutableArray *arr = [NSMutableArray array];
    
    [arr addObjectsFromArray:[self.obdConfig carCheckUpSelectedLibrary]];
    return arr;
}

- (void)setCarCheckUpItems:(NSString *)itemsStr
{
    [AppContants addValue:itemsStr forKey:kCAR_CHECKUP_ITEMS];
    [self.obdConfig resetCarCheckUpSelectedLibrary];
}

#pragma mark - Property

- (NSTimer *)transferTimeoutTimer
{
    if (!_transferTimeoutTimer) {
        _transferTimeoutTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(transferTimeoutHandler) userInfo:nil repeats:YES];
    }
    return _transferTimeoutTimer;
}

#pragma mark - Call Delegate
- (void)callbackChangeUpdate:(OBDConnectState)state
{
    _connectState = state;
    if (state == OBDConnectStateInitialize) {
        _unableToConnectCount = 0;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(carcoreOBDStateChanged:)]) {
        [self.delegate carcoreOBDStateChanged:state];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"carcoreOBDStateChanged" object:[NSNumber numberWithInteger:state]];
}
- (void)errorCallbackWithError:(NSString *)error code:(OBDError)errorCode
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(carcoreOBDError:errorCode:)]) {
        [self.delegate carcoreOBDError:error errorCode:errorCode];
    }
}

- (void)logCallbackWithLog:(NSString *)log
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(carcoreActionLog:)]) {
        [self.delegate carcoreActionLog:log];
    }
}

- (void)dataCallbackWithValue:(id)value command:(NSString *)command
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(carcoreOBDReceiveValue:command:)]) {
        [self.delegate carcoreOBDReceiveValue:value command:command];
    }
}
#pragma mark - Notification

- (void)userLoginAction
{
    [self scanOBDDevice];
}

- (void)userLogoutAction
{
    //    [self.obdTransferCondition wait];
    //    [self cleanup];
    if (self.discoveredPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
    }
}


#pragma mark - 蓝牙动作
/// 扫描OBD设备
- (void)scanOBDDevice
{
    [self cleanup];
    [self initVar];
    if (!_centralManager) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }else{
        
        [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
    }
    _connectState = OBDConnectStateSearching;
    [self callbackChangeUpdate:OBDConnectStateSearching];
    //    [self startTimeoutTimer];
}
/// 断开设备连接
- (void)cancelConnectDevice
{
    [self cancelConnect];
}

- (BOOL)writeValue:(NSString *)code
{
    if (code == nil || [code length] <= 0) {
        NSLog(@"writeValue: code == nil || code length <= 0");
        return NO;
    }
    if ([code isEqualToString:@"Instant_Fuel_Consumption"]) {
        //        [self loopOBDTransfer];
        code = C_INTAKE_FLOW;
    }
    _currentSendCode = code;
    if (self.rxCharacteristic == nil || self.discoveredPeripheral == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请连接蓝牙并扫描服务" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    if ([code hasPrefix:@"01"]) {
        if (([code isEqualToString:@"0100"] == NO) && ([code isEqualToString:@"0101"] == NO)) {
            code = [NSString stringWithFormat:@"%@1",code];
        }
    }
    
    code = [NSString stringWithFormat:@"%@\r",code];
    NSData *writeData = [code dataUsingEncoding:NSUTF8StringEncoding];
    
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    //
    //    dispatch_async(queue, ^{
    CBCharacteristicWriteType writeType = CBCharacteristicWriteWithResponse;
    if (self.rxCharacteristic.properties ==  CBCharacteristicPropertyWriteWithoutResponse){
        writeType = CBCharacteristicWriteWithoutResponse;
    }
    
    [self.discoveredPeripheral writeValue:writeData forCharacteristic:self.rxCharacteristic type:writeType];
    //    if (self.transferTimeoutTimer.valid) {
    //        [self.transferTimeoutTimer invalidate];
    //    }
    [[NSRunLoop mainRunLoop] addTimer:self.transferTimeoutTimer forMode:NSDefaultRunLoopMode];
    //    });
    return YES;
}

#pragma mark - Timer handler
- (void)transferTimeoutHandler
{
    NSLog(@"传输%@超时",_currentSendCode);
    return;
    _bleTempString =[NSMutableString stringWithFormat:@""];
    if (_isInitializeDone) {
        [self loopOBDTransfer];
    }else{
        
    }
}

#pragma mark - OBD行为

- (void)cancelConnect
{
    [self cleanup];
}

/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup
{
    _transferReady = NO;
    _isInitializeDone = NO;
    _sendInitCommand = 0;
    _unableToConnectCount = 0;
    _actionType = OBDActionTypeNone;

    [self.transferTimeoutTimer invalidate];
    if (_carParameterTimer) {
        dispatch_source_cancel(_carParameterTimer);
    }
    if (_obdTransferCondition) {
        _obdTransferCondition = nil;
    }
    if (_obdTransferThread) {
        _obdTransferThread = nil;
    }
    
    if ([CarcoreDataManager sharedManager].currentTrackInfo) {
        [[CarcoreDataManager sharedManager] tripEnd];
    }
    
    [self callbackChangeUpdate:OBDConnectStateDisconnect];
    
    // Don't do anything if we're not connected
    if (self.discoveredPeripheral == nil) {
        return;
    }
    if (!self.discoveredPeripheral.state == CBPeripheralStateDisconnected) {
        // And we're done.
        return;
    }
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
    
    // See if we are subscribed to a characteristic on the peripheral
    //    if (self.discoveredPeripheral.services != nil) {
    //        for (CBService *service in self.discoveredPeripheral.services) {
    //            if (service.characteristics != nil) {
    //                for (CBCharacteristic *characteristic in service.characteristics) {
    //                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ISSC_TRANS_TX]]) {
    //                        if (characteristic.isNotifying) {
    //                            // It is notifying, so unsubscribe
    //                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
    //                            return;
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}

- (void)reconnect
{
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
    //    [self cleanup];
    _centralManager = nil;
    [self scanOBDDevice];
}

- (void)discoverCharacteristicsForService:(CBService *)service
{
    [self.discoveredPeripheral discoverCharacteristics:nil forService:service];
}

- (void)setTransferCommandType:(OBDCommandContain)contain
{
    [self.obdConfig setCommandContain:contain];
}

#pragma mark 获取数据
- (void)OBDDriverInitialize
{
    [[TitleMessageBox instance] showMessage:@"正在连接设备中..." autoDismiss:NO];
    
    if (self.transferReady == NO) {
        [self reconnect];
    }
    
    _actionType = OBDActionTypeBasicInitialize;
    [_tempCommands removeAllObjects];
    [_tempCommands addObjectsFromArray:[OBDConfig initializeCommands]];
    
    [self performSelector:@selector(loopSendInitCode) withObject:nil afterDelay:2.0f];
    
    //    [self loopSendInitCode];
}

- (void)loopSendInitCode
{
    if (_obdConnectFailCount >= 5) {
        if (self.centralManager) {
            //            self.centralManager
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接失败" message:@"请检查手机蓝牙是否开启并重新拔插OBD设备并点击连接" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"连接", nil];
            alert.tag = 10010;
            [alert show];
            
            [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
        }
        return;
    }
    
    if (_tempCommands.count < 1) {
        [_tempCommands addObjectsFromArray:[OBDConfig initializeCommands]];
    }
    if (_sendInitCommand >= [_tempCommands count]) {
        _obdConnectFailCount ++;
        _sendInitCommand = 0;
    }
    if (_sendInitCommand == 0) {
        //        [NSThread sleepForTimeInterval:1.0f];
    }
    
    NSString *initializeCommand = _tempCommands[_sendInitCommand];
    NSLog(@"%@",[NSString stringWithFormat:@"发送初始化指令:%@",initializeCommand]);
    [self writeValue:initializeCommand];
    _sendInitCommand++;
    if (_sendInitCommand >= _tempCommands.count) {
        _sendInitCommand = 0;
    }
}

- (void)OBDDriverReInitialize
{
    _sendInitCommand = 0;
    [self OBDDriverInitialize];
}

- (void)getCarAgreement
{
    
}

//- (void)getSpeed
//{
//    if (_transferReady == NO) {
//        [self reconnect];
//    }
//    _actionType = OBDActionTypeGetSpeed;
//    NSString *speedCommand = [CarcoreDataManager obdQuickCommand:C_CAR_SPEED];
//    [self writeValue:speedCommand];
//}
//
//- (void)getEngineLoad
//{
//    if (_transferReady == NO) {
//        [self reconnect];
//    }
//    _actionType = OBDActionTypeGetEngineLoad;
//    NSString *speedCommand = [CarcoreDataManager obdQuickCommand:C_ENGINE_LOAD];//[NSString stringWithFormat:@"%@1",C_ENGINE_LOAD];
//    [self writeValue:speedCommand];
//}
//
//- (void)getIntakeFlow
//{
//    if (_transferReady == NO) {
//        [self reconnect];
//    }
//    _actionType = OBDActionTypeIntakeFlow;
//    NSString *speedCommand = [CarcoreDataManager obdQuickCommand:C_INTAKE_FLOW];
//
//    [self writeValue:speedCommand];
//}

#pragma mark - 长连接线程
dispatch_source_t CreateCarStatusDispatchTimer(double interval, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

- (void)obdTransferStart
{
    if (!_obdTransferThread) {
        _obdTransferThread = [[NSThread alloc] initWithTarget:self selector:@selector(obdTransferAction) object:nil];
    }
    if (_obdTransferThread.executing == NO) {
        [self.obdTransferThread start];
    }else{
        [self.obdTransferCondition signal];
    }
    
}

/// 开始通信
- (void)obdTransferAction
{
    [_obdTransferCondition lock];
    _sendTransferCommandIdx = 0;
    _actionType = OBDActionTypeAbleTransfer;
    [self loopOBDTransfer];
    //    while (YES) {
    //        NSString *quickCommand;
    //        if (self.needReadFaultDetail == YES) {
    //            commandIndex = 0;
    //                // 检测到故障
    //            quickCommand = C_FAULT_DETAIL_READING;
    //            if (self.isSentFaultCode == NO) {
    //                [NSThread sleepForTimeInterval:1.0f];
    //
    //                [self writeValue:quickCommand];
    //                self.isSentFaultCode = YES;
    //            }
    //
    //        }else{
    ////            if ([CarcoreDataManager sharedManager].currentTrackInfo == nil) {
    ////                // 转速为0，发动机未点火
    ////                NSString *quickCommand = [CarcoreDataManager obdQuickCommand:C_ENGINE_RPM];
    //////                quickCommand = [CarcoreDataManager obdQuickCommand:C_FAULT_CODE_READING];
    ////
    ////                [self writeValue:quickCommand];
    ////                commandIndex = 0;
    ////            }else{
    //                // 转速不为0,发动机点火
    //                if (commandIndex >= [[self.obdConfig transferCommands] count]) {
    //                    commandIndex = 0;
    //                }
    //                NSString *command = [self.obdConfig transferCommands][commandIndex];
    //                quickCommand = [CarcoreDataManager obdQuickCommand:command];
    //
    //                [self writeValue:quickCommand];
    //
    //                commandIndex++;
    ////            }
    //
    //            [NSThread sleepForTimeInterval:0.2f];
    //            [self.obdTransferCondition wait];
    //
    //            if (self.transferReady == NO || self.readFaultDetail == YES) {
    //                [self.obdTransferCondition wait];
    //            }
    //
    //        }
    //
    //    }
    [_obdTransferCondition unlock];
}

- (void)restartTransfer
{
    _sendTransferCommandIdx = 0;
    
    // TODO: 开启loopOBD，会产生错误 ,不开启，无法继续传输
    [self loopOBDTransfer];
}

- (void)loopOBDTransfer
{
    [self.transferTimeoutTimer invalidate];
    
    NSString *quickCommand;
    BOOL isWirteSuccess = NO;
    
    if (self.needReadFaultDetail == YES) {
        
        // 先判断是否读取错误协议
        if (self.readFaultAgreement == NO) {
            // 先读取错误协议
            isWirteSuccess = [self writeValue:C_FAULT_AGREEMENT];
        }else{
            // 错误协议读取完毕
            _sendTransferCommandIdx = 0;
            // 检测到故障
            quickCommand = C_FAULT_DETAIL_READING;
            if (self.isSentFaultCode == NO) {
                
                isWirteSuccess = [self writeValue:quickCommand];
                self.isSentFaultCode = YES;
            }
        }
    }else{
        if (_sendTransferCommandIdx >= [[self.obdConfig transferCommands] count]) {
            _sendTransferCommandIdx = 0;
        }
        NSString *command = [[self.obdConfig transferCommands] safe_objectAtIndex:_sendTransferCommandIdx];
        quickCommand = [CarcoreDataManager obdQuickCommand:command];
        
        if ([quickCommand isEqualToString:@"(null)"] == NO) {
            isWirteSuccess = [self writeValue:quickCommand];
        }else{
            isWirteSuccess = YES;
        }
        
        _sendTransferCommandIdx++;
    }
    if (isWirteSuccess == NO) {
        [self loopOBDTransfer];
    }
}

- (void)obdTransferStop
{
    //    [self.obdTransferThread cancel];
    //    [self.obdTransferCondition wait];
}

- (void)carPramaterThreadStart
{
    [[TitleMessageBox instance] showMessage:@"已连接到设备" autoDismiss:YES];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    double secondsToFire = 1.800f;
    
    _carParameterTimer = CreateCarStatusDispatchTimer(secondsToFire, queue, ^{
        //        [self getSpeed];
        //        [self getIntakeFlow];
        // 获取当前时间车速计算里程
        [[CarcoreDataManager sharedManager] getMileage];
        if ([CarcoreDataManager sharedManager].currentTrackInfo) {
            [[CarcoreDataManager sharedManager] getCurrentLocation];
        }
    });
}



- (void)carParamaterThreadPause
{
    dispatch_suspend(_carParameterTimer);
}

#pragma mark - OBD Code Library
- (NSDictionary *)selectorsForOBDCode{
    NSDictionary* handleMap = @{
                                C_CAR_SPEED : NSStringFromSelector(@selector(analysisSpeedWithData:)),
                                C_ENGINE_RPM : NSStringFromSelector(@selector(analysisEngineRPMWithData:)),
                                C_ENGINE_LOAD : NSStringFromSelector(@selector(analysisEngineLoadWithData:)),
                                C_INTAKE_FLOW : NSStringFromSelector(@selector(analysisIntaskFlowWithData:)),
                                C_ENGINE_RUNTIME : NSStringFromSelector(@selector(analysisEngineRuntimeWithData:)),
                                C_ENGINE_COOLANT_TEMP : NSStringFromSelector(@selector(analysisEngineCoolantTempWithData:)),
                                C_INTAKE_AIR_TEMP : NSStringFromSelector(@selector(analysisIntaskAirTempWithData:)),
                                C_THROTTLE : NSStringFromSelector(@selector(analysisThrottleWithData:)),
                                C_INTAKE_AIR_PRESURE : NSStringFromSelector(@selector(analysisIntaskAirPresureWithData:)),
                                C_FAULT_CODE_READING : NSStringFromSelector(@selector(analysisFaultCodeWithData:::)),
                                CATALYST_TEMP_B1S1 : NSStringFromSelector(@selector(analysisCatalystTempB1s1WithData:)),
                                };
    return handleMap;
}

#pragma mark - 分析获取数据
- (void)exceptionValueHandler:(NSString *)value
{
//    NSLog(@"send:%@",_currentSendCode);
    if ([_currentSendCode isEqualToString:C_INTAKE_FLOW]) {
        // 进气量读取错误
        if ([CarcoreDataManager sharedManager].obd_engineRPM != 0) {
            self.isNoSupportIntaskFlow = YES;
            
            if ([CarcoreDataManager sharedManager].obd_intaskAirTemp != 0 && [CarcoreDataManager sharedManager].obd_intaskAirPresure != 0) {
                [CarcoreDataManager sharedManager].obd_airIntask = @(0.029*[[CarcoreDataManager sharedManager].obd_engineRPM floatValue]*1.6*[[CarcoreDataManager sharedManager].obd_intaskAirPresure floatValue]/([[CarcoreDataManager sharedManager].obd_intaskAirTemp floatValue]+273.15));
            }
        }
    }else if ([_currentSendCode isEqualToString:C_HEALTH_BATTERY_VOLTAGE])
    {
        [self analysisBatteryVoltageWithData:value :@"car_batteryVoltage" :C_HEALTH_BATTERY_VOLTAGE ];
    }
}

- (void)analysisInitializeWithData:(NSString *)value
{
    
    @try {
        //    if (self.transferTimeoutTimer.valid) {
        [self.transferTimeoutTimer invalidate];
        //    }
        if (value.length > 4) {
            
            if ([value isContainString:@"SEARCHING..."]) {
                NSRange searchingRange = [value rangeOfString:@"SEARCHING..."];
                value = [value substringWithRange:NSMakeRange(searchingRange.length, value.length - searchingRange.length)];
            }
            if ([value isContainString:@" "]) {
                value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
            if ([value hasSuffix:@">"]) {
                value = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@">"]];
            }
            
            NSString *headerStr = [value safe_substringWithRange:NSMakeRange(0, 4)];
            if ([headerStr isEqualToString:@"4100"]||[headerStr isEqualToString:@"0100"]) {
                _obdConnectFailCount = 0;
                [self logCallbackWithLog:@"获取自适应车辆协议"];
                [self callbackChangeUpdate:OBDConnectStateInitialize];
                [[NSNotificationCenter defaultCenter] postNotificationName:OBD_INIT_DONE object:nil];
                // 开始访问vin码
                _actionType = OBDActionTypeVinCodeReading;
                [self writeValue:C_VIN_CODE];
                
                return;
            }else{
                [self loopSendInitCode];
            }
        }else{
            [self loopSendInitCode];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"analysisInitialize fail:%@",[exception reason]);
        _sendInitCommand = 0;
        [self loopSendInitCode];
    }
    @finally {
        
    }
    
    
    
}

- (void)analysisOBDAgreementSupportWithData:(NSString *)value
{
    _actionType = OBDActionTypeNone;
    NSLog(@"agr:%@",value);
}
- (void)analysisVinCodeWithData:(NSString *)value
{
    //        if ([value hasPrefix:@"4902"] || [value hasPrefix:@"4100"]) {
    if (YES) {
        @try {
            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@">"]];
            if ([value hasPrefix:@"4902"] || [value hasPrefix:@"0902"]) {
                if ((4+(value.length-4)) < value.length) {
                    value = [value substringWithRange:NSMakeRange(4, value.length-4)];
                }
            }
            NSString *vinCode = [CarcoreDataManager hexCodeToString:value];
            if (vinCode.length > 0) {
                NSString *aVinCode = [NSString stringWithFormat:@"%@",vinCode];
                [CarcoreDataManager sharedManager].vinCode = aVinCode;
                [[NSUserDefaults standardUserDefaults] setValue:aVinCode forKey:@"Car_VinCode"];
                NSLog(@"OBD设备初始化成功");
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            NSLog(@"Go to start transfer");
            _actionType = OBDActionTypeAbleTransfer;
            _isInitializeDone = YES;
            
            [self obdTransferStart];
            [self carPramaterThreadStart];
            // 连接上就开始记录
            if ([CarcoreDataManager sharedManager].currentTrackInfo == nil) {
                [self tripStart];
            }
        }
        
    }
}
/// 分析车速
- (void)analysisSpeedWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = C_CAR_SPEED;
    
    value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO) {
        
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        validValue = [validValue substringWithRange:NSMakeRange(0, 2)];
        
        float speed = [CarcoreDataManager floatFromString:validValue];
        //        [[CarcoreDataManager sharedManager] setSpeedValue:speed];;
        [[CarcoreDataManager sharedManager] setObd_speed:@(speed)];
        [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",speed] code:@"obd_speed"];
        // 主线程执行：
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dataCallbackWithValue:[NSNumber numberWithFloat:speed] command:command];
            [self logCallbackWithLog:[NSString stringWithFormat:@"当前车速:%.1f",speed]];
        });
    }
}
/// 分析引擎负荷
- (void)analysisEngineLoadWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = C_ENGINE_LOAD;
    
    value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO) {
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        
        float load = [CarcoreDataManager floatFromString:[validValue substringWithRange:NSMakeRange(0, 2)]];
        float loadPer = (load*100.0)/255.0;
        
        [self logCallbackWithLog:[NSString stringWithFormat:@"当前引擎负荷:%.1f%%",loadPer]];
        [[CarcoreDataManager sharedManager] setObd_engineLoad:@(loadPer)];
        [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",loadPer] code:@"obd_engineLoad"];
        
    }
}
// 汽车排量
- (CGFloat)vehicleEmission
{
    id data = [[NSUserDefaults standardUserDefaults] valueForKey:@"car_displacement"];
    if (data == nil) {
        return 1.6;
    }
    float num = [data floatValue];
    return num;
}
/// 分析油耗
- (void)analysisIntaskFlowWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = C_INTAKE_FLOW;
    value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO) {
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *AStr = [validValue substringWithRange:NSMakeRange(0, 2)];
        NSString *BStr = [validValue substringWithRange:NSMakeRange(2, 2)];
        float aValue = [CarcoreDataManager floatFromString:AStr];
        float bValue = [CarcoreDataManager floatFromString:BStr];
        
        float intaskFlow =  (aValue*256+bValue)/100.00;
        
        if (intaskFlow == 0) {
            // 当进气流量为0但是车速不为0时候，可得该车不支持进气流量
            /*
             进气量计算公式F=0.029NVP/T其中F为进气流量（g/s），N为发动机转速（rpm）,V为发动机排量（L），P为进气压力（KPA）,T为进气的绝对温度（K），其数为读到的温度值加上273.15，如进气温度为30度时，T=273.15+30。车的排量默认为1.6L,如果车辆档案内的车辆排量有填写，则使用填写的排量。
             */
            if ([CarcoreDataManager sharedManager].obd_engineRPM != 0) {
                self.isNoSupportIntaskFlow = YES;
                
                if ([CarcoreDataManager sharedManager].obd_intaskAirTemp != 0 && [CarcoreDataManager sharedManager].obd_intaskAirPresure != 0) {
                    intaskFlow = (0.029*[[CarcoreDataManager sharedManager].obd_engineRPM floatValue]*[self vehicleEmission]*[[CarcoreDataManager sharedManager].obd_intaskAirPresure floatValue])/([[CarcoreDataManager sharedManager].obd_intaskAirTemp floatValue]+273.15);
                    [[CarcoreDataManager sharedManager] setObd_airIntask:@(intaskFlow)];
                    [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",intaskFlow] code:@"obd_airIntask"];
                }
            }
        }else{
            self.isNoSupportIntaskFlow = NO;
            [[CarcoreDataManager sharedManager] setObd_airIntask:@(intaskFlow)];
            [self dataCallbackWithValue:[NSNumber numberWithFloat:intaskFlow] command:command];
            [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",intaskFlow] code:@"obd_airIntask"];
        }
    }
}
/// 分析转速
- (void)analysisEngineRPMWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = C_ENGINE_RPM;
    if (value.length < 4) {
        return;
    }
    value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO) {
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2)];
        NSString *bStr = [validValue substringWithRange:NSMakeRange(2, 2)];
        float aValue = [CarcoreDataManager floatFromString:aStr];
        float bValue = [CarcoreDataManager floatFromString:bStr];
        
        float engineRPM =  (aValue*256+bValue)/4.0;
        float oldEngineRPM = [[CarcoreDataManager sharedManager].obd_engineRPM floatValue];
        if (engineRPM > 0 && oldEngineRPM == 0) {
            // 判断启动车辆，上传数据
            [self performSelector:@selector(uploadCarStatusAfterLaunch) withObject:nil afterDelay:3.0f];
        }
        //        if (engineRPM <= 0) {
        //            if ([CarcoreDataManager sharedManager].currentTrackInfo != nil) {
        //                [self tripEnd];
        //            }
        //        }else{
        //            if ([CarcoreDataManager sharedManager].currentTrackInfo == nil) {
        //                [self tripStart];
        //            }
        [self logCallbackWithLog:[NSString stringWithFormat:@"当前转速:%.0f%%",engineRPM]];
        [[CarcoreDataManager sharedManager] setObd_engineRPM:@(engineRPM)];
        if (engineRPM > [[CarcoreDataManager sharedManager].obd_highestRPM floatValue]) {
            [CarcoreDataManager sharedManager].obd_highestRPM = @(engineRPM);
        }
        [self dataCallbackWithValue:[NSNumber numberWithFloat:engineRPM] command:command];
        [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",engineRPM] code:@"obd_engineRPM"];
        //        }
    }
}
/// 分析引擎起动运行时间
- (void)analysisEngineRuntimeWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = C_ENGINE_RUNTIME;
    value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO) {
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2)];
        NSString *bStr = [validValue substringWithRange:NSMakeRange(2, 2)];
        float aValue = [CarcoreDataManager floatFromString:aStr];
        float bValue = [CarcoreDataManager floatFromString:bStr];
        
        float engineRuntime =  (aValue*256+bValue);
        //        if (engineRPM <= 0) {
        //            [self tripEnd];
        //        }else{
        //            if ([CarcoreDataManager sharedManager].currentTrackInfo == nil) {
        //                [self tripStart];
        //            }
        NSLog(@"引擎运行时间:%.0f",engineRuntime);
        [[CarcoreDataManager sharedManager] setObd_engineRuntime:@(engineRuntime)];
        [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",engineRuntime] code:@"obd_engineRuntime"];
        
        //        }
    }
}

/// 分析电瓶电压
- (void)analysisBatteryVoltageWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@">" withString:@""];
    if ([value hasPrefix:@"?"] || [value hasPrefix:@"N"]) {
        return;
    }
    if (value.length<4) {
        return;
    }
    if ([value hasSuffix:@"V"] == NO || [value isEqualToString:@"ATRV"]) {
        return;
    }
    
    NSString *subStr = [value stringByReplacingOccurrencesOfString:@"V" withString:@""];
    //    if ([value hasSuffix:@"V"] == NO) {
    //        return;
    //    }
    //    subStr = [value substringWithRange:NSMakeRange(0, value.length -4)];
    float voltage = [subStr floatValue];
    [[CarcoreDataManager sharedManager] setCar_batteryVoltage:@(voltage+0.4)];
    [self setUserDefaultValue:[NSString stringWithFormat:@"%.1f",voltage] code:@"car_batteryVoltage"];
    
}

/// 分析引擎冷却液温度
- (void)analysisEngineCoolantTempWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = C_ENGINE_COOLANT_TEMP;
    value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
    NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2>validValue.length?validValue.length:2)];
    float aValue = [CarcoreDataManager floatFromString:aStr];
#warning 测试超出范围提醒
    
    float engineCoolantTemp = (aValue-40);
    [[CarcoreDataManager sharedManager] setObd_engineCoolantTemp:@(engineCoolantTemp)];
    [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",engineCoolantTemp] code:@"obd_engineCoolantTemp"];
    
}

/// 分析进气温度
- (void)analysisIntaskAirTempWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = C_INTAKE_AIR_TEMP;
    value = [value stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2>validValue.length?validValue.length:2)];
        float aValue = [CarcoreDataManager floatFromString:aStr];
        
        float intaskAirTemp =  (aValue-40);
        [[CarcoreDataManager sharedManager] setObd_intaskAirTemp:@(intaskAirTemp)];
        [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",intaskAirTemp] code:@"obd_intaskAirTemp"];
        
    }
}

/// 分析进气压力
- (void)analysisIntaskAirPresureWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = C_INTAKE_AIR_PRESURE;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2>validValue.length?validValue.length:2)];
        float aValue = [CarcoreDataManager floatFromString:aStr];
        
        float intaskAirPresure =  aValue;
        [[CarcoreDataManager sharedManager] setObd_intaskAirPresure:@(intaskAirPresure)];
        [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",intaskAirPresure] code:@"obd_intaskAirPresure"];
        
    }
}
/// 分析节气门开度
- (void)analysisThrottleWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = C_THROTTLE;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2>validValue.length?validValue.length:2)];
        float aValue = [CarcoreDataManager floatFromString:aStr];
        aValue = aValue*100/255.00;
        [[CarcoreDataManager sharedManager] setCar_throttle:@(aValue)];
        [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",aValue] code:@"car_throttle"];
        
    }
}

- (void)analysisCatalystTempB1s2WithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = CATALYST_TEMP_B1S2;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2)];
        NSString *bStr = [validValue substringWithRange:NSMakeRange(2, 2)];
        float aValue = [CarcoreDataManager floatFromString:aStr];
        float bValue = [CarcoreDataManager floatFromString:bStr];
        
        float CatalystTempB1s2 =  (aValue*256+bValue)/10-40;
        [[CarcoreDataManager sharedManager] setCar_catalystTempB1s2:[NSNumber numberWithFloat:CatalystTempB1s2]];
        [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",CatalystTempB1s2] code:@"car_catalystTempB1s2"];
        
    }
}

- (void)analysisCatalystTempB2s1WithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = CATALYST_TEMP_B2S1;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2)];
        NSString *bStr = [validValue substringWithRange:NSMakeRange(2, 2)];
        float aValue = [CarcoreDataManager floatFromString:aStr];
        float bValue = [CarcoreDataManager floatFromString:bStr];
        
        float CatalystTempB2s1 =  (aValue*256+bValue)/10-40;
        [[CarcoreDataManager sharedManager] setCar_catalystTempB2s1:[NSNumber numberWithFloat:CatalystTempB2s1]];
        [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",CatalystTempB2s1] code:@"car_catalystTempB1s1"];
        
    }
}

- (void)analysisCatalystTempB2s2WithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = CATALYST_TEMP_B2S2;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2)];
        NSString *bStr = [validValue substringWithRange:NSMakeRange(2, 2)];
        float aValue = [CarcoreDataManager floatFromString:aStr];
        float bValue = [CarcoreDataManager floatFromString:bStr];
        
        float CatalystTempB2s2 =  (aValue*256+bValue)/10-40;
        [[CarcoreDataManager sharedManager] setCar_catalystTempB2s2:[NSNumber numberWithFloat:CatalystTempB2s2]];
        [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",CatalystTempB2s2] code:@"car_catalystTempB1s1"];
        
    }
}

/// 分析故障列表
- (void)analysisFaultCodeWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    if (value.length <= 0) {
        return;
    }
    NSString *command = C_FAULT_CODE_READING;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        if (validValue.length <= 0) {
            return;
        }
        NSString *str1 = [validValue substringWithRange:NSMakeRange(0, 2)];
        
        /*
         NSString *str2 = [validValue substringWithRange:NSMakeRange(2, 2)];
         uint16_t a = [str1 intValue] & [str2 intValue];
         */
        int aValue = (int)[CarcoreDataManager floatFromString:str1];
        if (aValue != 0) {
            int faultNum = (aValue - 128);
            if (faultNum > 0) {
                //            self.haveFaultCode = YES;
                [[NSUserDefaults standardUserDefaults] setValue:@"存在故障" forKey:@"LastCarCheckMessage"];
                
                if (faultNum != [[CarcoreDataManager sharedManager].obd_faultNum intValue]) {
                    [[CarcoreDataManager sharedManager] setObd_faultNum:@(faultNum)];
                    
                    // 需要读取
                    self.needReadFaultDetail = YES;
                    self.isSentFaultCode = NO;
                    self.readFaultAgreement = NO;
                    
                    @autoreleasepool {
                        NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
                        NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
                        
                        for (NSString *code in [OBDConfig basicInspectionCommands]) {
                            CarCheckUpItem *item = [OBDConfig itemWithOBDCode:code];
                            id value = [[CarcoreDataManager sharedManager] valueForKey:item.valueKey];
                            NSString *valueString;
                            if ([value isKindOfClass:[NSNumber class]]) {
                                valueString = [NSString stringWithFormat:@"%.1f",[value floatValue]];
                            }else{
                                valueString = value;
                            }
                            NSMutableArray *mArr = [mDic objectForKey:code];
                            if (mArr) {
                                [mArr addObject:[NSString stringWithFormat:@"%d-%@",[value intValue],destDateString]];
                            }else{
                                mArr = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%d-%@",[value intValue],destDateString]];
                            }
                            [mDic setObject:mArr forKey:code];
                            
                            mArr = nil;
                            item = nil;
                        }
                        [[CarcoreDataManager sharedManager] saveCarSelectedStatusToDatabaseWithAllItems:YES valueTimeMap:mDic withDelegate:nil];
                        
                        
                        
                        dateFormatter = nil;
                        destDateString = nil;
                    }
                    
                    
                }
                return;
            }
        }else{
            //        self.haveFaultCode = NO;
            [[CarcoreDataManager sharedManager] setObd_faultNum:@(0)];
            [[NSUserDefaults standardUserDefaults] setValue:@"状态良好" forKey:@"LastCarCheckMessage"];
            
            return;
        }
        
    }
    
}

/// 分析具体故障码
- (void)analysisFaultDetailWithData:(NSString *)faultCode valueCode:(NSString *)valueCode
{
    //    NSString *command = C_FAULT_DETAIL_READING;
    if (self.tempErrorCodeString) {
        self.tempErrorCodeString = nil;
    }
    self.tempErrorCodeString = [[NSMutableString alloc] initWithString:faultCode];
    
    // 传输结束，开始解析
    if (self.tempErrorCodeString && self.tempErrorCodeString.length > 0) {
        
        int startLoc = 2;
        if (self.is15765Agreement == NO) {
            startLoc = 0;
        }
        
        NSLog(@"rece err:%@",self.tempErrorCodeString);
        NSRange rRange = [self.tempErrorCodeString rangeOfString:@"\r"];
        if (rRange.location != NSNotFound) {
            [self.tempErrorCodeString replaceCharactersInRange:rRange withString:@""];
        }
        
        NSString *headerCode = [self.tempErrorCodeString substringWithRange:NSMakeRange(0,2)];
        if ([headerCode isEqualToString:@"43"]) {
            NSString *validStr = [self.tempErrorCodeString substringWithRange:NSMakeRange(2+startLoc, self.tempErrorCodeString.length-2-startLoc)];
            NSMutableArray *codeArr = [NSMutableArray array];
            int i = 0;
            while (i < [validStr length])
            {
                int subStrLength = (i+4)>(int)validStr.length?((int)validStr.length-i):(4);
                NSString * subStr = [validStr substringWithRange: NSMakeRange(i, subStrLength)];
                
                NSLog(@"subStr:%@",subStr);
                
                if ([subStr isEqualToString:@"0000"] == NO && subStr.length == 4) {
                    NSString *firstLetter = [subStr substringWithRange:NSMakeRange(0, 1)];
                    subStr = [subStr stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[self errHeaderCode:firstLetter]];
                    
                    [codeArr addObject:subStr];
                }
                
                i+=4;
            }
            [CarcoreDataManager sharedManager].obd_faultArray = nil;
            [CarcoreDataManager sharedManager].obd_faultArray = [[NSArray alloc] initWithArray:codeArr];
            _needReadFaultDetail = NO;
            [[CDataManager sharedInstance] insertNewFaultDataWithFaultCodes:codeArr];
            
            self.tempErrorCodeString = nil;
            self.needReadFaultDetail = NO;
            
        }
        
    }
    [self loopOBDTransfer];
    
}

/// 分析燃油压力
- (void)analysisFuelPressureWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = C_FUEL_PRESSURE;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue safe_substringWithRange:NSMakeRange(0, 2)];
        float aValue = [CarcoreDataManager floatFromString:aStr];
        float fuelPressure = aValue * 3.00;
        [[CarcoreDataManager sharedManager] setCar_fuelPressure:@(fuelPressure)];
        [self setUserDefaultValue:[NSString stringWithFormat:@"%f",fuelPressure] code:@"car_fuelPressure"];
    }
}

/// 分析点火提前角
- (void)analysisAngleOfIgnitionAdvanceWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = C_Angle_Of_Ignition_Advance;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue safe_substringWithRange:NSMakeRange(0, 2)];
        float aValue = [CarcoreDataManager floatFromString:aStr];
        float angleOfIgnitionAdvance = aValue/2.00 - 64.00;
        [[CarcoreDataManager sharedManager] setCar_angleOfIgnitionAdvance:@(angleOfIgnitionAdvance)];
        [self setUserDefaultValue:[NSString stringWithFormat:@"%f",angleOfIgnitionAdvance] code:@"car_angleOfIgnitionAdvance"];
    }
}

/// 分析氧传感器位置
- (void)analysisOxygenSensorPositionWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey{
    NSString *command = C_Oxygen_Sensor_Position;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue safe_substringWithRange:NSMakeRange(0, 2)];
        float aValue = [CarcoreDataManager floatFromString:aStr];
        float oxygenSensorPosition = aValue;
        [[CarcoreDataManager sharedManager] setCar_oxygenSensorPosition:@(oxygenSensorPosition)];
        [self setUserDefaultValue:[NSString stringWithFormat:@"%f",oxygenSensorPosition] code:@"car_oxygenSensorPosition"];
    }
}
/// 缸组1传感器1氧传感器电压
- (void)analysisOxygenSensorVoltageCylinder1Sensor1WithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    // 上传 。。V, ...%
    NSString *command = C_Oxygen_Sensor_Voltage_Cylinder1_Sensor1;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue safe_substringWithRange:NSMakeRange(0, 2)];
        NSString *bStr = [validValue safe_substringWithRange:NSMakeRange(2, 2)];
        
        float aValue = [CarcoreDataManager floatFromString:aStr];
        aValue = aValue/200;
        NSString *oxygenSensor;
        if (([bStr intValue] & 0xFF) == 0xFF) {
            oxygenSensor = [NSString stringWithFormat:@"%.3fV",aValue];
        }else{
            float bValue = [CarcoreDataManager floatFromString:bStr];
            bValue = (bValue-128)/100*128;
            
            oxygenSensor = [NSString stringWithFormat:@"%.3f\n%.1f",aValue,bValue];
        }
        [[CarcoreDataManager sharedManager] setCar_oxygenSensorVoltageCylinder1Sensor1:oxygenSensor];
        [self setUserDefaultValue:oxygenSensor code:@"car_oxygenSensorVoltageCylinder1Sensor1"];
    }
}

/// 缸组1传感器2氧传感器电压
- (void)analysisOxygenSensorVoltageCylinder1Sensor2WithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    // 上传 。。V, ...%
    NSString *command = C_Oxygen_Sensor_Voltage_Cylinder1_Sensor2;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue safe_substringWithRange:NSMakeRange(0, 2)];
        NSString *bStr = [validValue safe_substringWithRange:NSMakeRange(2, 2)];
        
        float aValue = [CarcoreDataManager floatFromString:aStr];
        aValue = aValue/200;
        NSString *oxygenSensor;
        if (([bStr intValue] & 0xFF) == 0xFF) {
            oxygenSensor = [NSString stringWithFormat:@"%.3fV",aValue];
        }else{
            float bValue = [CarcoreDataManager floatFromString:bStr];
            bValue = (bValue-128)/100*128;
            
            oxygenSensor = [NSString stringWithFormat:@"%.3f\n%.1f",aValue,bValue];
        }
        [[CarcoreDataManager sharedManager] setCar_oxygenSensorVoltageCylinder1Sensor2:oxygenSensor];
        [self setUserDefaultValue:oxygenSensor code:@"car_oxygenSensorVoltageCylinder1Sensor2"];
    }
}

/// 缸组1传感器3氧传感器电压
- (void)analysisOxygenSensorVoltageCylinder1Sensor3WithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    // 上传 。。V, ...%
    NSString *command = C_Oxygen_Sensor_Voltage_Cylinder1_Sensor3;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue safe_substringWithRange:NSMakeRange(0, 2)];
        NSString *bStr = [validValue safe_substringWithRange:NSMakeRange(2, 2)];
        
        float aValue = [CarcoreDataManager floatFromString:aStr];
        aValue = aValue/200;
        NSString *oxygenSensor;
        if (([bStr intValue] & 0xFF) == 0xFF) {
            oxygenSensor = [NSString stringWithFormat:@"%.3fV",aValue];
        }else{
            float bValue = [CarcoreDataManager floatFromString:bStr];
            bValue = (bValue-128)/100*128;
            
            oxygenSensor = [NSString stringWithFormat:@"%.3f\n%.1f",aValue,bValue];
        }
        [[CarcoreDataManager sharedManager] setCar_oxygenSensorVoltageCylinder1Sensor3:oxygenSensor];
        [self setUserDefaultValue:oxygenSensor code:@"car_oxygenSensorVoltageCylinder1Sensor3"];
    }
}

/// 缸组1传感器4氧传感器电压
- (void)analysisOxygenSensorVoltageCylinder1Sensor4WithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    // 上传 。。V, ...%
    NSString *command = C_Oxygen_Sensor_Voltage_Cylinder1_Sensor4;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue safe_substringWithRange:NSMakeRange(0, 2)];
        NSString *bStr = [validValue safe_substringWithRange:NSMakeRange(2, 2)];
        
        float aValue = [CarcoreDataManager floatFromString:aStr];
        aValue = aValue/200;
        NSString *oxygenSensor;
        if (([bStr intValue] & 0xFF) == 0xFF) {
            oxygenSensor = [NSString stringWithFormat:@"%.3fV",aValue];
        }else{
            float bValue = [CarcoreDataManager floatFromString:bStr];
            bValue = (bValue-128)/100*128;
            
            oxygenSensor = [NSString stringWithFormat:@"%.3f\n%.1f",aValue,bValue];
        }
        [[CarcoreDataManager sharedManager] setCar_oxygenSensorVoltageCylinder1Sensor4:oxygenSensor];
        [self setUserDefaultValue:oxygenSensor code:@"car_oxygenSensorVoltageCylinder1Sensor4"];
    }
}

/// 缸组2传感器1氧传感器电压
- (void)analysisOxygenSensorVoltageCylinder2Sensor1WithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    // 上传 。。V, ...%
    NSString *command = C_Oxygen_Sensor_Voltage_Cylinder2_Sensor1;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue safe_substringWithRange:NSMakeRange(0, 2)];
        NSString *bStr = [validValue safe_substringWithRange:NSMakeRange(2, 2)];
        
        float aValue = [CarcoreDataManager floatFromString:aStr];
        aValue = aValue/200;
        NSString *oxygenSensor;
        if (([bStr intValue] & 0xFF) == 0xFF) {
            oxygenSensor = [NSString stringWithFormat:@"%.3fV",aValue];
        }else{
            float bValue = [CarcoreDataManager floatFromString:bStr];
            bValue = (bValue-128)/100*128;
            
            oxygenSensor = [NSString stringWithFormat:@"%.3f\n%.1f",aValue,bValue];
        }
        [[CarcoreDataManager sharedManager] setCar_oxygenSensorVoltageCylinder2Sensor1:oxygenSensor];
        [self setUserDefaultValue:oxygenSensor code:@"car_oxygenSensorVoltageCylinder2Sensor1"];
    }
}

/// 缸组2传感器2氧传感器电压
- (void)analysisOxygenSensorVoltageCylinder2Sensor2WithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    // 上传 。。V, ...%
    NSString *command = C_Oxygen_Sensor_Voltage_Cylinder2_Sensor2;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue safe_substringWithRange:NSMakeRange(0, 2)];
        NSString *bStr = [validValue safe_substringWithRange:NSMakeRange(2, 2)];
        
        float aValue = [CarcoreDataManager floatFromString:aStr];
        aValue = aValue/200;
        NSString *oxygenSensor;
        if (([bStr intValue] & 0xFF) == 0xFF) {
            oxygenSensor = [NSString stringWithFormat:@"%.3fV",aValue];
        }else{
            float bValue = [CarcoreDataManager floatFromString:bStr];
            bValue = (bValue-128)/100*128;
            
            oxygenSensor = [NSString stringWithFormat:@"%.3f\n%.1f",aValue,bValue];
        }
        [[CarcoreDataManager sharedManager] setCar_oxygenSensorVoltageCylinder2Sensor2:oxygenSensor];
        [self setUserDefaultValue:oxygenSensor code:@"car_oxygenSensorVoltageCylinder2Sensor2"];
    }
}

/// 缸组2传感器3氧传感器电压
- (void)analysisOxygenSensorVoltageCylinder2Sensor3WithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    // 上传 。。V, ...%
    NSString *command = C_Oxygen_Sensor_Voltage_Cylinder2_Sensor3;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue safe_substringWithRange:NSMakeRange(0, 2)];
        NSString *bStr = [validValue safe_substringWithRange:NSMakeRange(2, 2)];
        
        float aValue = [CarcoreDataManager floatFromString:aStr];
        aValue = aValue/200;
        NSString *oxygenSensor;
        if (([bStr intValue] & 0xFF) == 0xFF) {
            oxygenSensor = [NSString stringWithFormat:@"%.3fV",aValue];
        }else{
            float bValue = [CarcoreDataManager floatFromString:bStr];
            bValue = (bValue-128)/100*128;
            
            oxygenSensor = [NSString stringWithFormat:@"%.3f\n%.1f",aValue,bValue];
        }
        [[CarcoreDataManager sharedManager] setCar_oxygenSensorVoltageCylinder2Sensor3:oxygenSensor];
        [self setUserDefaultValue:oxygenSensor code:@"car_oxygenSensorVoltageCylinder2Sensor3"];
    }
}

/// 缸组2传感器4氧传感器电压
- (void)analysisOxygenSensorVoltageCylinder2Sensor4WithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    // 上传 。。V, ...%
    NSString *command = C_Oxygen_Sensor_Voltage_Cylinder2_Sensor4;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue safe_substringWithRange:NSMakeRange(0, 2)];
        NSString *bStr = [validValue safe_substringWithRange:NSMakeRange(2, 2)];
        
        float aValue = [CarcoreDataManager floatFromString:aStr];
        aValue = aValue/200;
        NSString *oxygenSensor;
        if (([bStr intValue] & 0xFF) == 0xFF) {
            oxygenSensor = [NSString stringWithFormat:@"%.3fV",aValue];
        }else{
            float bValue = [CarcoreDataManager floatFromString:bStr];
            bValue = (bValue-128)/100*128;
            
            oxygenSensor = [NSString stringWithFormat:@"%.3f\n%.1f",aValue,bValue];
        }
        [[CarcoreDataManager sharedManager] setCar_oxygenSensorVoltageCylinder2Sensor4:oxygenSensor];
        [self setUserDefaultValue:oxygenSensor code:@"car_oxygenSensorVoltageCylinder2Sensor4"];
    }
}

/// 相对歧管真空油轨压力
- (void)analysisVacuumOilPressureWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    NSString *command = C_Vacuum_Oil_Pressure;
    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
        NSString *validValue = [CarcoreDataManager validValueWithValue:value command:command];
        NSString *aStr = [validValue safe_substringWithRange:NSMakeRange(0, 2)];
        NSString *bStr = [validValue safe_substringWithRange:NSMakeRange(2, 2)];
        
        float aValue = [CarcoreDataManager floatFromString:aStr];
        float bValue = [CarcoreDataManager floatFromString:bStr];
        
        float value =  (aValue*256+bValue)*0.079;
        
        [[CarcoreDataManager sharedManager] setCar_vacuumOilPressure:@(value)];
        [self setUserDefaultValue:[NSString stringWithFormat:@"%f",value] code:@"car_vacuumOilPressure"];
    }
}

/// 氧传感器B1S1 - B4S2
- (void)analysisOxygenSensorWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    // @"%.3f V, Eq. ratio: %.3f"
    //    NSString *command = Oxygen_Sensor_B1S1;
    //    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
    NSString *validValue = [CarcoreDataManager validValueWithValue:value command:obdKey];
    NSString *aStr = [validValue safe_substringWithRange:NSMakeRange(0, 2)];
    NSString *bStr = [validValue safe_substringWithRange:NSMakeRange(2, 2)];
    NSString *cStr = [validValue safe_substringWithRange:NSMakeRange(4, 2)];
    NSString *dStr = [validValue safe_substringWithRange:NSMakeRange(6, 2)];
    
    float aValue = [CarcoreDataManager floatFromString:aStr];
    float bValue = [CarcoreDataManager floatFromString:bStr];
    float cValue = [CarcoreDataManager floatFromString:cStr];
    float dValue = [CarcoreDataManager floatFromString:dStr];
    
    float value1 =  ((aValue*256)+bValue)/32768;
    float value2 =  ((cValue*256)+dValue)/8192;
    NSString *valueStr = [NSString stringWithFormat:@"%.3f N/A\n%.3fV",value1,value2];
    [[CarcoreDataManager sharedManager] setValue:valueStr forKey:valueKey];
    [self setUserDefaultValue:valueStr code:valueKey];
    //    }
}

/// 检测三元催化
- (void)analysisCatalystTempB1s1WithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    //    NSString *command = CATALYST_TEMP_B1S1;
    //    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
    NSString *validValue = [CarcoreDataManager validValueWithValue:value command:obdKey];
    NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2)];
    NSString *bStr = [validValue substringWithRange:NSMakeRange(2, 2)];
    float aValue = [CarcoreDataManager floatFromString:aStr];
    float bValue = [CarcoreDataManager floatFromString:bStr];
    
    float CatalystTempB1s1 =  (aValue*256+bValue)/10-40;
    [[CarcoreDataManager sharedManager] setValue:[NSNumber numberWithFloat:CatalystTempB1s1] forKey:valueKey];
    [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",CatalystTempB1s1] code:valueKey];
    //    }
}

/// EGR指令开度
- (void)analysisEGRWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    //    NSString *command = CATALYST_TEMP_B1S1;
    //    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
    NSString *validValue = [CarcoreDataManager validValueWithValue:value command:obdKey];
    NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2)];
    float aValue = [CarcoreDataManager floatFromString:aStr];
    
    float egr =  (aValue*100)/255;
    [[CarcoreDataManager sharedManager] setValue:[NSNumber numberWithFloat:egr] forKey:valueKey];
    [self setUserDefaultValue:[NSString stringWithFormat:@"%f",egr] code:@"car_EGR"];
    //    }
}

/// 蒸发清除开度
- (void)analysisEvaporationClearanceWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    //    NSString *command = CATALYST_TEMP_B1S1;
    //    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
    NSString *validValue = [CarcoreDataManager validValueWithValue:value command:obdKey];
    NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2)];
    float aValue = [CarcoreDataManager floatFromString:aStr];
    
    float Clearance =  aValue*100/256;
    [[CarcoreDataManager sharedManager] setValue:[NSNumber numberWithFloat:Clearance] forKey:valueKey];
    [self setUserDefaultValue:[NSString stringWithFormat:@"%f",Clearance] code:@"car_evaporationClearance"];
    //    }
}

/// 油箱剩余油量
- (void)analysisResidualOilWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    //    NSString *command = CATALYST_TEMP_B1S1;
    //    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
    NSString *validValue = [CarcoreDataManager validValueWithValue:value command:obdKey];
    NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2)];
    float aValue = [CarcoreDataManager floatFromString:aStr];
    
    float residualOil =  aValue*100/255;
    [[CarcoreDataManager sharedManager] setValue:[NSNumber numberWithFloat:residualOil] forKey:valueKey];
    [self setUserDefaultValue:[NSString stringWithFormat:@"%f",residualOil] code:@"car_residualOil"];
    //    }
}

/// 蒸发系统蒸汽压力
- (void)analysisVapoTensionWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    //    NSString *command = CATALYST_TEMP_B1S1;
    //    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
    NSString *validValue = [CarcoreDataManager validValueWithValue:value command:obdKey];
    NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2)];
    NSString *bStr = [validValue substringWithRange:NSMakeRange(2, 2)];
    
    float aValue = [CarcoreDataManager floatFromString:aStr];
    float bValue = [CarcoreDataManager floatFromString:bStr];
    
    float VapoTension =  ((aValue*256)+bValue)-32767;
    [[CarcoreDataManager sharedManager] setValue:[NSNumber numberWithFloat:VapoTension] forKey:valueKey];
    [self setUserDefaultValue:[NSString stringWithFormat:@"%f",VapoTension] code:@"car_vapoTension"];
    //    }
}

/// 油门踏板的位置
- (void)analysisThrottlePedalPositionWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    //    NSString *command = CATALYST_TEMP_B1S1;
    //    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
    NSString *validValue = [CarcoreDataManager validValueWithValue:value command:obdKey];
    NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2)];
    
    float aValue = [CarcoreDataManager floatFromString:aStr];
    
    float ThrottlePedalPosition =  aValue*100/255;
    [[CarcoreDataManager sharedManager] setValue:[NSNumber numberWithFloat:ThrottlePedalPosition] forKey:valueKey];
    [self setUserDefaultValue:[NSString stringWithFormat:@"%f",ThrottlePedalPosition] code:@"car_throttlePedalPosition"];
    //    }
}

/// 油门踏板的相对位置
- (void)analysisThrottlePedalAcceleratorPositionWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey
{
    //    NSString *command = CATALYST_TEMP_B1S1;
    //    if (![value isEqualToString:command] && [value isEqualToString:[CarcoreDataManager obdQuickCommand:command]] == NO){
    NSString *validValue = [CarcoreDataManager validValueWithValue:value command:obdKey];
    NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2)];
    
    float aValue = [CarcoreDataManager floatFromString:aStr];
    
    float ThrottlePedalAcceleratorPosition =  aValue*100/255;
    [[CarcoreDataManager sharedManager] setValue:[NSNumber numberWithFloat:ThrottlePedalAcceleratorPosition] forKey:valueKey];
    [self setUserDefaultValue:[NSString stringWithFormat:@"%f",ThrottlePedalAcceleratorPosition] code:@"car_throttlePedalAcceleratorPosition"];
    //    }
}
/// 油耗修正
- (void)analysisTermFuelCorrectionWithData:(NSString *)value :(NSString *)valueKey :(NSString *)obdKey{
    NSString *validValue = [CarcoreDataManager validValueWithValue:value command:obdKey];
    NSString *aStr = [validValue substringWithRange:NSMakeRange(0, 2)];
    float aValue = [CarcoreDataManager floatFromString:aStr];
    
    float fuelCorrection =  0.7812*(aValue-128);
    [[CarcoreDataManager sharedManager] setValue:[NSNumber numberWithFloat:fuelCorrection] forKey:valueKey];
    [self setUserDefaultValue:[NSString stringWithFormat:@"%.0f",fuelCorrection] code:valueKey];
}


- (NSString *)errHeaderCode:(NSString *)header
{
    if ([header isEqualToString:@"0"]) {
        return @"P0";
    }else if ([header isEqualToString:@"1"]) {
        return @"P1";
    }else if ([header isEqualToString:@"2"]) {
        return @"P2";
    }else if ([header isEqualToString:@"3"]) {
        return @"P3";
    }else if ([header isEqualToString:@"4"]) {
        return @"C0";
    }else if ([header isEqualToString:@"5"]) {
        return @"C1";
    }else if ([header isEqualToString:@"6"]) {
        return @"C2";
    }else if ([header isEqualToString:@"7"]) {
        return @"C3";
    }else if ([header isEqualToString:@"8"]) {
        return @"B0";
    }else if ([header isEqualToString:@"9"]) {
        return @"B1";
    }else if ([header isEqualToString:@"A"]) {
        return @"B2";
    }else if ([header isEqualToString:@"B"]) {
        return @"B3";
    }else if ([header isEqualToString:@"C"]) {
        return @"U0";
    }else if ([header isEqualToString:@"D"]) {
        return @"U1";
    }else if ([header isEqualToString:@"E"]) {
        return @"U2";
    }else if ([header isEqualToString:@"F"]) {
        return @"U3";
    }
    return header;
}

- (void)analysisFaultCode:(NSString *)faultCode
{
}

- (void)setUserDefaultValue:(NSString *)value code:(NSString *)code
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:code];
}

#pragma mark -

- (void)tripStart
{
    [[CarcoreDataManager sharedManager] tripStart];
    NSLog(@"行程开始");
}

- (void)tripEnd
{
    [[CarcoreDataManager sharedManager] tripEnd];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentTripEnd" object:nil];
}

- (void)uploadCarStatusAfterLaunch
{
    [[CarcoreDataManager sharedManager] uploadCarStatusWithType:2 trackID:nil Delegate:nil];
}

#pragma mark - CBCentralManager delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
        {
            OBDLog(@"CBCentralManagerStatePoweredOn");
            //            [self cleanup];
            self.isBluetoothAvaliable = YES;
            [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
            _connectState = OBDConnectStateSearching;
            [self callbackChangeUpdate:OBDConnectStateSearching];
            //            [self startTimeoutTimer];
        }
            break;
            
        case CBCentralManagerStatePoweredOff:{
            OBDLog(@"CBCentralManagerStatePoweredOff");
            [[TitleMessageBox instance] hideMessageBox];
            
            [self cleanup];
            self.isBluetoothAvaliable = NO;
        }
            break;
            
        case CBCentralManagerStateUnsupported:
            OBDLog(@"CBCentralManagerStateUnsupported");
            break;
            
        default:
            self.isBluetoothAvaliable = YES;
            break;
    }
}

-(void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if([peripheral.name isEqualToString:kCarcoreOBDName]){
        [self.centralManager stopScan];
        if (self.delegate && [self.delegate respondsToSelector:@selector(carcoreDidDiscoverOBDDevice)]) {
            [self.delegate carcoreDidDiscoverOBDDevice];
        }
        
        if (_discoveredPeripheral != peripheral) {
            
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
            _discoveredPeripheral = peripheral;
            
        }
        // And connect
        [self.centralManager connectPeripheral:peripheral options:nil];
        _connectState = OBDConnectStateConnecting;
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    // Stop scanning
    _discoveredPeripheral.delegate = self;
    
    _isConnected = YES;
    [_discoveredPeripheral discoverServices:@[[CBUUID UUIDWithString:@"FFF0"]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"连接失败:%@",[error localizedDescription]);
    [self cleanup];
    [self errorCallbackWithError:[error localizedDescription] code:OBDErrorConnectFail];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OBD_DISCONNECT object:nil];
    if (_carParameterTimer) {
        dispatch_source_cancel(_carParameterTimer);
    }
    if (error == nil) {
        _centralManager = nil;
        _discoveredPeripheral = nil;
        _targetService = nil;
        _targetCharacteristic = nil;
        [self callbackChangeUpdate:OBDConnectStateDisconnect];
        _actionType = OBDActionTypeNone;
    }else
    {
        OBDLog(@"点开连接失败:%@",[error localizedDescription]);
        [[NSUserDefaults standardUserDefaults] setValue:@NO forKey:CANCEL_AUTO_RECORDING_TRIP];
        [self callbackChangeUpdate:OBDConnectStateDisconnect];
        [self tripEnd];
        [self obdTransferStop];
        [self cleanup];
        [self scanOBDDevice];
        [[TitleMessageBox instance] hideMessageBox];
        [[CarcoreDataManager sharedManager] saveParkingTimeWithTimeLimit:YES];
        /*
         if ([CDataManager sharedInstance].lastParkInfoSaveTime) {
         NSTimeInterval secondsInterval= [[CDataManager sharedInstance].lastParkInfoSaveTime timeIntervalSinceDate:[NSDate date]];
         if (secondsInterval > 5*60000) {
         CLLocationCoordinate2D location = [[BMKLocationServiceHelper instance] currentLocation];
         [BMKLocationServiceHelper locationInfoWithCoordinate:location success:^(NSString *address) {
         NSString *latlng = [BMKLocationServiceHelper locationStringWithCoordinate:location];
         NSString *locationStr = address;
         ParkingMEMO* parking = [[CDataManager sharedInstance] createEntityWithName:@"ParkingMEMO"];
         parking.parkingTime = [NSDate date];
         parking.parkingTitle = [NSString stringWithFormat:@"%@",locationStr];
         parking.parkingLagLng = latlng;
         parking.parkingAddress = locationStr;
         parking.parkingImageUrl = nil;
         parking.userId = [CUserDefaults instance].userId;
         [[CDataManager sharedInstance] saveParkingMEMO:parking];
         }];
         [CDataManager sharedInstance].lastParkInfoSaveTime = [NSDate date];
         }
         }else{
         CLLocationCoordinate2D location = [[BMKLocationServiceHelper instance] currentLocation];
         [BMKLocationServiceHelper locationInfoWithCoordinate:location success:^(NSString *address) {
         NSString *latlng = [BMKLocationServiceHelper locationStringWithCoordinate:location];
         NSString *locationStr = address;
         ParkingMEMO* parking = [[CDataManager sharedInstance] createEntityWithName:@"ParkingMEMO"];
         parking.parkingTime = [NSDate date];
         parking.parkingTitle = [NSString stringWithFormat:@"%@",locationStr];
         parking.parkingLagLng = latlng;
         parking.parkingAddress = locationStr;
         parking.parkingImageUrl = nil;
         parking.userId = [CUserDefaults instance].userId;
         [[CDataManager sharedInstance] saveParkingMEMO:parking];
         }];
         [CDataManager sharedInstance].lastParkInfoSaveTime = [NSDate date];
         
         }
         */
    }
    [self cleanup];
    
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        OBDLog(@"扫描服务错误:%@",[error localizedDescription]);
        
        return;
    }
    
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(carcoreDidDiscoverServices:)]) {
    //        [self.delegate carcoreDidDiscoverServices:self.discoveredPeripheral.services];
    //    }
    
    for (CBService *service in peripheral.services)
    {
        if ([[service.UUID UUIDString] isEqual:@"FFF0"]) {
            self.obdService = service;
            [self.discoveredPeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:ISSC_TRANS_RX],[CBUUID UUIDWithString:ISSC_TRANS_TX]] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self reconnect];
        return;
    }
    if (![CUserDefaults instance].isLogined) {
        NSLog(@"没有登录");
        return;
    }
    _targetService = nil;
    _targetService = service;
    
    for (CBCharacteristic *characteristics in service.characteristics)
    {
        if ([characteristics.UUID isEqual:[CBUUID UUIDWithString:ISSC_TRANS_RX]]) {
            self.rxCharacteristic = characteristics;
        }else if ([characteristics.UUID isEqual:[CBUUID UUIDWithString:ISSC_TRANS_TX]])
        {
            self.txCharacteristic = characteristics;
            [peripheral setNotifyValue:YES forCharacteristic:characteristics];
        }
        
    }
    if (self.rxCharacteristic != nil && self.txCharacteristic != nil) {
        //        _transferReady = YES;
        //        _connectState = OBDConnectStateTransferReady;
        //        [self callbackChangeUpdate:OBDConnectStateTransferReady];
    }else{
        [self reconnect];
    }
}

/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"改变监听状态错误: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:ISSC_TRANS_TX]]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"开始监听:%@", characteristic);
        // 开始初始化
        // !!!: 开始传输
        _transferReady = YES;
        _connectState = OBDConnectStateTransferReady;
        [self callbackChangeUpdate:OBDConnectStateTransferReady];
        
        //        [self performSelector:@selector(OBDDriverInitialize) withObject:nil afterDelay:0.5];
        //        [self OBDDriverInitialize];
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        //        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        //        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Read Value Error:%@",[error localizedDescription]);
        return;
    }
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(carcoreDidUpdateCharacteristicsValue:)]) {
    //        [self.delegate carcoreDidUpdateCharacteristicsValue:characteristic];
    //    }
    NSString *aValue = [CarcoreDataManager stringWithData:characteristic.value];
    
    if ([CarcoreDataManager valueIsEqualCommand:aValue]) {
        return;
    }
    if ([aValue hasPrefix:@"43"]) {
        NSLog(@"开始记录错误");
    }
    if (aValue.length == 2 && [aValue isEqualToString:@"03"]) {
        return;
    }
    
    if ([_currentSendCode isEqualToString:C_FAULT_AGREEMENT]) {
        if ([aValue isEqualToString:C_FAULT_AGREEMENT]) {
            return;
        }
        NSLog(@"%@",aValue);
    }
    
    //    NSRange vaildRange;
    if ([aValue isContainString:@"STOPPED"]||
        [aValue isContainString:@"RESET"]) {
        if (self.actionType == OBDActionTypeBasicInitialize) {
            [self loopSendInitCode];
        }else if(self.actionType == OBDActionTypeAbleTransfer){
            [self loopOBDTransfer];
        }
        return;
    }
    
    if ([aValue isContainString:@"NO DATA"]) {
        //        NSLog(@"%@",[NSString stringWithFormat:@"发送%@得到数据NO DATA",_currentSendCode]);
        if (self.actionType == OBDActionTypeAbleTransfer ) {
            if ([_currentSendCode isEqualToString:C_INTAKE_FLOW]) {
                // !!!:车辆不支持进气流量
                /*
                 油耗问题，有些车进气量“0110”没有返回，或返回NO DATA,所以如果收到发动机转速大于300，1秒钟内（延时一段时间是因为可能刚读转速还没开始读进气0110）进气量还是0，则发送010B1和010F1读取进气温度进气压力计算详见协义中的的“油耗信息”一栏。
                 进气量计算公式F=0.029NVP/T其中F为进气流量（g/s），N为发动机转速（rpm）,V为发动机排量（L），P为进气压力（KPA）,T为进气的绝对温度（K），其数为读到的温度值加上273.15，如进气温度为30度时，T=273.15+30。车的排量默认为1.6L,如果车辆档案内的车辆排量有填写，则使用填写的排量。
                 */
                if ([CarcoreDataManager sharedManager].obd_engineRPM != 0) {
                    self.isNoSupportIntaskFlow = YES;
                    
                    if ([CarcoreDataManager sharedManager].obd_intaskAirTemp != 0 && [CarcoreDataManager sharedManager].obd_intaskAirPresure != 0) {
                        [CarcoreDataManager sharedManager].obd_airIntask = @(0.029*[[CarcoreDataManager sharedManager].obd_engineRPM floatValue]*1.6*[[CarcoreDataManager sharedManager].obd_intaskAirPresure floatValue]/([[CarcoreDataManager sharedManager].obd_intaskAirTemp floatValue]+273.15));
                    }
                }else{
                    self.isNoSupportIntaskFlow = NO;
                }
                
            }
            _bleTempString = [NSMutableString stringWithFormat:@""];
            [self loopOBDTransfer];
        }else if(self.actionType == OBDActionTypeVinCodeReading)
        {
            _actionType = OBDActionTypeAbleTransfer;
            _isInitializeDone = YES;
            [self obdTransferStart];
            [self carPramaterThreadStart];
        }
        return;
    }
    
    if ([aValue isContainString:@"UNABLE TO CONNECT"]) {
        // 重新初始化命令
        if (self.actionType == OBDActionTypeBasicInitialize) {
            _sendInitCommand = 0;
            [self loopSendInitCode];
        }
    }
    
    // 去除space
    NSRange spaceRange = [aValue rangeOfString:@" "];
    if (spaceRange.location != NSNotFound) {
        aValue = [aValue stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    // 去除冒号
    NSRange maoRange = [aValue rangeOfString:@":"];
    if (maoRange.location != NSNotFound) {
        NSMutableString *tempStr = [[NSMutableString alloc] init];
        aValue = [aValue stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *arr = [aValue componentsSeparatedByString:@":"];
        for (int i = 0; i < arr.count; i++) {
            if (i != 0) {
                NSString *str = arr[i];
                NSLog(@"length:%lu",(unsigned long)str.length);
                if (str.length %2 != 0) {
                    str = [str substringWithRange:NSMakeRange(0, str.length-1)];
                }
                [tempStr safe_appendString:str];
            }
        }
        aValue = tempStr;
    }
    
    if ([_currentSendCode isEqualToString:C_VIN_CODE]) {
        @try {
            if ([aValue hasPrefix:@"4902"]) {
                aValue = [aValue substringWithRange:NSMakeRange(6, aValue.length - 6)];
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
    
    [_bleTempString safe_appendString:aValue];
    //    NSLog(@"%@",[NSString stringWithFormat:@"BLE_TEMP:%@",_bleTempString]);
    if ([_bleTempString hasPrefix:@"413c"]) {
        NSLog(@"接收413c");
    }
    if ([aValue hasSuffix:@">"]) {
        
        // 接收到结束符号
        NSString *value = [_bleTempString stringByReplacingOccurrencesOfString:@">" withString:@""];
        if (self.needReadFaultDetail == YES) {
            
            if (self.readFaultAgreement == NO) {
                _is15765Agreement = [value containsString:@"15765"];
                self.readFaultAgreement = YES;
                [_bleTempString replaceCharactersInRange:NSMakeRange(0, _bleTempString.length) withString:@""];
                [self loopOBDTransfer];
                return;
            }
            
            NSString *headerCode = [value substringWithRange:NSMakeRange(0, 2)];
            
            if ([headerCode hasSuffix:@"43"]) {
                [self analysisFaultDetailWithData:value valueCode:@""];
            }
            
            return;
        }
        
        if (self.actionType == OBDActionTypeBasicInitialize) {
            [self analysisInitializeWithData:value];
        }else if (self.actionType == OBDActionTypeVinCodeReading)
        {
            NSLog(@"vin码源码长度:%ld",[value length]);
            [self analysisVinCodeWithData:value];
        }else if (self.actionType == OBDActionTypeAgreementSupport)
        {
            [self analysisOBDAgreementSupportWithData:value];
        }
        else{
            
            NSMutableString *tempStr = [NSMutableString stringWithString:value];
            NSString *headerCode = tempStr;
            if ([tempStr hasPrefix:@"4"] || [tempStr hasPrefix:@"0"]) {
                if ([tempStr hasPrefix:@"4"]) {
                    [tempStr replaceCharactersInRange:NSMakeRange(0, 1) withString:@"0"];
                }
                if (tempStr.length < 4) {
                    return;
                }
                headerCode = [tempStr safe_substringWithRange:NSMakeRange(0, 4)];
                NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"OBDCodeList" ofType:@"plist"];
                NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
                NSDictionary *codeDic = data[headerCode];
                NSString *selString = codeDic[@"selector"];
                
                if ([selString length] > 0 && [selString isEqualToString:@"none"] == NO) {
                    SEL sel = NSSelectorFromString(selString);
                    if (sel) {
                        @try {
                            // value valueKey obdKey
                            IMP imp = [self methodForSelector:sel];
                            void (*func)(id, SEL, NSString *,NSString *,NSString *) = (void *)imp;
                            NSString *valueKey = codeDic[@"data_key"];
                            func(self, sel, tempStr,valueKey,headerCode);
                        }
                        @catch (NSException *exception) {
                            //                            NSAssert(0, @"%s :%@",__func__,[exception reason]);
#warning analysisFaultCodeWithData:::错误 [__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object from objects[2]
                            NSLog(@"%@", [exception reason]);
                        }
                    }
                }else{
                    // !!!:   异常数据处理
                    [self exceptionValueHandler:tempStr];
                }
            }else{
                // !!!:   异常数据处理
                [self exceptionValueHandler:tempStr];
            }
            // !!!: 开始下一轮传输
            [self loopOBDTransfer];
        }
        
        [_bleTempString replaceCharactersInRange:NSMakeRange(0, _bleTempString.length) withString:@""];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Did write error:%@",[error localizedDescription]);
        return;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == tAlert_BluetoothSetting) {
        if (buttonIndex == 1) {
            NSURL *url;
            //            if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f) {
            //                url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            //            }
            url=[NSURL URLWithString:@"prefs:root=Bluetooth"];
            [[UIApplication sharedApplication] openURL:url];
            //            if ([[UIApplication sharedApplication] canOpenURL:url]) {
            //                [[UIApplication sharedApplication] openURL:url];
            //            }
        }
    }else if (alertView.tag == 10010)
    {
        if (buttonIndex == 1) {
            [self scanOBDDevice];
        }
    }
}

@end
