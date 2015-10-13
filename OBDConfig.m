//
//  OBDParse.m
//  CarcoreBTTest
//
//  Created by Besprout's Mac Mini on 15/5/21.
//  Copyright (c) 2015年 Fang Zijian. All rights reserved.
//

#import "OBDConfig.h"
#import "CarcoreDataManager.h"

NSString *const kCarcoreOBDName = @"CarCore-Air"; // @"CarCore-Air";//@"gooddriver"


NSString *const ISSC_PROPRIETARY_SERVICE = @"49535343-FE7D-4AE5-8FA9-9FAFD205E455";
// ISSC的专有特性
NSString *const ISSC_UPDATE_CONNECTION_PARAMETER = @"49535343-6DAA-4D02-ABF6-19569ACA69FE";
NSString *const ISSC_AIR_PATCH = @"49535343-ACA3-481C-91EC-D85E28A60318";
// 输入流
NSString *const ISSC_TRANS_RX = @"FFF2";
// 输出流
NSString *const ISSC_TRANS_TX = @"FFF1";

// 错误协议类型
NSString *const C_FAULT_AGREEMENT           = @"ATDP";

NSString *const C_VIN_CODE                  = @"0902";
NSString *const C_CAR_AGREEMENT_SUPPORT     = @"ATSP0";
NSString *const C_CAR_SPEED                 = @"010D";
NSString *const C_ENGINE_LOAD               = @"0104";

NSString *const C_INTAKE_FLOW               = @"0110"; // 进气流量 g/s
NSString *const C_INTAKE_AIR_TEMP           = @"010F";
NSString *const C_INTAKE_AIR_PRESURE        = @"010B"; // 进气压力kPa
NSString *const C_FAULT_CODE_READING        = @"0101"; // 故障码解读
NSString *const C_FAULT_DETAIL_READING      = @"03";
NSString *const C_ENGINE_RPM                = @"010C";// ((A*256)+B)/4 发动机转数RPM

NSString *const C_ENGINE_RUNTIME            = @"011F";

NSString *const C_THROTTLE                  = @"0111";

NSString *const C_HEALTH_BATTERY_VOLTAGE    = @"ATRV";
NSString *const C_ENGINE_COOLANT_TEMP       = @"0105"; // A-40 冷却剂温度℃

//			VOLTAGE = "ATRV", // 电瓶电压
//			ENGINE_LOAD = "0104", // A*100/255 发动机负荷%

NSString *const ENGINE_RPM              = @"010C";
NSString *const VEHICLE_SPEED           = @"010D"; // A 车速 Km/h
//			INTAKE_AIR_TEMP = "010F", // A-40 进气温度℃

//			CATALYST_TEMP_B2S1 = "013D",
//			CATALYST_TEMP_B1S2 = "013E",
//			CATALYST_TEMP_B2S2 = "013F",

NSString *const CONT_MODULE_VOLT        = @"0142"; // ((A*256)+B)/1000 OBD控制电压 V
NSString *const AMBIENT_AIR_TEMP        = @"0146"; // A-40 出气温度℃
NSString *const ENGINE_OIL_TEMP         = @"015C"; // A-40 机油温度℃


NSString *const kCAR_CHECKUP_ITEMS = @"kCAR_CHECKUP_ITEMS";

