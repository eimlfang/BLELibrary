//
//  CarCheckUpItem.m
//  Carcore
//
//  Created by Besprout's Mac Mini on 15/6/10.
//  Copyright (c) 2015年 besprout.com. All rights reserved.
//

#import "CarCheckUpItem.h"

@implementation CarCheckUpItem

+ (CarCheckUpItem *)itemWithSystemName:(NSString *)systemName Title:(NSString *)title code:(NSString *)obdCode valueKey:(NSString *)valueKey max:(float)max min:(float)min unit:(NSString *)unit dataId:(NSString *)dataId
{
    CarCheckUpItem *item = [[CarCheckUpItem alloc] init];
    item.systemName = systemName;
    item.title = title;
    item.valueKey = valueKey;
    item.obdCode = obdCode;
    item.maxValue = max;
    item.minValue = min;
    item.unit = unit;
    item.dataId = dataId;
    return item;
}

@end
