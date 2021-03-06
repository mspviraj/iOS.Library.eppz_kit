//
//  EPPZDevice.h
//  eppz!kit
//
//  Created by Borbás Geri on 8/22/13.
//  Copyright (c) 2013 eppz! development, LLC.
//
//  donate! by following http://www.twitter.com/_eppz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#include <sys/sysctl.h>

#import "EPPZSingletonSubclass.h"


#define DEVICE [EPPZDevice sharedDevice]


@interface EPPZDevice : EPPZSingleton

+(EPPZDevice*)sharedDevice;

@property (nonatomic, readonly) float iOSversion;
@property (nonatomic, readonly) BOOL iOS5;
@property (nonatomic, readonly) BOOL iOS6;
@property (nonatomic, readonly) BOOL iOS7;

@property (nonatomic, readonly) NSString *machineID;
@property (nonatomic, readonly) NSString *generation;
@property (nonatomic, readonly) NSString *variant;
@property (nonatomic, readonly) NSString *model;

@property (nonatomic, readonly) NSString *platformDescription;
@property (nonatomic, readonly) NSString *platformString; //Alias for compatibility.

@property (nonatomic, readonly) NSString *vendorIdentifier; //Alias for compatibility.
@property (nonatomic, readonly) float batteryPercentage;

@end
