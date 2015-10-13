//
//  CarcoreDataManager.m
//  CarcoreBTTest
//
//  Created by Besprout's Mac Mini on 15/5/19.
//  Copyright (c) 2015年 Fang Zijian. All rights reserved.
//

#import "CarcoreDataManager.h"
#import "JSONKit.h"

#define AccelerationThreshold 1

@implementation SharpTurnData


+ (SharpTurnData *)dataWithParameter:(SharpTurnParameter)parameter
{
    SharpTurnData *data = [[SharpTurnData alloc] init];
    data.parameter = parameter;
    return data;
}

@end

@implementation CarcoreDataManager

+ (instancetype)sharedManager {
    static CarcoreDataManager *sharedDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataManager = [[self alloc] init];
    });
    return sharedDataManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
        _sharpTurnDataArray = [[NSMutableArray alloc] init];
        _fuelScoreArray = [[NSMutableArray alloc] init];
//        _inspactionData = [NSMu]
        [self checkMotion];
    }
    return self;
}

+ (NSString *)keyForOBDCode:(NSString *)obdCode
{
    if ([obdCode isEqualToString:C_CAR_SPEED]) {
        return @"obd_speed";
    }else if ([obdCode isEqualToString:C_ENGINE_COOLANT_TEMP]) {
        return @"obd_engineCoolantTemp";
    }else if ([obdCode isEqualToString:C_ENGINE_LOAD]) {
        return @"obd_engineLoad";
    }else if ([obdCode isEqualToString:C_ENGINE_RPM]) {
        return @"obd_engineRPM";
    }else if ([obdCode isEqualToString:C_ENGINE_RUNTIME]) {
        return @"obd_engineRuntime";
    }else if ([obdCode isEqualToString:C_HEALTH_BATTERY_VOLTAGE]) {
        return @"car_batteryVoltage";
    }else if ([obdCode isEqualToString:C_INTAKE_AIR_TEMP]) {
        return @"obd_intaskAirTemp";
    }else if ([obdCode isEqualToString:C_INTAKE_FLOW]) {
        return @"obd_airIntask";
    }else if ([obdCode isEqualToString:C_THROTTLE]) {
        return @"car_throttle";
    }else if ([obdCode isEqualToString:@"Instant_Fuel_Consumption"])
    {
        return @"obd_instantFuelConsumption";
    }else if ([obdCode isEqualToString:C_INTAKE_AIR_PRESURE])
    {
        return @"obd_intaskAirPresure";
    }else if ([obdCode isEqualToString:CATALYST_TEMP_B1S1])
    {
        return @"car_catalystTempB1s1";
    }
    return @"";
}

+ (NSString *)hexStringFromString:(NSString *)string
{
//    int asciiCode = [string characterAtIndex:0]; // 65
    NSData *myD = [string dataUsingEncoding:NSASCIIStringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr]; 
    } 
    return hexStr; 
}

+ (NSString *)representativeStringWithUUID:(CBUUID*)uuid;
{
    NSData *data = [uuid data];
    
    NSUInteger bytesToConvert = [data length];
    const unsigned char *uuidBytes = [data bytes];
    NSMutableString *outputString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
    {
        switch (currentByteIndex)
        {
            case 3:
            case 5:
            case 7:
            case 9:[outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]]; break;
            default:[outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
        }
        
    }
    
    return outputString;
}

