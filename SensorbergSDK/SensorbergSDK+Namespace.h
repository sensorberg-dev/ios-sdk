//
//  SensorbergSDK+Namespace.h
//  SensorbergSDK
//
//  Copyright (c) 2014-2015 Sensorberg GmbH. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#ifndef __SBSDK_NS_SYMBOL
    #define __SBSDK_NS_REWRITE(ns, symbol) ns ## _ ## symbol
    #define __SBSDK_NS_BRIDGE(ns, symbol) __SBSDK_NS_REWRITE(ns, symbol)
    #define __SBSDK_NS_SYMBOL(symbol) __SBSDK_NS_BRIDGE(SBSDK, symbol)
#endif

//
// Classes
//

#ifndef AFHTTPSessionManager
    #define AFHTTPSessionManager __SBSDK_NS_SYMBOL(AFHTTPSessionManager)
#endif

#ifndef AFJSONRequestSerializer
    #define AFJSONRequestSerializer __SBSDK_NS_SYMBOL(AFJSONRequestSerializer)
#endif

#ifndef AFJSONResponseSerializer
    #define AFJSONResponseSerializer __SBSDK_NS_SYMBOL(AFJSONResponseSerializer)
#endif

#ifndef MSWeakTimer
    #define MSWeakTimer __SBSDK_NS_SYMBOL(MSWeakTimer)
#endif

#ifndef SensorbergSDK_FrameworkLoader
    #define SensorbergSDK_FrameworkLoader __SBSDK_NS_SYMBOL(SensorbergSDK_FrameworkLoader)
#endif

//
// Functions
//

//
// Externs
//