#pragma mark - 体检项目
NSString *const C_FUEL_PRESSURE                 = @"010A";
NSString *const C_Angle_Of_Ignition_Advance     = @"010E";
NSString *const C_Oxygen_Sensor_Position        = @"0113";
NSString *const C_Oxygen_Sensor_Voltage_Cylinder1_Sensor1 = @"0114";
NSString *const C_Oxygen_Sensor_Voltage_Cylinder1_Sensor2 = @"0115";
NSString *const C_Oxygen_Sensor_Voltage_Cylinder1_Sensor3 = @"0116";
NSString *const C_Oxygen_Sensor_Voltage_Cylinder1_Sensor4 = @"0117";
NSString *const C_Oxygen_Sensor_Voltage_Cylinder2_Sensor1 = @"0118";
NSString *const C_Oxygen_Sensor_Voltage_Cylinder2_Sensor2 = @"0119";
NSString *const C_Oxygen_Sensor_Voltage_Cylinder2_Sensor3 = @"011A";
NSString *const C_Oxygen_Sensor_Voltage_Cylinder2_Sensor4 = @"011B";
#pragma mark 相对歧管真空油轨压力
NSString *const C_Vacuum_Oil_Pressure = @"0122";
#pragma mark 氧传感器
NSString *const Oxygen_Sensor_B1S1 = @"0124";
NSString *const Oxygen_Sensor_B1S2 = @"0125";
NSString *const Oxygen_Sensor_B2S1 = @"0126";
NSString *const Oxygen_Sensor_B2S2 = @"0127";
NSString *const Oxygen_Sensor_B3S1 = @"0128";
NSString *const Oxygen_Sensor_B3S2 = @"0129";
NSString *const Oxygen_Sensor_B4S1 = @"012A";
NSString *const Oxygen_Sensor_B4S2 = @"012B";
#pragma mark  三元催化剂温度
NSString *const CATALYST_TEMP_B1S1      = @"013C"; // (((A*256)+B)/10)-40 三元催化剂温度℃
NSString *const CATALYST_TEMP_B1S2      = @"013D"; // (((A*256)+B)/10)-40 三元催化剂温度℃
NSString *const CATALYST_TEMP_B2S1      = @"013E"; // (((A*256)+B)/10)-40 三元催化剂温度℃
NSString *const CATALYST_TEMP_B2S2      = @"013F"; // (((A*256)+B)/10)-40 三元催化剂温度℃
#pragma mark EGR指令开度
NSString *const C_EGR = @"012C";
#pragma mark 蒸发清除开度
NSString *const C_Evaporation_Clearance = @"012E";
#pragma mark 油箱剩余油量
NSString *const C_Residual_Oil = @"012F";
#pragma mark 蒸发系统蒸汽压力
NSString *const C_Vapo_Tension = @"0154";
#pragma mark 油门踏板的位置
NSString *const C_Throttle_Pedal_Position = @"014B";
#pragma mark 油门踏板的相对位置
NSString *const C_Throttle_Pedal_Accelerator_Position = @"015A";
#pragma mark  短期燃油校正(1，3)
NSString *const C_Short_Term_Fuel_Correction13 = @"0106";
#pragma mark  长期燃油校正(1，3)
NSString *const C_Long_Term_Fuel_Correction13 = @"0107";
#pragma mark  短期燃油校正(2，4)
NSString *const C_Short_Term_Fuel_Correction24 = @"0108";
#pragma mark  长期燃油校正(2，4)
NSString *const C_Long_Term_Fuel_Correction24 = @"0109";


#pragma mark -


@implementation OBDConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
//        _transferCommands = [[NSMutableArray alloc] initWithObjects:/*C_FAULT_CODE_READING,*/C_ENGINE_RPM,C_CAR_SPEED,C_ENGINE_LOAD,C_INTAKE_FLOW, nil];
    }
    return self;
}

+ (NSArray *)initializeCommands
{
    return @[@"ATZ",@"ATE0",@"ATL0"/*, @"ATE0"*/, @"ATM0", @"ATS0", @"ATH0",@"ATAT1",C_CAR_AGREEMENT_SUPPORT,@"0100"];
//    return @[@"ATZ", @"ATE0", @"ATE0", @"ATM0", @"ATL0", @"ATS0", @"AT@1", @"ATI", @"ATH0",@"ATAT1",@"ATSP0",@"0100", @"ATH1", @"ATDPN", @"0100", @"ATH0", @"0100", @"0120", @"0902", @"010D", @"0101", @"0101"];
}

+ (NSDictionary *)OBDListDictionary
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"OBDCodeList" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    return data;
}

+ (CarCheckUpItem *)itemWithOBDCode:(NSString *)obdCode
{
    NSDictionary *dic = [OBDConfig OBDListDictionary];
    NSDictionary *obdDic = dic[obdCode];
    return [CarCheckUpItem itemWithSystemName:obdDic[@"system"]?obdDic[@"system"]:@""
                                        Title:obdDic[@"description"]?obdDic[@"description"]:@""
                                         code:obdCode
                                     valueKey:obdDic[@"data_key"]?obdDic[@"data_key"]:@""
                                          max:[obdDic[@"max"] floatValue]
                                          min:[obdDic[@"min"] floatValue]
                                         unit:obdDic[@"unit"]?obdDic[@"unit"]:@""
                                       dataId:[NSString stringWithFormat:@"%d",[obdDic[@"dataId"] intValue]]];
}


