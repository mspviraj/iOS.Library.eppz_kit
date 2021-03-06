//
//  EPPZAppStoreCallbacks.h
//  eppz!tools
//
//  Created by Borbás Geri on 11/15/12.
//  Copyright (c) 2013 eppz! development, LLC.
//
//  donate! by following http://www.twitter.com/_eppz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "EPPZTimer.h"


static NSUInteger const EPPZAppStoreProductRequestRetryAttempts = 3;
static NSUInteger const EPPZAppStoreProductRequestRetryTimeOut = 8.0;


typedef void (^EPPZAppStoreProductDetailsSuccessBlock)(SKProduct *product);
typedef void (^EPPZAppStoreProductPurchaseSuccessBlock)(NSString *productID, SKPaymentTransaction *transaction);
typedef void (^EPPZAppStoreErrorBlock)(NSError *error);


@interface EPPZAppStoreCallbacks : NSObject

@property (nonatomic, strong) EPPZAppStoreProductDetailsSuccessBlock productDetailsSuccessBlock;
@property (nonatomic, strong) EPPZAppStoreErrorBlock productDetailsErrorBlock;

@property (nonatomic, strong) EPPZAppStoreProductPurchaseSuccessBlock productPurchaseSuccessBlock;
@property (nonatomic, strong) EPPZAppStoreErrorBlock productPurchaseErrorBlock;

@property (nonatomic, strong) NSString *productIdentifier;
@property (nonatomic) NSUInteger retryAttempts;
@property (nonatomic, weak) SKProductsRequest *productsRequest;

+(id)productDetailsCallbacksWithSuccess:(EPPZAppStoreProductDetailsSuccessBlock) successBlock error:(EPPZAppStoreErrorBlock) errorBlock productsRequest:(SKProductsRequest*) productsRequest productIdentifier:(NSString*) productIdentifier;
+(id)productPurchaseCallbacksWithSuccess:(EPPZAppStoreProductPurchaseSuccessBlock) successBlock error:(EPPZAppStoreErrorBlock) errorBlock;
-(void)retryAfterIntervalIfNeeded:(NSTimeInterval) interval;
-(void)retryProductRequest;

@end