+ (NSData*)hexToBytesWithString:(NSString *)string{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= string.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [string substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

+ (NSString *)stringWithData:(NSData *)data
{
    NSMutableData *tempData = [[NSMutableData alloc] initWithData:data];
    int loc = 0;
    while (loc < [data length]) {
        char buffer;
        [data getBytes:&buffer range:NSMakeRange(loc, 1)];
        if (buffer == 0x0d || buffer == 0x0a) {
            [tempData replaceBytesInRange:NSMakeRange(loc, 1) withBytes:nil length:1];
        }
        loc++;
    }
    int tempLoc = 0;
    NSMutableString *mStr = [[NSMutableString alloc] init];
    while (tempLoc < [tempData length]) {
        char buffer;
        [tempData getBytes:&buffer range:NSMakeRange(tempLoc, 1)];
        if (buffer != 0x00) {
            NSString *atempStr = [[NSString alloc] initWithBytes:&buffer length:1 encoding:NSUTF8StringEncoding];
            [mStr safe_appendString:atempStr];
        }
        tempLoc++;
    }
    return mStr;
    
//    int okDataLength = (int)[data length];
//    const uint8_t *bytes = (const uint8_t*)[data bytes];
//    NSString *s = [[NSString alloc] initWithBytes:bytes
//                                           length:[data length]
//                                         encoding:NSUTF8StringEncoding];
//
//    return s;

}

+ (NSString *)hexCodeToString:(NSString *)hexCode
{
    NSMutableString * newString = [[NSMutableString alloc] init];

    @try {
        int i = 0;
        while (i < [hexCode length])
        {
            NSString * hexChar = [hexCode substringWithRange: NSMakeRange(i, 2)];
            int value = 0;
            sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
            [newString appendFormat:@"%c", (char)value];
            i+=2;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"warning 解析字符串%@错误:%@,",hexCode,exception.reason);
        newString = [NSMutableString stringWithFormat:@""];
    }
    @finally {
        return newString;

    }
    

}

+ (NSString *)obdQuickCommand:(NSString *)command
{
    if ([command hasPrefix:@"A"]) {
        return command;
    }else if ([command isEqualToString:C_FAULT_CODE_READING])
    {
        return command;
    }
    
    return [NSString stringWithFormat:@"%@",command];
}

+ (float)floatFromString:(NSString *)string
{
    float num = (float)strtoul([string UTF8String],0,16);

    return num;
}

+ (NSString *)validValueWithValue:(NSString *)value command:(NSString *)command
{
    NSString *validValue = [value substringWithRange:NSMakeRange(command.length, value.length - command.length)];
    validValue = [validValue stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    return validValue;
}

#pragma mark - Server delegate
- (void)doFinished:(NSString *)status action:(NSString *)action withMessage:(NSString *)message withData:(id)data
{
    if ([status isEqualToString:kOkCode]) {
        if ([action isEqualToString:kExaminationUpload]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DataManagerActionDetailDidChange object:nil];
        }else if ([action isEqualToString:kHomeTimeLineAdd] ){
            [[NSNotificationCenter defaultCenter] postNotificationName:DataManagerActionDetailDidChange object:nil];
        }
    }
}

#pragma mark - Motion
- (void)checkMotion
{
    // 加速度器的检测
    if ([self.motionManager isAccelerometerAvailable]){
        NSLog(@"Accelerometer is available.");
        self.motionManager.accelerometerUpdateInterval = 1.8;
        _motionQueue = [[NSOperationQueue alloc] init];
    }
}

- (void)startAccelerometerUpdates
{
    @try {
        [self.motionManager startAccelerometerUpdatesToQueue: _motionQueue
                                                 withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                     
                                                     if (self.obd_engineRPM > 0 && self.obd_speed > 0) {
                                                         [self isSharpTurnWithAcceleration:accelerometerData.acceleration speed:[self.obd_speed floatValue]];
                                                     }
                                                 }];
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)stopAccelerometerUpdates
{
    [self.motionManager stopAccelerometerUpdates];
}

- (BOOL)isSharpTurnWithAcceleration:(CMAcceleration)acceleration speed:(float)speed
{
    @try {
        if ([self.sharpTurnDataArray count] >= 3) {
            [self.sharpTurnDataArray safe_removeObjectAtIndex:0];
        }
        SharpTurnData *data = [SharpTurnData dataWithParameter:SharpTurnParameterMake(speed, acceleration)];
        [self.sharpTurnDataArray addObject:data];
        
        if ([self.sharpTurnDataArray count] < 3) {
            return NO;
        }
        
        SharpTurnData *data1 = self.sharpTurnDataArray[self.sharpTurnDataArray.count-3];
        SharpTurnData *data2 = self.sharpTurnDataArray[self.sharpTurnDataArray.count-2];
        SharpTurnData *data3 = self.sharpTurnDataArray[self.sharpTurnDataArray.count-1];
        
        // 加速度1
        int a1 = sqrtf((powf(data1.parameter.acceleration.x, 2)+powf(data1.parameter.acceleration.y, 2)+powf(data1.parameter.acceleration.z, 2) ));
        // 加速度2
        int a2 = sqrtf((powf(data2.parameter.acceleration.x, 2)+powf(data2.parameter.acceleration.y, 2)+powf(data2.parameter.acceleration.z, 2) ));
        // 加速度3
        int a3 = sqrtf((powf(data3.parameter.acceleration.x, 2)+powf(data3.parameter.acceleration.y, 2)+powf(data3.parameter.acceleration.z, 2) ));
        if (a1 > AccelerationThreshold && a2 > AccelerationThreshold && a3 > AccelerationThreshold) {
            BOOL b1 = (data2.parameter.speed - data1.parameter.speed) >= (MIN(a2, a1)*1.8);
            BOOL b2 = (data3.parameter.speed - data2.parameter.speed) >= (MIN(a3, a2)*1.8);
            if (b1 == NO || b2 == NO) {
                self.obd_sharpTurnTimes = @([self.obd_sharpTurnTimes intValue] + 1);
            }
        }

    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    return NO;
}

#pragma mark - Calculation
/**
 瞬时油耗
 进气量/14.64/0.725*3.6  结果是升/小时
 统计油耗
 Σ瞬时油耗 1s累加 && 修正系数（测试）
 */

+ (float)basicFuelConsumptionWithAirIntask:(float)airIntask
{
    float o = airIntask/14.64/0.725*3.6;

    return o;
}

+ (float)displayFuelConsumptionWithAirIntask:(float)airIntask
{
    float o = [CarcoreDataManager basicFuelConsumptionWithAirIntask:airIntask];//airIntask/2.948;
    float speed = [[CarcoreDataManager sharedManager].obd_speed floatValue];
    if (speed > 0) {
        return (o*100/speed);
    }
    return o;
}

- (void)setObd_speed:(NSNumber *)obd_speed
{
    self.obd_averageSpeed = @(([_obd_averageSpeed floatValue] + [obd_speed floatValue])/2.00);
    if (([obd_speed floatValue] - [_obd_speed floatValue]) > 15) {
        if (self.runningStatus != CarRunningStatusHeavyAccel) {
            self.runningStatus = CarRunningStatusHeavyAccel;
            _obd_heavyAccelTimes = @([_obd_heavyAccelTimes intValue] + 1);
        }
    }else if(([_obd_speed floatValue] - [obd_speed floatValue]) > 25){
        if (self.runningStatus != CarRunningStatusBreak) {
            self.runningStatus = CarRunningStatusBreak;
            _obd_sharpSlowdownTimes = @([_obd_sharpSlowdownTimes intValue] +1);
        }
    }
    _obd_speed = obd_speed;
    if ([self.obd_speedMax floatValue] < [obd_speed floatValue]) {
        self.obd_speedMax = obd_speed;
    }

}

- (void)setObd_airIntask:(NSNumber *)obd_airIntask
{
    _obd_airIntask = obd_airIntask;
    float basicFuel = [CarcoreDataManager basicFuelConsumptionWithAirIntask:[_obd_airIntask floatValue]];
    self.obd_avgFuelConsumption = @(([self.obd_instantFuelConsumption floatValue] + basicFuel/2/1000.00)/2);
    self.obd_instantFuelConsumption = @(basicFuel/2/1000.00);
}

- (NSNumber *)obd_totalMileage
{
    return @([_obd_totalMileage floatValue]/1000.00);
}

- (void)getMileage
{
    self.obd_totalMileage = @([_obd_totalMileage floatValue] + [self.obd_speed floatValue]/2);

    if (self.obd_speed == 0) {
//        self.obd_zeroSpeedTimes++;
        _obd_zeroSpeedTimes = @([_obd_zeroSpeedTimes intValue] +1);
    }else if ([self.obd_speed floatValue] < 60)
    {
//        self.obd_lowSpeedTimes++;
        _obd_lowSpeedTimes = @([_obd_lowSpeedTimes intValue] + 1);
    }else if ([self.obd_speed floatValue] >= 60 && [self.obd_speed floatValue] <= 120)
    {
        _obd_normalSpeedTimes = @([_obd_normalSpeedTimes intValue] +1);
//        self.obd_normalSpeedTimes++;
    }else if ([self.obd_speed floatValue] >120)
    {
        _obd_highSpeedTimes = @([_obd_highSpeedTimes intValue]+1);
//        self.obd_highSpeedTimes++;
    }
    
    float basicFuel = [CarcoreDataManager basicFuelConsumptionWithAirIntask:[self.obd_airIntask floatValue]];
    self.obd_instantFuelConsumption = @(basicFuel/2/1000.00);
    self.obd_displayInstantFuelConsumption = @([CarcoreDataManager displayFuelConsumptionWithAirIntask:[self.obd_airIntask floatValue]]);
    self.obd_totalFuelConsumption = @([self.obd_totalFuelConsumption floatValue] + basicFuel/2/1000.00); // 单位L
//    self.obd_fuelCount ++;
    _obd_fuelCount = @([_obd_fuelCount intValue] +1);
    self.obd_totalDriverCost = @([self.obd_totalFuelConsumption floatValue]*[CUserDefaults instance].oilPrice);//self.obd_totalDriverCost + (basicFuel/1000)*[CUserDefaults instance].oilPrice;

    [self getFuelScore];
}

- (void)getFuelScore
{
    if ([self.fuelScoreCount intValue] %5 == 0) {
        float currentSpeed = [self.obd_speed floatValue];
        int score = 0;
        if (currentSpeed <= 9) {
            score = 0;
        }else if (currentSpeed >= 10 && currentSpeed <= 19)
        {
            score = ((currentSpeed - 14)*10) <0?0:((currentSpeed - 14)*10);
        }else if (currentSpeed >= 20 && currentSpeed <= 29)
        {
            if (currentSpeed <= 24) {
                score = 55 + 5*(currentSpeed - 24);
            }else{
                score =75 + (currentSpeed -24);
            }
        }else if (currentSpeed >= 30 && currentSpeed <= 39)
        {
            score = 80 + (currentSpeed - 30);
        }else if (currentSpeed >= 40 && currentSpeed <= 49)
        {
            score = 91 + (currentSpeed - 40);
        }else if (currentSpeed >= 50 && currentSpeed <= 59)
        {
            score = 100;
        }else if (currentSpeed >= 60 && currentSpeed <= 69)
        {
            score = 99 - (currentSpeed-60);
        }else if (currentSpeed >= 70 && currentSpeed <= 79)
        {
            score = 89 - (currentSpeed-70);
        }else if (currentSpeed >= 80 && currentSpeed <= 89)
        {
            score = 79 - (currentSpeed-80);
        }else if (currentSpeed >= 90 && currentSpeed <= 99)
        {
            score = 69 - (currentSpeed-90);
        }else if (currentSpeed >= 100 && currentSpeed <= 109)
        {
            score = 59 - (currentSpeed-100);
        }else if (currentSpeed >= 110 && currentSpeed <= 119)
        {
            score = 49 - (currentSpeed-110);
        }else if (currentSpeed >= 120 && currentSpeed <= 129)
        {
            score = (35 - (currentSpeed - 120)*5)<0?0:(35 - (currentSpeed - 120)*5);
        }else if (currentSpeed >= 130)
        {
            currentSpeed = 0;
        }
        
        if (score >= 0) {
            [self.fuelScoreArray addObject:[NSNumber numberWithInt:score]];
        }
    }
    
//    self.fuelScoreCount++;
    _fuelScoreCount = @([_fuelScoreCount intValue]+1);
}

- (int)getTripFuelScore
{
    int score = 0;
    int sum = 0;

    if ([self.fuelScoreArray count] > 0) {
        for (NSNumber *num in self.fuelScoreArray) {
            sum = sum + [num intValue];
        }
    }
    
    score = sum / [self.fuelScoreArray count];
    
    return score;
}

- (void)getCurrentLocation
{
    if (self.obd_speed == 0) {
        return;
    }
    
    CLLocationCoordinate2D location = [[BMKLocationServiceHelper instance] currentLocation];
    NSString *locationStr = [BMKLocationServiceHelper locationStringWithCoordinate:location];
    
    if (!self.trip_locationString) {
        _trip_locationString = [[NSMutableString alloc] init];
        [self.trip_locationString safe_appendString:locationStr];
    }else{
        if ([self.trip_locationString length] <= 0) {
            [self.trip_locationString safe_appendString:locationStr];
            
        }else{
            
            [self.trip_locationString appendFormat:@";%@",locationStr];
        }
    }
    [self setTrip_locationData:[self.trip_locationString dataUsingEncoding:NSUTF8StringEncoding]];

}

- (NSDictionary *)getCheckUpScoreAndMessage
{
    NSString *message;
    int carScore = 99;
    int faultCount = [self.obd_faultNum intValue];
    if (faultCount <= 0) {
        carScore = 99;
        message = @"状态良好，继续保持";
    }else if (faultCount == 1) {
        carScore = 90;
        message = @"车况亚健康，请联系技师检修";
    }else if (faultCount == 2) {
        carScore = 80;
        message = @"车况亚健康，建议进行相关保养";
    }else if (faultCount == 3 ||
              faultCount == 4) {
        carScore = 59;
        message = @"存在故障，建议请专家为您检修";
    }else if (faultCount > 4 && faultCount < 8) {
        carScore = (50 - (faultCount -4)*10) <0?0:(50 - faultCount*10);

    }else{
        carScore = 10;
        message = @"存在严重故障，建议到维修店检修";
    }
    return @{@"score":[NSNumber numberWithInt:carScore],@"message":message};
}

#pragma mark - 行程管理

NSNumber * floatToNumber(NSNumber *value)
{
    return value;
}

NSNumber * intToNumber(NSNumber *value)
{
    return value;
}

- (NSNumber *)getAverageFuel
{
    float avgFuelFloat = [self.obd_totalFuelConsumption floatValue]/[self.obd_fuelCount intValue];
    return floatToNumber(@(avgFuelFloat));
}

- (NSNumber *)getDriveScore
{
    int score = 100;
    int sharpSlowdownScore  = [self.obd_sharpSlowdownTimes intValue];
    int heavyAccelScore     = [self.obd_heavyAccelTimes intValue];
    int sharpTurnScore      = [self.obd_sharpTurnTimes intValue]*2;
    score = score - sharpSlowdownScore - heavyAccelScore - sharpTurnScore;
    return [NSNumber numberWithInt:score];
}

- (void)tripStart
{
    if (!self.currentTrackInfo) {
        [self cleanData];
        _currentTrackInfo = [[CDataManager sharedInstance] createNewTrackInfo];
        if (!self.currentTrackLatlngsStr) {
            _currentTrackLatlngsStr = [[NSMutableString alloc] init];
        }
    }
    [self startAccelerometerUpdates];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kTripStartRecording" object:nil];
}

- (void)tripEnd
{
    if (self.currentTrackInfo == nil) {
        return;
    }
    @try {
        [self stopAccelerometerUpdates];
        // 上传数据到数据库
        self.currentTrackInfo.maxSpeed = floatToNumber(self.obd_speedMax);
        self.currentTrackInfo.avgSpeed = floatToNumber(self.obd_averageSpeed);
        self.currentTrackInfo.highSpeed = intToNumber(self.obd_highestRPM);
        self.currentTrackInfo.totalMileage = floatToNumber(self.obd_totalMileage);
        self.currentTrackInfo.totalFuel = floatToNumber(self.obd_totalFuelConsumption);
        self.currentTrackInfo.avgFuel = [self getAverageFuel];
        self.currentTrackInfo.heavyAccelTimes = intToNumber(self.obd_heavyAccelTimes);
        self.currentTrackInfo.sharpSlowdownTimes = intToNumber(self.obd_sharpSlowdownTimes);
        self.currentTrackInfo.sharpTurnTimes = intToNumber(self.obd_sharpTurnTimes);
        float zeroTime = [self.obd_zeroSpeedTimes intValue]*1.8;
        self.currentTrackInfo.zeroDriveTime = @(zeroTime);
        float lowSpeedTime = [self.obd_lowSpeedTimes intValue]*1.8;
        self.currentTrackInfo.lowSpeedTime = @(lowSpeedTime);
        float normalSpeedTime = [self.obd_normalSpeedTimes intValue]*1.8;
        self.currentTrackInfo.normalDriveTime = @(normalSpeedTime);
        float highSpeedTime = [self.obd_highSpeedTimes intValue]*1.8;
        self.currentTrackInfo.highDriveTime = @(highSpeedTime);
        self.currentTrackInfo.safeScore = [self getDriveScore];
        self.currentTrackInfo.cost = self.obd_totalDriverCost;
        if (self.trip_locationData == nil) {
            _trip_locationData = [[NSData alloc] init];
        }
        self.currentTrackInfo.fuelScore = [NSNumber numberWithInt:[self getTripFuelScore]];
        self.currentTrackInfo.driveScore = @(([self.currentTrackInfo.safeScore floatValue] + [self.currentTrackInfo.fuelScore floatValue])/2);

        self.currentTrackInfo.latlngs = self.trip_locationData;//[self.trip_locationString dataUsingEncoding:NSUTF8StringEncoding];
#warning 测试用，正式使用取消注释
        // 总里程小于200米，不记录
//        if ([self.obd_totalMileage floatValue] > 0.2) {
            [[CDataManager sharedInstance] saveTrackInfo:self.currentTrackInfo];
            NSLog(@"保存数据库成功");
            // 保存停车记录
            [self saveParkingTimeWithTimeLimit:NO];
//        }
    }
    @catch (NSException *exception) {
        NSLog(@"保存形成错误:%@",[exception reason]);
    }
    @finally {
//        if ([self.obd_totalMileage floatValue] > 0.2) {
        // 行程结束，需要上传体检数据
//        }
        
        self.currentTrackInfo = nil;
        self.currentTrackLatlngsStr = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentTripEnd" object:nil];

    }
}

- (void)saveParkingTimeWithTimeLimit:(BOOL)timeLimit
{
//    if ([CDataManager sharedInstance].lastParkInfoSaveTime && timeLimit == YES) {
        NSTimeInterval secondsInterval= [[CDataManager sharedInstance].lastParkInfoSaveTime timeIntervalSinceDate:[NSDate date]];
        if (YES) {
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
//                [[CDataManager sharedInstance] saveParkingMEMO:parking];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];

                [[ServerDAO instance]  homeTimelinedAddWithType:@"2"
                                                           info:[NSString stringWithFormat:@"%@",locationStr]
                                                          value:latlng
                                                         infoID:@""
                                                           date:destDateString
                                                       delegate:self];
            }];
            
            [CDataManager sharedInstance].lastParkInfoSaveTime = [NSDate date];
        }
//    }else{
//        CLLocationCoordinate2D location = [[BMKLocationServiceHelper instance] currentLocation];
//        [BMKLocationServiceHelper locationInfoWithCoordinate:location success:^(NSString *address) {
//            NSString *latlng = [BMKLocationServiceHelper locationStringWithCoordinate:location];
//            NSString *locationStr = address;
//            ParkingMEMO* parking = [[CDataManager sharedInstance] createEntityWithName:@"ParkingMEMO"];
//            parking.parkingTime = [NSDate date];
//            parking.parkingTitle = [NSString stringWithFormat:@"%@",locationStr];
//            parking.parkingLagLng = latlng;
//            parking.parkingAddress = locationStr;
//            parking.parkingImageUrl = nil;
//            parking.userId = [CUserDefaults instance].userId;
//            [[CDataManager sharedInstance] saveParkingMEMO:parking];
//        }];
//        [CDataManager sharedInstance].lastParkInfoSaveTime = [NSDate date];
//        
//    }
}

- (void)saveCarStatusToDatabaseWithHomePush:(BOOL)homePush withDelegate:(id<ServerAdaptorDelegateProtocol>)delegate
{
//    [self uploadCarStatusWithAuto:YES Delegate:self];
//    NSMutableArray *checkedCarItemArray = [NSMutableArray array];
//    NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
//    NSString *jsonString;
//    NSArray *commandsLibrary = [OBDConfig basicInspectionCommands];
//    for (NSString *code in commandsLibrary) {
//        CarCheckUpItem *item = [OBDConfig itemWithOBDCode:code];
//        NSString *valueKey = item.valueKey;
//        NSNumber *value = [[CarcoreDataManager sharedManager] valueForKey:valueKey]?[[CarcoreDataManager sharedManager] valueForKey:valueKey]:[NSNumber numberWithInt:0];
//        @try {
//            [checkedCarItemArray addObject:@{@"title":item.title, @"valueKey":valueKey,@"value":value,@"unit":item.unit,@"maxValue":[NSNumber numberWithFloat:item.maxValue],@"minValue":[NSNumber numberWithFloat:item.minValue],@"systemName":item.systemName,@"unit":item.unit,@"dataId":item.dataId}];
//            NSArray *valueTimeMap = @[@{@"1":[NSString stringWithFormat:@"%@-%@",value,[NSDate date]]}];
//            [jsonArray addObject:@{@"valueTimeMap":valueTimeMap,@"id":item.dataId,@"value":value,@"name":item.title,@"request_cmd":code,@"unit":item.unit}];
//        }
//        @catch (NSException *exception) {
//            NSAssert(0, @"reason:%@",exception.reason);
//        }
//        @finally {
//            jsonString = [jsonArray JSONString];
//            NSLog(@"%@",jsonString);
//        }
//    }
//
//    if ([jsonString length] > 0) {
//        [[ServerDAO instance] btusersUploadWithUserId:[CUserDefaults instance].userId data:jsonString delegate:delegate];
//    }
//    
//    [[CDataManager sharedInstance] insertNewCarCheckResultWithResults:checkedCarItemArray score:0 faultCodes:[CarcoreDataManager sharedManager].obd_faultArray needPushToHome:homePush];
}
-(NSString*)DataTOjsonString:(id)object
{
    if (object == nil) {
        return @"";
    }
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

- (NSString *)getCarStatusValueJSON:(NSDictionary *)valueTimeMap withAllItems:(BOOL)allItems
{
    
    NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
    NSString *jsonString;
    NSArray *commandsLibrary;
    if (allItems == YES) {
        commandsLibrary = [OBDConfig basicInspectionCommands];
    }else{
        commandsLibrary = [[CarcoreOBDManager sharedManager] carCheckUpCommands];
    }
    for (NSString *code in commandsLibrary) {
        CarCheckUpItem *item = [OBDConfig itemWithOBDCode:code];
        NSString *valueKey = item.valueKey;
        id value = [[CarcoreDataManager sharedManager] valueForKey:valueKey];
        if ([value isKindOfClass:[NSString class]]) {
            if ([(NSString *)value isContainString:@"\n"]) {
                value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@","];
            }
        }
        NSString *unit = item.unit;
        if ([unit isContainString:@"{n}"]) {
            unit = [unit stringByReplacingOccurrencesOfString:@"{n}" withString:@" "];
        }
        @try {
            NSMutableArray *valueArr = [valueTimeMap objectForKey:code];
            NSMutableDictionary *valueTimeMapDic = [NSMutableDictionary dictionary];
            for (int i = 0; i < [valueArr count]; i++) {
                [valueTimeMapDic setValue:valueArr[i] forKey:[NSString stringWithFormat:@"%d",i]];
            }
            
            if (valueTimeMapDic == nil || [valueTimeMapDic count] == 0) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
                NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
                
                valueTimeMapDic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"0-%@",destDateString] forKey:@"1"];
            }
            [jsonArray addObject:@{@"valueTimeMap":valueTimeMapDic,
                                   @"id":item.dataId,
                                   @"value":value?value:@"",
                                   @"name":item.title,
                                   @"request_cmd":[code isEqualToString:@"Instant_Fuel_Consumption"]?@"Instant_Fuel_Consumption":code,
                                   @"unit":unit}];
            
        }
        @catch (NSException *exception) {
            NSAssert(0, @"reason:%@",exception.reason);
        }
        @finally {
            // TODO:调用接口
            jsonString = [self DataTOjsonString:jsonArray];
            NSLog(@"%@",jsonString);
        }
    }
    if ([jsonString length] > 0 && [jsonString isEqualToString:@"[\n\n]"] == NO) {
        return jsonString;
    }

}
#pragma mark 车况体检上传接口

