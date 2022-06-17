//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

extension Gaia {
    enum V2Commands: UInt16 {
        case getAPIVersion                     = 0x0300
        case setDataEndPointMode             = 0x022E
        case getDataEndPointMode             = 0x02AE
        case vmUpgradeConnect                 = 0x0640
        case vmUpgradeDisconnect             = 0x0641
        case vmUpgradeControl                 = 0x0642

        case registerNotification            = 0x4001
        case getNotification                = 0x4081
        case cancelNotification                = 0x4002
        case eventNotification                = 0x4003
    }

    enum V2UpdateEvents: UInt8 {
        case vmUpgradeProtocolPacket = 0x12
    }
}
