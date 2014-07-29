//
//  HBXExtendedNSLog.m
//  Haulbox
//
//  Created by Joseph Pecoraro on 7/14/14.
//  Copyright (c) 2014 GatorLab. All rights reserved.
//

#import "GCPExtendedNSLog.h"

@implementation GCPExtendedNSLog

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...)
{
    // Type to hold information about variable arguments.
    va_list ap;
    
    // Initialize a variable argument list.
    va_start (ap, format);
    
    // NSLog only adds a newline to the end of the NSLog format if
    // one is not already there.
    // Here we are utilizing this feature of NSLog()
    if (![format hasSuffix: @"\n"])
    {
        format = [format stringByAppendingString: @"\n"];
    }
    
    NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
    
    // End using variable argument list.
    va_end (ap);
    
    NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
    fprintf(stderr, "%s [%s:%d] %s",
            functionName, [fileName UTF8String],
            lineNumber, [body UTF8String]);
}

@end