- (NSString *)getfaultCodes
{
    if ([CarcoreDataManager sharedManager].obd_faultNum > 0) {
        NSMutableString *faultCodes = [[NSMutableString alloc] init];
        for (NSString *code in [CarcoreDataManager sharedManager].obd_faultArray) {
            if ([faultCodes length] == 0) {
                [faultCodes appendString:code];
            }else{
                [faultCodes appendFormat:@",%@",code];
            }
        }
        return faultCodes;
    }
    return @"";
}

- (NSString *)valueStringWithData:(id)value{
    if (!value) {
        return @"";
    }
    NSString *valueString;
    if([value isKindOfClass:[NSNumber class]])
    {
        if (strcmp([value objCType], @encode(float)) == 0)
        {
            valueString =  [NSString stringWithFormat:@"%.2f", [value floatValue]];
        }
        else if (strcmp([value objCType], @encode(double)) == 0)
        {
            valueString =  [NSString stringWithFormat:@"%.2f", [value floatValue]];
        }
        else if (strcmp([value objCType], @encode(int)) == 0)
        {
            valueString =  [NSString stringWithFormat:@"%d", [value intValue]];
        }
        else
            valueString = [NSString stringWithFormat:@"%d", [value intValue]];
    }else if ([value isKindOfClass:[NSString class]]){
        valueString = value;
    }
    return valueString;
}


