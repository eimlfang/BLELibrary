//
//  CarcoreDataManager.h
//  CarcoreBTTest
//
//  Created by Besprout's Mac Mini on 15/5/19.
//  Copyright (c) 2015年 Fang Zijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreMotion/CoreMotion.h>
#import "CDataManager.h"
#import "TrackInfo.h"
#import "OBDConfig.h"
#import "ServerAdaptorDelegateProtocol.h"

typedef NS_ENUM(NSInteger, CarRunningStatus){
    CarRunningStatusIdle,
    CarRunningStatusNormal,
    CarRunningStatusHeavyAccel,
    CarRunningStatusBreak
};

typedef struct {
    float speed;
    CMAcceleration acceleration;
} SharpTurnParameter;

NS_INLINE SharpTurnParameter SharpTurnParameterMake(float speed, CMAcceleration acceleration) {
    SharpTurnParameter p;
    p.speed = speed;
    p.acceleration = acceleration;
    return p;
}


@interface SharpTurnData : NSObject

@property (assign, nonatomic) SharpTurnParameter parameter;

@end

@interface CarcoreDataManager : NSObject<ServerAdaptorDelegateProtocol>
@property (nonatomic, strong) OBDConfig *tempOBDConfig;

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSOperationQueue *motionQueue;
@property(readonly, nonatomic) CMAcceleration acceleration;
@property (nonatomic, strong) NSMutableArray *sharpTurnDataArray;

@property (nonatomic, strong) NSMutableArray *supportAgreements;

@property (nonatomic, strong) TrackInfo *currentTrackInfo;
@property (nonatomic, strong) NSString *currentTrackLatlngsStr;

@property (nonatomic, readwrite) CarRunningStatus runningStatus;
/// 坐标集字符串
@property (nonatomic, strong) NSMutableString *trip_locationString;
/// 坐标集数据
@property (nonatomic, strong) NSData *trip_locationData;
/// Vin码
@property (nonatomic, strong) NSString *vinCode;
/// 故障个数
@property (nonatomic, strong) NSNumber *obd_faultNum;
/// 故障集合
@property (nonatomic, strong) NSArray *obd_faultArray;
/// 速度
@property (nonatomic, strong) NSNumber *obd_speed;
/// 最高速度
@property (nonatomic, strong) NSNumber *obd_speedMax;
/// 平均速度
@property (nonatomic, strong) NSNumber *obd_averageSpeed;
/// 引擎负荷
@property (nonatomic, strong) NSNumber *obd_engineLoad;
/// 引擎转速
@property (nonatomic, strong) NSNumber *obd_engineRPM;
/// 引擎运行时间
@property (nonatomic, strong) NSNumber *obd_engineRuntime;
/// 冷却液温度
@property (nonatomic, strong) NSNumber *obd_engineCoolantTemp;
/// 进气量
@property (nonatomic, strong) NSNumber *obd_airIntask;
/// 进气温度
@property (nonatomic, strong) NSNumber *obd_intaskAirTemp;
/// 进气压力
@property (nonatomic, strong) NSNumber *obd_intaskAirPresure;
/// 瞬时油耗
@property (nonatomic, strong) NSNumber *obd_instantFuelConsumption;
/// 展示瞬时油耗
@property (nonatomic, strong) NSNumber *obd_displayInstantFuelConsumption;

/// 总油耗
@property (nonatomic, strong) NSNumber *obd_totalFuelConsumption;
/// 平均油耗
@property (nonatomic, strong) NSNumber *obd_avgFuelConsumption;
// 耗费价格
@property (nonatomic, strong) NSNumber *obd_totalDriverCost;

