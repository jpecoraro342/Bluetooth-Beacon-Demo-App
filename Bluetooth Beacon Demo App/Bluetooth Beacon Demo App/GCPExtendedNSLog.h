//
//  HBXExtendedNSLog.h
//  Haulbox
//
//  Created by Joseph Pecoraro on 7/14/14.
//  Copyright (c) 2014 GatorLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCPExtendedNSLog : NSObject

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);

@end