+ (NSArray *)basicCommandsWithIntakeFlowNotSupport:(BOOL)isNoSupport
{
//    return @[C_FAULT_CODE_READING,C_ENGINE_RPM,C_CAR_SPEED,C_ENGINE_LOAD,C_INTAKE_FLOW,C_INTAKE_AIR_TEMP,C_INTAKE_AIR_PRESURE];
    return @[C_FAULT_CODE_READING,C_HEALTH_BATTERY_VOLTAGE,C_CAR_SPEED,C_ENGINE_COOLANT_TEMP,C_ENGINE_RPM,C_THROTTLE,C_ENGINE_LOAD,C_Angle_Of_Ignition_Advance,C_INTAKE_FLOW,CATALYST_TEMP_B1S1,C_INTAKE_AIR_PRESURE,C_Oxygen_Sensor_Voltage_Cylinder1_Sensor1,C_Oxygen_Sensor_Voltage_Cylinder1_Sensor2,C_FUEL_PRESSURE,C_Short_Term_Fuel_Correction13,C_Long_Term_Fuel_Correction13,C_INTAKE_AIR_TEMP,C_Vapo_Tension,C_EGR,C_Throttle_Pedal_Position];

}

- (NSArray *)basicCommands
{
    return [OBDConfig basicCommandsWithIntakeFlowNotSupport:[CarcoreOBDManager sharedManager].isNoSupportIntaskFlow];
}

+ (NSArray *)basicInspectionCommands
{
    // 缺少瞬时油耗
    return @[C_HEALTH_BATTERY_VOLTAGE,C_ENGINE_COOLANT_TEMP,C_ENGINE_LOAD,C_FAULT_CODE_READING,C_CAR_SPEED,C_ENGINE_RPM,C_THROTTLE,C_Angle_Of_Ignition_Advance,C_INTAKE_FLOW,CATALYST_TEMP_B1S1,C_INTAKE_AIR_PRESURE,C_Oxygen_Sensor_Voltage_Cylinder1_Sensor1,C_Oxygen_Sensor_Voltage_Cylinder1_Sensor2,C_FUEL_PRESSURE,C_Short_Term_Fuel_Correction13,C_Long_Term_Fuel_Correction13,C_INTAKE_AIR_TEMP,C_EGR,C_Throttle_Pedal_Position,C_Residual_Oil];
}

// 体检项目为所有项目数据
- (NSArray *)vehicleInspectionCommands
{
    if (!_vehicleInspectionCommands) {
        NSDictionary *allCommandsList = [OBDConfig OBDListDictionary];
        NSArray *keys = [allCommandsList allKeys];
        NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            return [obj1 compare:obj2 options:NSNumericSearch];
        }];
        
        NSMutableArray *tarArray = [[NSMutableArray alloc] initWithArray:sortedArray];
        for (int i = 0; i < [tarArray count] ; i++) {
            for (int j = 0; j < [tarArray count]-1-i; j++) {
                float num1 = (float)strtoul([tarArray[j] UTF8String],0,16);
                float num2 = (float)strtoul([tarArray[j+1] UTF8String],0,16);
                if (num1 > num2) {
                    NSString *temp;
                    temp = tarArray[j];
                    tarArray[j] = tarArray[j+1];
                    tarArray[j+1] = temp;
                }
            }
        }
        
        NSMutableArray *arr = [NSMutableArray array];
        for (NSString *code in tarArray) {
            NSDictionary *dic = allCommandsList[code];
            CarCheckUpItem *item = [CarCheckUpItem itemWithSystemName:dic[@"system"]
                                                                Title:dic[@"description"]
                                                                 code:code
                                                             valueKey:dic[@"value"]
                                                                  max:[dic[@"max"] floatValue]
                                                                  min:[dic[@"min"] floatValue]
                                                                 unit:dic[@"unit"]
                                                               dataId:[NSString stringWithFormat:@"%d",[dic[@"dataId"] intValue]]];
            [arr addObject:item.obdCode];
        }
        _vehicleInspectionCommands = [NSArray arrayWithArray:arr];
    }

    
    return _vehicleInspectionCommands;
}