/// 瞬时油耗
@property (nonatomic, strong) NSNumber *obd_fuelCount;
/// 急加速
@property (nonatomic, strong) NSNumber *obd_heavyAccelTimes;
/// 急转弯
@property (nonatomic, strong) NSNumber *obd_sharpTurnTimes;
/// 急减速
@property (nonatomic, strong) NSNumber *obd_sharpSlowdownTimes;
/// 当前行程里程
@property (nonatomic, strong) NSNumber *obd_totalMileage;
/// 怠速时间,单位1.8s
@property (nonatomic, strong) NSNumber *obd_zeroSpeedTimes;
/// 低速行驶时间
@property (nonatomic, strong) NSNumber *obd_lowSpeedTimes;
/// 中速行驶时间
@property (nonatomic, strong) NSNumber *obd_normalSpeedTimes;
/// 高速行驶时间
@property (nonatomic, strong) NSNumber *obd_highSpeedTimes;
/// 最高转速
@property (nonatomic, strong) NSNumber *obd_highestRPM;
/// 高速行驶时间
@property (nonatomic, strong) NSNumber *obd_highestSpeed;
/// 电瓶电压
@property (nonatomic, strong) NSNumber *car_batteryVoltage;
/// 气节门开度
@property (nonatomic, strong) NSNumber *car_throttle;
/// 三元催化b1s1
@property (nonatomic, strong) NSMutableArray *fuelScoreArray;
@property (nonatomic, strong) NSNumber *fuelScoreCount;

#pragma mark - 体检数据
/// 短期燃油校正(1，3)
@property (nonatomic, strong) NSNumber * car_shortTermFuelCorrection13;
/// 长期燃油校正(1，3)
@property (nonatomic, strong) NSNumber * car_longTermFuelCorrection13;
/// 短期燃油校正(2，4)
@property (nonatomic, strong) NSNumber * car_shortTermFuelCorrection24;
/// 长期燃油校正(2，4)
@property (nonatomic, strong) NSNumber * car_longTermFuelCorrection24;
/// 燃油压力
@property (nonatomic, strong) NSNumber *car_fuelPressure;
/// 点火提前角
@property (nonatomic, strong) NSNumber *car_angleOfIgnitionAdvance;
/// 氧传感器位置
@property (nonatomic, strong) NSNumber *car_oxygenSensorPosition;
/// 缸组1传感器1氧传感器电压
@property (nonatomic, strong) NSString *car_oxygenSensorVoltageCylinder1Sensor1;
/// 缸组1传感器2氧传感器电压
@property (nonatomic, strong) NSString *car_oxygenSensorVoltageCylinder1Sensor2;
/// 缸组1传感器3氧传感器电压
@property (nonatomic, strong) NSString *car_oxygenSensorVoltageCylinder1Sensor3;
/// 缸组1传感器4氧传感器电压
@property (nonatomic, strong) NSString *car_oxygenSensorVoltageCylinder1Sensor4;
/// 缸组2传感器1氧传感器电压
@property (nonatomic, strong) NSString *car_oxygenSensorVoltageCylinder2Sensor1;
/// 缸组2传感器2氧传感器电压
@property (nonatomic, strong) NSString *car_oxygenSensorVoltageCylinder2Sensor2;
/// 缸组2传感器3氧传感器电压
@property (nonatomic, strong) NSString *car_oxygenSensorVoltageCylinder2Sensor3;
/// 缸组2传感器4氧传感器电压
@property (nonatomic, strong) NSString *car_oxygenSensorVoltageCylinder2Sensor4;
/// 相对歧管真空油轨压力
@property (nonatomic, strong) NSNumber *car_vacuumOilPressure;
/// 氧传感器B1S1
@property (nonatomic, strong) NSString * car_oxygenSensorB1S1;
/// 氧传感器B1S2
@property (nonatomic, strong) NSString * car_oxygenSensorB1S2;
/// 氧传感器B2S1
@property (nonatomic, strong) NSString * car_oxygenSensorB2S1;
/// 氧传感器B2S2
@property (nonatomic, strong) NSString * car_oxygenSensorB2S2;
/// 氧传感器B3S1
@property (nonatomic, strong) NSString * car_oxygenSensorB3S1;
/// 氧传感器B3S2
@property (nonatomic, strong) NSString * car_oxygenSensorB3S2;
/// 氧传感器B4S1
@property (nonatomic, strong) NSString * car_oxygenSensorB4S1;
/// 氧传感器B4S2
@property (nonatomic, strong) NSString * car_oxygenSensorB4S2;
/// 三元催化b1s1
@property (nonatomic, strong) NSNumber *car_catalystTempB1s1;
/// 三元催化b1s2
@property (nonatomic, strong) NSNumber *car_catalystTempB1s2;
/// 三元催化b2s1
@property (nonatomic, strong) NSNumber *car_catalystTempB2s1;
/// 三元催化b2s2
@property (nonatomic, strong) NSNumber *car_catalystTempB2s2;
/// EGR指令开度
@property (nonatomic, strong) NSNumber * car_EGR;
/// 蒸发清除开度
@property (nonatomic, strong) NSNumber * car_evaporationClearance;
/// 油箱剩余油量
@property (nonatomic, strong) NSNumber * car_residualOil;
/// 蒸发系统蒸汽压力
@property (nonatomic, strong) NSNumber * car_vapoTension;
/// 油门踏板的位置
@property (nonatomic, strong) NSNumber * car_throttlePedalPosition;
/// 油门踏板的相对位置
@property (nonatomic, strong) NSNumber * car_throttlePedalAcceleratorPosition;


