//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

typealias AssistantInfo = (identifier: UInt8, userVisibleString: String)

protocol GaiaDeviceVoiceAssistantPluginProtocol: GaiaDevicePluginProtocol {
    var availableAssistantOptions: [AssistantInfo] { get }
    var selectedOption: AssistantInfo { get }

    func selectOption(_ option: AssistantInfo)
}