- (NSString *)updateID:(NSString *)dataID
{
    
}

- (void)uploadCarStatusWithType:(int)type
                        trackID:(NSString *)trackID
                       Delegate:(id<ServerAdaptorDelegateProtocol>)delegate{
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
    NSString *jsonString;
    NSMutableArray *commandsLibrary = [[NSMutableArray alloc] initWithArray:[OBDConfig basicInspectionCommands]];
    @try {
        for (NSString *code in commandsLibrary) {
            CarCheckUpItem *item = [OBDConfig itemWithOBDCode:code];
            NSString *valueKey = item.valueKey;
            id value;
            if ([valueKey isEqualToString:@"obd_faultNum"]) {
                // 获取错误代码
                value = [self getfaultCodes];
            }else{
                value = [self valueForKey:valueKey];//[[CarcoreDataManager sharedManager] valueForKey:valueKey];
            }
            if ([value isKindOfClass:[NSString class]]) {
                if ([(NSString *)value isContainString:@"\n"]) {
                    value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@","];
                }
            }
            if (value == nil) {
                value = [NSNumber numberWithFloat:0.00f];
            }
//            NSString *valueStr = [self valueStringWithData:value];
            [jsonDic setValue:value
                        forKey:item.dataId];
        }
//        [jsonDic setObject:[NSString stringWithFormat:@"%.2f",[[[CarcoreDataManager sharedManager] valueForKey:@"obd_displayInstantFuelConsumption"] floatValue]]
//                    forKey:@"51"];
        [jsonDic setObject:[[CarcoreDataManager sharedManager] valueForKey:@"obd_displayInstantFuelConsumption"]
                    forKey:@"51"];

        
    }
    @catch (NSException *exception) {
        NSLog(@"%s:error:%@",__func__,[exception reason]);
    }
    @finally {
        jsonString = [self DataTOjsonString:jsonDic];
        
        if ([jsonString length] > 0 && [jsonString isEqualToString:@"[\n\n]"] == NO) {
            NSDictionary *checkUpDic = [[CarcoreDataManager sharedManager] getCheckUpScoreAndMessage];
            
            NSString *examScore = checkUpDic[@"score"];
            NSString *examEvaluation = checkUpDic[@"message"];
            [[NSUserDefaults standardUserDefaults] setValue:examScore forKey:LAST_EXAM_SCORE];
            // TODO:调用接口
            [[ServerDAO instance] examinationUpload:[CUserDefaults instance].carId
                                               type:type
                                   examinationScore:examScore
                              examinationEvaluation:examEvaluation
                                    examinationData:jsonString
                                               time:0
                                            trackID:trackID
                                           delegate:self];
            [self cleanData];

        }
    }
}
#pragma mark 上传时段车况
//- (void)uploadCarStatusWithdata:(NSDictionary *)data delegate:(id<ServerAdaptorDelegateProtocol>)delegate
//{
//    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
//    NSString *jsonString;
//    NSArray *commandsLibrary = [OBDConfig basicInspectionCommands];
//    
//    @try {
//        for (NSString *code in commandsLibrary) {
//            CarCheckUpItem *item = [OBDConfig itemWithOBDCode:code];
//            NSString *valueKey = item.valueKey;
//            id value = [[CarcoreDataManager sharedManager] valueForKey:valueKey];
//            if ([value isKindOfClass:[NSString class]]) {
//                if ([(NSString *)value isContainString:@"\n"]) {
//                    value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@","];
//                }
//            }
//            NSString *dic = [NSString stringWithFormat:@"%@:%@",item.dataId,value?value:@""];//@{item.dataId:value?value:@""};
//            [jsonDic setObject:[NSString stringWithFormat:@"%@",value?value:@"0"]
//                        forKey:item.dataId];
//        }
//    }
//    @catch (NSException *exception) {
//        NSLog(@"%s:error:%@",__func__,[exception reason]);
//    }
//    @finally {
//        jsonString = [self DataTOjsonString:jsonDic];
//        
//        if ([jsonString length] > 0 && [jsonString isEqualToString:@"[\n\n]"] == NO) {
//            NSDictionary *checkUpDic = [[CarcoreDataManager sharedManager] getCheckUpScoreAndMessage];
//            
//            NSString *examScore = checkUpDic[@"score"];
//            NSString *examEvaluation = checkUpDic[@"message"];
//            // TODO:调用接口
//            [[ServerDAO instance] examinationUpload:[CUserDefaults instance].carId
//                                               type:0
//                                   examinationScore:examScore
//                              examinationEvaluation:examEvaluation
//                                    examinationData:jsonString
//                                               time:0 trackID:<#(NSString *)#> delegate:<#(id<ServerAdaptorDelegateProtocol>)#>
//                                           delegate:self];
//        }
//    }
//}

