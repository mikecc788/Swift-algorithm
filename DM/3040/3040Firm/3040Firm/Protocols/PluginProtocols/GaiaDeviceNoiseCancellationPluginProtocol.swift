//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

protocol GaiaDeviceNoiseCancellationPluginProtocol: GaiaDevicePluginProtocol {
    var enabled: Bool { get }
	func setEnabledState(_ enabled: Bool)

    var isLeftAdaptive: Bool { get }
    var isRightAdaptive: Bool { get }
    
    var currentMode: Int { get }
    var maxMode: Int { get }
    func setCurrentMode(_ value: Int)

    var staticGain: Int { get }
    var rightAdaptiveGain: Int { get }
    var leftAdaptiveGain: Int { get }
    func setStaticGain(_ value: Int)
}
