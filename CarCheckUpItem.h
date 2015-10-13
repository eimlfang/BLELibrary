//
//  CarCheckUpItem.h
//  Carcore
//
//  Created by Besprout's Mac Mini on 15/6/10.
//  Copyright (c) 2015年 besprout.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarCheckUpItem : NSObject
@property (nonatomic, strong) NSString *systemName;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *obdCode;
@property (nonatomic, strong) NSString *valueKey;
@property (nonatomic, strong) NSString *unit;
@property (nonatomic, readwrite) float minValue;
@property (nonatomic, readwrite) float maxValue;
@property (nonatomic, strong) NSString *dataId;
+ (CarCheckUpItem *)itemWithSystemName:(NSString *)systemName Title:(NSString *)title code:(NSString *)obdCode valueKey:(NSString *)valueKey max:(float)max min:(float)min unit:(NSString *)unit dataId:(NSString *)dataId;
@end