- (void)saveCarSelectedStatusToDatabaseWithAllItems:(BOOL)allItems valueTimeMap:(NSDictionary *)valueTimeMap withDelegate:(id<ServerAdaptorDelegateProtocol>)delegate
{
        NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
        NSString *jsonString;
        NSArray *commandsLibrary;
        if (allItems == YES) {
            commandsLibrary = [OBDConfig basicInspectionCommands];
        }else{
            commandsLibrary = [[CarcoreOBDManager sharedManager] carCheckUpCommands];
        }
        for (NSString *code in commandsLibrary) {
            CarCheckUpItem *item = [OBDConfig itemWithOBDCode:code];
            NSString *valueKey = item.valueKey;
            id value = [[CarcoreDataManager sharedManager] valueForKey:valueKey];
            if ([value isKindOfClass:[NSString class]]) {
                if ([(NSString *)value isContainString:@"\n"]) {
                    value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@","];
                }
            }
            NSString *unit = item.unit;
            if ([unit isContainString:@"{n}"]) {
                unit = [unit stringByReplacingOccurrencesOfString:@"{n}" withString:@" "];
            }
            @try {
                NSMutableArray *valueArr = [valueTimeMap objectForKey:code];
                NSMutableDictionary *valueTimeMapDic = [NSMutableDictionary dictionary];
                for (int i = 0; i < [valueArr count]; i++) {
                    [valueTimeMapDic setValue:valueArr[i] forKey:[NSString stringWithFormat:@"%d",i]];
                }

                NSString *valueTimeMapJSON = [self DataTOjsonString:valueTimeMapDic];

                if (valueTimeMapDic == nil || [valueTimeMapDic count] == 0) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
                    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];

                    valueTimeMapDic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"0-%@",destDateString] forKey:@"1"];
                }
                [jsonArray addObject:@{@"valueTimeMap":valueTimeMapDic,
                                       @"id":item.dataId,
                                       @"value":value?value:@"",
                                       @"name":item.title,
                                       @"request_cmd":[code isEqualToString:@"Instant_Fuel_Consumption"]?@"Instant_Fuel_Consumption":code,
                                       @"unit":unit}];
                
            }
            @catch (NSException *exception) {
                NSAssert(0, @"reason:%@",exception.reason);
            }
            @finally {
                // TODO:调用接口
                jsonString = [self DataTOjsonString:jsonArray];
                NSLog(@"%@",jsonString);
            }
    }
    if ([jsonString length] > 0 && [jsonString isEqualToString:@"[\n\n]"] == NO) {
        [[ServerDAO instance] btusersUploadWithUserId:[CUserDefaults instance].userId data:jsonString delegate:delegate];
    }
}

