//
//  OBDParse.h
//  CarcoreBTTest
//
//  Created by Besprout's Mac Mini on 15/5/21.
//  Copyright (c) 2015年 Fang Zijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CarCheckUpItem.h"
#define CARCORE_AIR_UUID @"5FFD42FC-E1D6-963C-6DFE-EC378DC517DC"
// OBD名称
extern NSString *const kCarcoreOBDName;
// ISSC专有服务
extern NSString *const ISSC_PROPRIETARY_SERVICE;
// ISSC的专有特性
extern NSString *const ISSC_UPDATE_CONNECTION_PARAMETER;
extern NSString *const ISSC_AIR_PATCH;
// 输入流
extern NSString *const ISSC_TRANS_RX;
// 输出流
extern NSString *const ISSC_TRANS_TX;

/// 错误协议类型
extern NSString *const C_FAULT_AGREEMENT;

/// 读取车辆VIN码
extern NSString *const C_VIN_CODE;
/// 设置设备自适应车辆协义
extern NSString *const C_CAR_AGREEMENT_SUPPORT;
/// 车速
extern NSString *const C_CAR_SPEED;
/// 发动机负荷
extern NSString *const C_ENGINE_LOAD;
//extern NSString *const C_FUEL_CONSUMPTION;
/// 进气流量 g/s
extern NSString *const C_INTAKE_FLOW;
/// 进气温度
extern NSString *const C_INTAKE_AIR_TEMP;
/// 进气压力
extern NSString *const C_INTAKE_AIR_PRESURE;
/// 故障码
extern NSString *const C_FAULT_CODE_READING;
/// 具体故障码
extern NSString *const C_FAULT_DETAIL_READING;
/// 发动机转速
extern NSString *const C_ENGINE_RPM;
/// 引擎起动运行时间
extern NSString *const C_ENGINE_RUNTIME;
/// 电瓶电压
extern NSString *const C_HEALTH_BATTERY_VOLTAGE;
/// 节气门开度
extern NSString *const C_THROTTLE;


/// A-40 冷却剂温度℃
extern NSString *const C_ENGINE_COOLANT_TEMP;

extern NSString *const INTAKE_PRESSURE;
extern NSString *const ENGINE_RPM;
extern NSString *const VEHICLE_SPEED;
extern NSString *const RESIDUE_OIL;

extern NSString *const CONT_MODULE_VOLT;
extern NSString *const AMBIENT_AIR_TEMP;
extern NSString *const ENGINE_OIL_TEMP;

extern NSString *const kCAR_CHECKUP_ITEMS;

#pragma mark - 体检项目

/// 燃油压力 410A45 A*3
extern NSString *const C_FUEL_PRESSURE;
/// 点火提前角 410E47 A/2-64
extern NSString *const C_Angle_Of_Ignition_Advance;
/// 氧传感器位置 41136916 A
extern NSString *const C_Oxygen_Sensor_Position;
/** 缸组x传感器x氧传感器电压  短期燃油校正
    41146916
    A/200（单位是V）
    (B-128)/100*128 如果B=0XFF,则此百分比无效
 */
extern NSString *const C_Oxygen_Sensor_Voltage_Cylinder1_Sensor1;
extern NSString *const C_Oxygen_Sensor_Voltage_Cylinder1_Sensor2;
extern NSString *const C_Oxygen_Sensor_Voltage_Cylinder1_Sensor3;
extern NSString *const C_Oxygen_Sensor_Voltage_Cylinder1_Sensor4;
extern NSString *const C_Oxygen_Sensor_Voltage_Cylinder2_Sensor1;
extern NSString *const C_Oxygen_Sensor_Voltage_Cylinder2_Sensor2;
extern NSString *const C_Oxygen_Sensor_Voltage_Cylinder2_Sensor3;
extern NSString *const C_Oxygen_Sensor_Voltage_Cylinder2_Sensor4;
/**
    相对歧管真空油轨压力
    41224556
    (A*256+B)*0.079
 */
extern NSString *const C_Vacuum_Oil_Pressure;

/**
 氧传感器 B1S1-B4S2
 412445412354
 ((A*256)+B)/32768
 ((C*256)+D)/8192
 */
extern NSString *const Oxygen_Sensor_B1S1;
extern NSString *const Oxygen_Sensor_B1S2;
extern NSString *const Oxygen_Sensor_B2S1;
extern NSString *const Oxygen_Sensor_B2S2;
extern NSString *const Oxygen_Sensor_B3S1;
extern NSString *const Oxygen_Sensor_B3S2;
extern NSString *const Oxygen_Sensor_B4S1;
extern NSString *const Oxygen_Sensor_B4S2;

