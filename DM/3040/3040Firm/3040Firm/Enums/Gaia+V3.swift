//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

extension Gaia {
    enum V3BasicCommands: UInt16 {
        case getAPIVersion = 0
        case getSupportedFeatures = 1
        case getSupportedFeaturesNext = 2
        case getSerialNumber = 3
        case getVariantName = 4
        case getApplicationVersion = 5
        case deviceReset = 6
        case registerForNotification = 7
        case unregisterForNotification = 8
    }

    enum V3UpdateCommands: UInt16 {
        case vmUpgradeConnect               = 0x0000
        case vmUpgradeDisconnect            = 0x0001
        case vmUpgradeControl               = 0x0002
        case getDataEndPointMode            = 0x0003
        case setDataEndPointMode            = 0x0004
    }

    enum V3UpdateEvents: UInt8 {
        case vmUpgradeProtocolPacket = 0x00
    }

    enum V3EarbudCommands: UInt16 {
        case getWhichEarbudIsPrimary = 0
        case getSecondarySerialNumber = 1
    }

    enum V3EarbudNotification: UInt8 {
        case primaryEarbudWillChange = 0
    }

    enum V3VoiceAssistantCommands: UInt16 {
        case getSelectedAssistant = 0
        case setSelectedAssistant = 1
        case getAssistantOptions = 2
    }

    enum V3VoiceAssistantNotification: UInt8 {
        case assistantChanged = 0
    }

    enum V3NoiseCancellationCommands: UInt16 {
        case getANCState = 1
        case setANCState = 2
        case getNumANCModes = 3
        case getANCMode = 4
        case setANCMode = 5
        case getConfiguredLeakthroughGain = 6
        case setConfiguredLeakthroughGain = 7
    }

    enum V3NoiseCancellationNotification: UInt8 {
        case ANCStateChanged = 0
        case ANCModeChanged = 1
        case ANCGainChanged = 2
        case adaptiveANCStateChanged = 3
        case adaptiveANCGainChanged = 4
    }
}
