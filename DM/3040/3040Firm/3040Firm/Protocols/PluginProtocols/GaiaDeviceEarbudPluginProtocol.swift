//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

protocol GaiaDeviceEarbudPluginProtocol: GaiaDevicePluginProtocol {
    var secondEarbudSerialNumber: String? { get }
    var leftEarbudIsPrimary: Bool { get }
}