/**
三元催化剂温度
413C4552
(A*256+B)/10-40
 */
extern NSString *const CATALYST_TEMP_B1S1;
extern NSString *const CATALYST_TEMP_B1S2;
extern NSString *const CATALYST_TEMP_B2S1;
extern NSString *const CATALYST_TEMP_B2S2;
/**
 EGR指令开度
 412C45 
 A*100/255
 */
extern NSString *const C_EGR;
/**
 蒸发清除开度
 412E47
 A*100/256
 */
extern NSString *const C_Evaporation_Clearance;
/**
 油箱剩余油量
 412F45
 A*100/255
 */
extern NSString *const C_Residual_Oil;
/**
 蒸发系统蒸汽压力
 41544556
 ((A*256)+B)-32767
 */
extern NSString *const C_Vapo_Tension;
/**
 油门踏板的位置
 414B45
 A*100/255
 */
extern NSString *const C_Throttle_Pedal_Position;
/**
 油门踏板的相对位置
 415A45
 A*100/255
 */
extern NSString *const C_Throttle_Pedal_Accelerator_Position;
/**
  短期燃油校正(1，3)
 410645
 0.7812*(A-128)
 */
extern NSString *const C_Short_Term_Fuel_Correction13;
/**
 长期燃油校正(1，3)
 410645
 0.7812*(A-128)
 */
extern NSString *const C_Long_Term_Fuel_Correction13;
/**
 短期燃油校正(2，4)
 410645
 0.7812*(A-128)
 */
extern NSString *const C_Short_Term_Fuel_Correction24;
/**
 长期燃油校正(2，4)
 410645
 0.7812*(A-128)
 */
extern NSString *const C_Long_Term_Fuel_Correction24;
#pragma mark -

typedef NS_ENUM(NSInteger, OBDActionType)
{
    OBDActionTypeBasicInitialize = 0,
    OBDActionTypeVinCodeReading,
    OBDActionTypeAgreementSupport,
    OBDActionTypeAbleTransfer,
    OBDActionTypeGetSpeed,
    OBDActionTypeGetEngineLoad,
    OBDActionTypeGetEngineRPM,
    OBDActionTypeIntakeFlow,
    OBDActionTypeNone,
};

typedef NS_ENUM(NSInteger, OBDConnectState)
{
    OBDConnectStateSearching = 0,
    OBDConnectStateConnecting,
    OBDConnectStateConnected,
    OBDConnectStateDisconnect,
    OBDConnectStateTransferReady,
    OBDConnectStateAgreementSupport,
    OBDConnectStateInitialize,
};

typedef NS_ENUM(NSInteger, OBDError)
{
    OBDErrorInitFail,
    OBDErrorConnectFail,
};

typedef NS_ENUM(NSInteger, OBDCommandContain){
    OBDCommandContainBasic      = 0,
    OBDCommandContainInspection     = 1,
    OBDCommandContainCarStatus = 2,
    OBDCommandContainCarDetailItems = 3,
    OBDCommandContainFault      = 4,
};

@interface OBDConfig : NSObject
@property (nonatomic) OBDCommandContain commandContain;
/// 传输命令集
@property (nonatomic, strong) NSArray *transferCommands;
/// 基本命令集
@property (nonatomic, strong) NSArray *basicCommands;

/// 体检命令集,这个集合为所有体检项目集合
@property (nonatomic, strong) NSArray *vehicleInspectionCommands;
/// 选择的车辆项目集
@property (nonatomic, strong) NSMutableArray *selectedCarInfoItems;
@property (nonatomic, strong) NSArray *carCheckUpSelectedLibrary;
//+ (instancetype)sharedConfig;

+ (CarCheckUpItem *)itemWithOBDCode:(NSString *)obdCode;

+ (NSArray *)initializeCommands;
+ (NSDictionary *)OBDListDictionary;
+ (NSArray *)basicCommandsWithIntakeFlowNotSupport:(BOOL)isNoSupport;
+ (NSString *)initializeCommandsWithIndex:(NSInteger)index;
+ (NSArray *)getCheckUpItemsArrayFromCodeArray:(NSArray *)codeArray;
/// 基本体检项目
+ (NSArray *)basicInspectionCommands;
/// 车辆状态
+ (NSArray *)carStatusLibrary;

- (NSArray *)vehicleInspectionItemsLibrary;
+ (NSArray *)vehicleInspectionAllItemsLibrary;
/// 重置CarCheckUpSelectedLibrary
- (void)resetCarCheckUpSelectedLibrary;
@end