- (NSArray *)transferCommands
{
//    if ([CarcoreDataManager sharedManager].currentTrackInfo == nil){
//    return @[C_FAULT_CODE_READING,C_ENGINE_RPM];
//    }
    NSMutableArray *arr;
    
    switch (self.commandContain) {
        case OBDCommandContainBasic:
            arr = [NSMutableArray arrayWithArray:self.basicCommands];
            break;
        case OBDCommandContainInspection:
//            arr = [NSMutableArray arrayWithArray:self.vehicleInspectionCommands];
            arr = [NSMutableArray arrayWithArray:[OBDConfig basicInspectionCommands]];
            break;
        case OBDCommandContainCarStatus:
            arr = [NSMutableArray arrayWithObject:C_FAULT_CODE_READING];
            [arr addObjectsFromArray:[OBDConfig carStatusLibrary]];//[NSMutableArray arrayWithArray:[OBDConfig carStatusLibrary]];
            break;
        case OBDCommandContainCarDetailItems:
            arr = [NSMutableArray arrayWithArray:self.carCheckUpSelectedLibrary];
            break;
        case OBDCommandContainFault:
            arr = [NSMutableArray arrayWithObject:C_FAULT_DETAIL_READING];
            break;
        default:
            arr = [NSMutableArray array];
            break;
    }
    return arr;
}

#pragma mark - 改变命令
+ (NSString *)initializeCommandsWithIndex:(NSInteger)index
{
    NSArray *arr = [self initializeCommands];
    return arr[index];
}

- (NSArray *)toubleCode
{
    return @[@"P",@"C",@"B",@"U"];
}

#pragma mark - 车辆状态

+ (NSArray *)carStatusLibrary
{
    return @[C_HEALTH_BATTERY_VOLTAGE,C_ENGINE_COOLANT_TEMP,C_THROTTLE,C_ENGINE_RPM,CATALYST_TEMP_B1S1];
}

#pragma mark - 体检项目

- (void)resetCarCheckUpSelectedLibrary
{
    _carCheckUpSelectedLibrary = nil;
    if (!_carCheckUpSelectedLibrary) {
        NSString *checkUpString = [AppContants valueForKey:kCAR_CHECKUP_ITEMS];
        if (checkUpString == nil) {
            _carCheckUpSelectedLibrary = [self vehicleInspectionItemsLibrary];
        }else if([checkUpString length] == 0){
            _carCheckUpSelectedLibrary = [[NSArray alloc] init];
        }else{
            NSArray *arr = [checkUpString componentsSeparatedByString:@";"];
            if (arr != nil) {
                _carCheckUpSelectedLibrary = [[NSArray alloc] initWithArray:arr];
            }else{
                _carCheckUpSelectedLibrary = [[NSArray alloc] initWithArray:[OBDConfig basicInspectionCommands]];
            }
        }
    }
}

- (NSArray *)carCheckUpSelectedLibrary
{
    if (!_carCheckUpSelectedLibrary) {
        NSString *checkUpString = [AppContants valueForKey:kCAR_CHECKUP_ITEMS];
        if (checkUpString == nil) {
            _carCheckUpSelectedLibrary = [self basicCommands];
        }else if ([checkUpString length] == 0){
            _carCheckUpSelectedLibrary = [[NSArray alloc] init];
        }
        else{
            NSArray *arr = [checkUpString componentsSeparatedByString:@";"];
            if (arr != nil) {
                _carCheckUpSelectedLibrary = [[NSArray alloc] initWithArray:arr];
            }else{
                _carCheckUpSelectedLibrary = [self vehicleInspectionItemsLibrary];
            }
        }
    }
    return _carCheckUpSelectedLibrary;
}

+ (NSArray *)getCheckUpItemsArrayFromCodeArray:(NSArray *)codeArray
{
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSString *code in codeArray) {
        for (NSString *item in [OBDConfig vehicleInspectionAllItemsLibrary]) {
            if (codeIsEqualTo(code,item)) {
                [tempArray addObject:item];
            }
        }
    }
    
    return tempArray;
}

