//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

struct Gaia {
    static let errorDomain = "com.csr.gaia"
    static let errorParam = "name"
    static let v2VendorID: UInt16 = 0x000A
    static let v3VendorID: UInt16 = 0x001D
    static let v2UpdateID = 0x12345678

    static let serviceUUID = "00001100-D102-11E1-9B23-00025B00A5A5"
    static let commandCharacteristicUUID = "00001101-D102-11E1-9B23-00025B00A5A5"
    static let responseCharacteristicUUID = "00001102-D102-11E1-9B23-00025B00A5A5"
    static let dataCharacteristicUUID = "00001103-D102-11E1-9B23-00025B00A5A5"

    enum CommandErrorCodes: UInt8 {
        /// The command succeeded.
        case success                          = 0x00
        /// An invalid Command ID was specified.
        case failedNotSupported               = 0x01
        /// The host is not authenticated to use a Command ID orcontrol a Feature Type.
        case failedNotAuthenticated           = 0x02
        /// The command was valid, but the device could not successfully carry out the command.
        case failedInsufficientResources      = 0x03
        /// The device is in the process of authenticating the host.
        case authenticating                   = 0x04
        /// An invalid parameter was used in the command.
        case invalidParameter                 = 0x05
        /// The device is not in the correct state to process the command.
        case incorrectState                   = 0x06
        /// The command is in progress
        case inProgress                       = 0x07
        /// Undocumented
        case noStatusAvailable                = 0xFF

        func userDescription() -> String {
            switch self {
            case .success:
                return NSLocalizedString("Everything is fine", comment: "Error Code")
            case .failedNotSupported:
                return NSLocalizedString("An invalid Command ID was specified", comment: "Error Code")
            case .failedNotAuthenticated:
                return NSLocalizedString("The host is not authenticated to use a Command ID or control a Feature Type", comment: "Error Code")
            case .failedInsufficientResources:
                return NSLocalizedString("he command was valid, but the device could not successfully carry out the command", comment: "Error Code")
            case .authenticating:
                return NSLocalizedString("The device is in the process of authenticating the host", comment: "Error Code")
            case .invalidParameter:
                return NSLocalizedString("An invalid parameter was used in the command", comment: "Error Code")
            case .incorrectState:
                return NSLocalizedString("The device is not in the correct state to process the command", comment: "Error Code")
            case .inProgress:
                return NSLocalizedString("The command is already in progress", comment: "Error Code")
            case .noStatusAvailable:
                return NSLocalizedString("No status available", comment: "Error Code")
            }
        }
    }
}
