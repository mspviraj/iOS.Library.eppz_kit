//
//  UIColor+EPPZRepresenter.m
//  eppz!kit
//
//  Created by Borbás Geri on 8/28/13.
//  Copyright (c) 2013 eppz! development, LLC.
//
//  donate! by following http://www.twitter.com/_eppz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "UIColor+EPPZRepresenter.h"


@implementation UIColor (EPPZRepresenter)


NSString *NSStringFromUIColor(UIColor *color)
{
    // Checks.
    if (color == nil)
    { return NSStringFromUIColor([UIColor blackColor]); }
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"[%f, %f, %f, %f]",
            components[0],
            components[1],
            components[2],
            components[3]];
}

UIColor *UIColorFromNSString(NSString *string)
{
    NSString *componentsString = [[string stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@""];
    NSArray *components = [componentsString componentsSeparatedByString:@", "];
    
    // Return with class methods.
    if ([string hasPrefix:@"["] == NO)
    {
        // Append `Color` if not already.
        NSString *classMehtodName = string;
        if ([string hasSuffix:@"Color"] == NO) classMehtodName = [NSString stringWithFormat:@"%@Color", string];
        
        SEL factoryMethod = NSSelectorFromString(classMehtodName);
        UIColor *color;
        @try { color = [UIColor performSelector:factoryMethod]; }
        @catch (NSException *exception) { }
        @finally {}
        
        return color;
    }
    
    return [UIColor colorWithRed:[(NSString*)components[0] floatValue]
                           green:[(NSString*)components[1] floatValue]
                            blue:[(NSString*)components[2] floatValue]
                           alpha:[(NSString*)components[3] floatValue]];
}


@end
