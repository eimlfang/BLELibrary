//
//  CarcoreOBDPrefix.h
//  CarcoreBTTest
//
//  Created by Besprout's Mac Mini on 15/5/19.
//  Copyright (c) 2015年 Fang Zijian. All rights reserved.
//

#ifndef CarcoreBTTest_CarcoreOBDPrefix_h
#define CarcoreBTTest_CarcoreOBDPrefix_h

#ifndef __OBD_DEBUG__
#define __OBD_DEBUG__
#endif

#ifdef __OBD_DEBUG__
#ifndef OBDLog//(...)
#   define OBDLog(...) NSLog(__VA_ARGS__)
#endif
#else
#ifndef OBDLog//(...)
#   define OBDLog(...)
#endif
#endif

#endif