- (NSString *)jsonForInspectionData:(id)data
{
    return @"";
}

#pragma mark - Clean Data
- (void)cleanData
{
    return;
    // 清空缓存
    self.obd_speed = 0;
    self.obd_averageSpeed = 0;
    self.obd_engineLoad = 0;
    self.obd_engineRPM = 0;
    self.obd_airIntask = 0;
    self.obd_totalFuelConsumption = 0;
    self.obd_totalMileage = 0;
    self.obd_fuelCount = 0;
    self.obd_heavyAccelTimes = 0;
    self.obd_sharpTurnTimes = 0;
    self.obd_sharpSlowdownTimes = 0;
    self.obd_lowSpeedTimes = 0;
    self.obd_normalSpeedTimes = 0;
    self.obd_highSpeedTimes = 0;
    self.obd_zeroSpeedTimes = 0;
    self.obd_speedMax = 0;
    self.trip_locationString = [NSMutableString stringWithString:@""];
    self.trip_locationData = nil;
    self.obd_totalDriverCost = 0;
    [self.fuelScoreArray removeAllObjects];
    self.fuelScoreCount = 0;
}

#pragma mark - 验证
+ (BOOL)valueIsEqualCommand:(NSString *)value
{

    BOOL isEqualCommand = NO;
    for (NSString *initCommand in [OBDConfig initializeCommands]) {
        if ([initCommand isEqualToString:value]) {
            isEqualCommand = YES;
            return isEqualCommand;
            break;
        }

    }
    if (isEqualCommand == NO) {
        for (NSString *basicCommands in [OBDConfig basicCommandsWithIntakeFlowNotSupport:[CarcoreOBDManager sharedManager].isNoSupportIntaskFlow]) {
            if ([basicCommands isEqualToString:value]) {
                isEqualCommand = YES;
                return isEqualCommand;
                break;
            }
        }
    }

    if (isEqualCommand == NO) {
        for (CarCheckUpItem *item in [OBDConfig vehicleInspectionAllItemsLibrary]) {
            
            if ([item.obdCode isEqualToString:value]) {
                isEqualCommand = YES;
                return isEqualCommand;
                break;
            }
        }
    }

    if ([C_VIN_CODE isEqualToString:value]) {
        isEqualCommand = YES;
        return isEqualCommand;
    }
    return isEqualCommand;
}

@end