bool codeIsEqualTo(NSString *code,NSString *targetCode)
{
    return [code isEqualToString:targetCode];
}

+ (NSArray *)vehicleInspectionAllItemsLibrary
{
    return @[
             [CarCheckUpItem itemWithSystemName:@"电源系统" Title:@"电池电压" code:C_HEALTH_BATTERY_VOLTAGE valueKey:@"car_batteryVoltage" max:15.0f min:0 unit:@"V" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"冷却系统" Title:@"冷却液温度" code:C_ENGINE_COOLANT_TEMP valueKey:@"obd_engineCoolantTemp" max:100.0f min:-40 unit:@"℃" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"怠速系统" Title:@"发动机转速" code:C_ENGINE_RPM valueKey:@"obd_engineRPM" max:8000 min:0 unit:@"rpm" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"进气系统" Title:@"节气门开度" code:C_THROTTLE valueKey:@"car_throttle" max:100 min:0 unit:@"\%" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"驾驶系统" Title:@"行驶速度" code:C_CAR_SPEED valueKey:@"obd_speed" max:255 min:0 unit:@"km/h" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"发动机负荷" Title:@"发动机负荷" code:C_ENGINE_LOAD valueKey:@"obd_engineLoad" max:100.0f min:0 unit:@"\%" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"驾驶系统" Title:@"瞬时油耗" code:@"Instant_Fuel_Consumption" valueKey:@"obd_fuelCount" max:100.0f min:0 unit:[CarcoreDataManager sharedManager].obd_speed>0?@"L/100KM":@"L/H" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"进气系统" Title:@"进气温度" code:C_INTAKE_AIR_TEMP valueKey:@"obd_intaskAirTemp" max:110.0f min:0 unit:@"℃" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"进气系统" Title:@"进气流量" code:C_INTAKE_FLOW valueKey:@"obd_airIntask" max:500.0 min:0 unit:@"g/s" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"进气系统" Title:@"进气压力" code:C_INTAKE_AIR_PRESURE valueKey:@"obd_intaskAirPresure" max:500.0 min:0 unit:@"Kpa" dataId:@""],
              [CarCheckUpItem itemWithSystemName:@"体检" Title:@"燃油压力" code:C_FUEL_PRESSURE valueKey:@"car_fuelPressure" max:100.0 min:0 unit:@"Kpa" dataId:@""],
            [CarCheckUpItem itemWithSystemName:@"体检" Title:@"点火提前角" code:C_Angle_Of_Ignition_Advance valueKey:@"car_angleOfIgnitionAdvance" max:100.0 min:0 unit:@"" dataId:@""],
              [CarCheckUpItem itemWithSystemName:@"体检" Title:@"氧传感器位置" code:C_Oxygen_Sensor_Position valueKey:@"car_oxygenSensorPosition" max:100.0 min:0 unit:@"" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"缸组1传感器1氧传感器电压" code:C_Oxygen_Sensor_Voltage_Cylinder1_Sensor1 valueKey:@"car_oxygenSensorVoltageCylinder1Sensor1" max:100.0 min:0 unit:@"" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"缸组1传感器2氧传感器电压" code:C_Oxygen_Sensor_Voltage_Cylinder1_Sensor2 valueKey:@"car_oxygenSensorVoltageCylinder1Sensor2" max:100.0 min:0 unit:@"" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"缸组1传感器3氧传感器电压" code:C_Oxygen_Sensor_Voltage_Cylinder1_Sensor3 valueKey:@"car_oxygenSensorVoltageCylinder1Sensor3" max:100.0 min:0 unit:@"" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"缸组1传感器4氧传感器电压" code:C_Oxygen_Sensor_Voltage_Cylinder1_Sensor4 valueKey:@"car_oxygenSensorVoltageCylinder1Sensor4" max:100.0 min:0 unit:@"" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"缸组2传感器1氧传感器电压" code:C_Oxygen_Sensor_Voltage_Cylinder2_Sensor1 valueKey:@"car_oxygenSensorVoltageCylinder2Sensor1" max:100.0 min:0 unit:@"" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"缸组2传感器2氧传感器电压" code:C_Oxygen_Sensor_Voltage_Cylinder2_Sensor2 valueKey:@"car_oxygenSensorVoltageCylinder2Sensor2" max:100.0 min:0 unit:@"" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"缸组2传感器3氧传感器电压" code:C_Oxygen_Sensor_Voltage_Cylinder2_Sensor3 valueKey:@"car_oxygenSensorVoltageCylinder2Sensor3" max:100.0 min:0 unit:@"" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"缸组2传感器4氧传感器电压" code:C_Oxygen_Sensor_Voltage_Cylinder2_Sensor4 valueKey:@"car_oxygenSensorVoltageCylinder2Sensor4" max:100.0 min:0 unit:@"" dataId:@""],
              [CarCheckUpItem itemWithSystemName:@"体检" Title:@"相对歧管真空油轨压力" code:C_Vacuum_Oil_Pressure valueKey:@"car_vacuumOilPressure" max:100.0 min:0 unit:@"kpa" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"氧传感器B1S1" code:Oxygen_Sensor_B1S1 valueKey:@"car_oxygenSensorB1S1" max:100.0 min:0 unit:@"kpa" dataId:@""],
              [CarCheckUpItem itemWithSystemName:@"体检" Title:@"氧传感器B1S2" code:Oxygen_Sensor_B1S2 valueKey:@"car_oxygenSensorB1S2" max:100.0 min:0 unit:@"kpa" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"氧传感器B2S1" code:Oxygen_Sensor_B2S1 valueKey:@"car_oxygenSensorB2S1" max:100.0 min:0 unit:@"kpa" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"氧传感器B2S2" code:Oxygen_Sensor_B2S2 valueKey:@"car_oxygenSensorB2S2" max:100.0 min:0 unit:@"kpa" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"氧传感器B3S1" code:Oxygen_Sensor_B3S1 valueKey:@"car_oxygenSensorB3S1" max:100.0 min:0 unit:@"kpa" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"氧传感器B3S2" code:Oxygen_Sensor_B3S2 valueKey:@"car_oxygenSensorB3S2" max:100.0 min:0 unit:@"kpa" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"氧传感器B4S1" code:Oxygen_Sensor_B4S1 valueKey:@"car_oxygenSensorB4S1" max:100.0 min:0 unit:@"kpa" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"氧传感器B4S2" code:Oxygen_Sensor_B4S2 valueKey:@"car_oxygenSensorB4S2" max:100.0 min:0 unit:@"kpa" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"排放系统" Title:@"三元催化剂温度B1S1" code:CATALYST_TEMP_B1S1 valueKey:@"car_catalystTempB1s1" max:850 min:0 unit:@"℃" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"排放系统" Title:@"三元催化剂温度B1S2" code:CATALYST_TEMP_B1S2 valueKey:@"car_catalystTempB1s2" max:850 min:0 unit:@"℃" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"排放系统" Title:@"三元催化剂温度B2S1" code:CATALYST_TEMP_B2S1 valueKey:@"car_catalystTempB2s1" max:850 min:0 unit:@"℃" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"排放系统" Title:@"三元催化剂温度B2S2" code:CATALYST_TEMP_B2S2 valueKey:@"car_catalystTempB2s2" max:850 min:0 unit:@"℃" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"EGR指令开度" code:C_EGR valueKey:@"car_EGR" max:850 min:0 unit:@"" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"油箱剩余油量" code:C_Residual_Oil valueKey:@"car_residualOil" max:850 min:0 unit:@"L" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"蒸发系统蒸汽压力" code:C_Vapo_Tension valueKey:@"car_vapoTension" max:100 min:0 unit:@"Kpa" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"油门踏板的位置" code:C_Throttle_Pedal_Position valueKey:@"car_throttlePedalPosition" max:100 min:0 unit:@"" dataId:@""],
              [CarCheckUpItem itemWithSystemName:@"体检" Title:@"油门的相对位置" code:C_Throttle_Pedal_Position valueKey:@"car_throttlePedalPosition" max:100 min:0 unit:@"" dataId:@""],
             [CarCheckUpItem itemWithSystemName:@"体检" Title:@"蒸发清除开度" code:C_Evaporation_Clearance valueKey:@"car_evaporationClearance" max:100 min:0 unit:@"%" dataId:@""],
             ];
}

- (NSArray *)vehicleInspectionItemsLibrary
{
    return self.vehicleInspectionCommands;
}
@end
