//
// Copyright 2016 Qualcomm Technologies International, Ltd.
//

#import <UIKit/UIKit.h>
#import "CSRGaia.h"
#import "CSRGaiaManager.h"
#import "CSRGaiaGattCommand.h"
#import "QTIGaiaClassicCommand.h"
#import "QTIRWCP.h"
#import "QTIRWCPServer.h"
#import "QTIGaiaPeripheral.h"

//! Project version number for GaiaLibrary.
FOUNDATION_EXPORT double GaiaLibraryVersionNumber;

//! Project version string for GaiaLibrary.
FOUNDATION_EXPORT const unsigned char GaiaLibraryVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GaiaLibrary/PublicHeader.h>

#ifdef DEBUG

//#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLog(fmt, ...) NSLog(fmt, ##__VA_ARGS__)

#else

#define DLog(...)

#endif