@property (nonatomic, strong) NSDictionary *inspactionData;

#pragma mark -

+ (instancetype)sharedManager;

+ (NSString *)keyForOBDCode:(NSString *)obdCode;

/// 字符串转化为16进制
+ (NSString *)hexStringFromString:(NSString *)string;
+ (NSString *)representativeStringWithUUID:(CBUUID*)uuid;
+ (NSData*)hexToBytesWithString:(NSString *)string;

+ (NSString *)stringWithData:(NSData *)data;
///  十六进制转换ascii
+ (NSString *)hexCodeToString:(NSString *)hexCode;
+ (NSString *)obdQuickCommand:(NSString *)command;
/// 十六进制转换为float
+ (float)floatFromString:(NSString *)string;
/// 获得数据头
+ (NSString *)validValueWithValue:(NSString *)value command:(NSString *)command;

/// 通过进气辆计算油耗
+ (float)basicFuelConsumptionWithAirIntask:(float)airIntask;
+ (float)displayFuelConsumptionWithAirIntask:(float)airIntask;
/// 获取里程
- (void)getMileage;
/// 获取坐标
- (void)getCurrentLocation;
/// 获取体分数和信息
- (NSDictionary *)getCheckUpScoreAndMessage;
/// 获得平均油耗
- (NSNumber *)getAverageFuel;
/// 开始一段新行程
- (void)tripStart;
/// 结束当前行程
- (void)tripEnd;
/// 保存停车信息
- (void)saveParkingTimeWithTimeLimit:(BOOL)timeLimit;
/// 获得车况数据的JSON字符串
- (NSString *)getCarStatusValueJSON:(NSDictionary *)valueTimeMap withAllItems:(BOOL)allItems;
/** 
 车况数据上传  车辆启动，结束，怠速取得的车况报告数据 type为自动手动判断
 0: 自动体检
 1: 手动体检
 2: 启动时自检（只上传不显示
 */
- (void)uploadCarStatusWithType:(int)type trackID:(NSString *)trackID Delegate:(id<ServerAdaptorDelegateProtocol>)delegate;
/// 保存车辆体检信息
- (void)saveCarSelectedStatusToDatabaseWithAllItems:(BOOL)allItems
                                       valueTimeMap:(NSDictionary *)valueTimeMap
                                       withDelegate:(id<ServerAdaptorDelegateProtocol>)delegate;

/// 保存选中信息
- (void)saveCarSelectedStatusToDatabaseWithAllItems:(BOOL)allItems withDelegate:(id<ServerAdaptorDelegateProtocol>)delegate;
#pragma mark - 验证
+ (BOOL)valueIsEqualCommand:(NSString *)value;
@end
