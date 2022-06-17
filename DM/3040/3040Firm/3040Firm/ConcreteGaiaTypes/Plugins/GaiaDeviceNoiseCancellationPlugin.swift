//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var GaiaDeviceNoiseCancellationPluginNotification = Notification.Name("GaiaDeviceNoiseCancellationPluginNotification")
}

struct GaiaNoiseCancellationPluginNotification: GaiaNotification {
    enum Reason {
        case enabledChanged
        case modeChanged
        case gainChanged
        case adaptiveStateChanged
    }

    var sender: GaiaNotificationSender
    var payload: GaiaDeviceProtocol?
    var reason: Reason

    static var name: Notification.Name = .GaiaDeviceNoiseCancellationPluginNotification
}

class GaiaDeviceNoiseCancellationPlugin: GaiaDeviceNoiseCancellationPluginProtocol, GaiaNotificationSender {
    static let featureID: GaiaDevicePluginFeatureID = .noiseCancellation

    let title = NSLocalizedString("Noise Cancellation", comment: "Plugin title")
    var subtitle: String? {
        let leftTypeValue = isLeftAdaptive ?
            NSLocalizedString("Left: Adaptive", comment: "ANC Type") :
            NSLocalizedString("Left: Static", comment: "ANC Type")

        let rightTypeValue = isRightAdaptive ?
            NSLocalizedString("Right: Adaptive", comment: "ANC Type") :
            NSLocalizedString("Right: Static", comment: "ANC Type")

        return leftTypeValue + " - " + rightTypeValue
    }

    private let devicePluginVersion: UInt8
    private weak var device: GaiaDeviceProtocol!
    private let connection: GaiaDeviceConnectionProtocol
    private let notificationCenter : NotificationCenter

    private(set) var enabled: Bool = false
    private(set) var isLeftAdaptive: Bool = false
    private(set) var isRightAdaptive: Bool = false
    private(set) var leftAdaptiveGain: Int = 0
    private(set) var rightAdaptiveGain: Int = 0

    private(set) var currentMode: Int = 0
    private(set) var maxMode: Int = 0

    private(set) var staticGain: Int = 0

    required init(version: UInt8,
                  device: GaiaDeviceProtocol,
                  connection: GaiaDeviceConnectionProtocol,
                  notificationCenter: NotificationCenter) {
        self.devicePluginVersion = version
        self.device = device
        self.connection = connection
        self.notificationCenter = notificationCenter
    }

    func startPlugin() {
        getCurrentState()
        getNumberOfModes()
        getCurrentMode()
        getStaticGain()
        registerForNCNotifications()
    }

    func stopPlugin() {
        cancelNCNotificationRegistration()
    }

	func responseReceived(messageDescription: IncomingMessageDescription) {
        switch messageDescription {
        case .notification(let notificationID, let data):
            guard let notification = Gaia.V3NoiseCancellationNotification(rawValue: notificationID) else {
                print("Non valid notification id")
                return
            }
            switch notification {
            case .ANCStateChanged:
                processNewANCState(data: data)
            case .ANCModeChanged:
                processNewANCMode(data: data)
            case .ANCGainChanged:
                processNewANCStaticGain(data: data)
            case .adaptiveANCStateChanged:
                guard data.count == 2 else {
                    print("Wrong data length for \(notification)")
                    return
                }
                let isLeftEarbud = data[0] == 0
                let isEnabled = data[1] == 1
                if isLeftEarbud {
					isLeftAdaptive = isEnabled
                } else {
                    isRightAdaptive = isEnabled
                }
                let notification = GaiaNoiseCancellationPluginNotification(sender: self,
                                                                           payload: nil,
                                                                           reason: .adaptiveStateChanged)
                notificationCenter.post(notification)

            case .adaptiveANCGainChanged:
                guard data.count == 2 else {
                    print("Wrong data length for \(notification)")
                    return
                }
                let isLeftEarbud = data[0] == 0
                let gain = Int(data[1])
                if isLeftEarbud {
                    leftAdaptiveGain = gain
                } else {
                    rightAdaptiveGain = gain
                }
                let notification = GaiaNoiseCancellationPluginNotification(sender: self,
                                                                           payload: nil,
                                                                           reason: .gainChanged)
                notificationCenter.post(notification)
            }
        case .response(let commandID, let data):
            guard let command = Gaia.V3NoiseCancellationCommands(rawValue: commandID) else {
                print("Non valid command id")
                return
            }

            switch command {
            case .getANCState:
                processNewANCState(data: data)
            case .getNumANCModes:
                guard data.count > 0 else {
                    print("Wrong data length for \(command)")
                    return
                }
                maxMode = max(0, (min(Int(data[0]) - 1, 9)))
            case .getANCMode:
                processNewANCMode(data: data)
            case .getConfiguredLeakthroughGain:
                processNewANCStaticGain(data: data)
            case .setANCState,
                 .setANCMode,
                 .setConfiguredLeakthroughGain:
                break
            }
        case .error(_, _, _):
            break
        default:
            break
        }
    }

    func didSendData(channel: GaiaDeviceConnectionChannel, error: Error?) {

    }
}

extension GaiaDeviceNoiseCancellationPlugin {
    func setEnabledState(_ enabled: Bool) {
        let message = GaiaV3GATTPacket(featureID: .noiseCancellation,
                                       commandID: Gaia.V3NoiseCancellationCommands.setANCState.rawValue,
                                       payload: Data([enabled ? 0x01 : 0x00]))
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func setCurrentMode(_ value: Int) {
        let mode = UInt8(max(min(value, maxMode), 0))
        let message = GaiaV3GATTPacket(featureID: .noiseCancellation,
                                       commandID: Gaia.V3NoiseCancellationCommands.setANCMode.rawValue,
                                       payload: Data([mode]))
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func setStaticGain(_ value: Int) {
        let valueToSet = UInt8(min(255, max(0, value)))

        let message = GaiaV3GATTPacket(featureID: .noiseCancellation,
                                       commandID: Gaia.V3NoiseCancellationCommands.setConfiguredLeakthroughGain.rawValue,
                                       payload: Data([valueToSet]))
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }
}

private extension GaiaDeviceNoiseCancellationPlugin {
    func processNewANCState(data: Data) {
        guard data.count > 0 else {
            return
        }
        enabled = data[0] == 1
        let notification = GaiaNoiseCancellationPluginNotification(sender: self,
                                                                   payload: nil,
                                                                   reason: .enabledChanged)
        notificationCenter.post(notification)
    }

    func processNewANCMode(data: Data) {
        guard data.count > 0 else {
            return
        }
        currentMode = max(0, min(Int(data[0]), maxMode))
        let notification = GaiaNoiseCancellationPluginNotification(sender: self,
                                                                   payload: nil,
                                                                   reason: .modeChanged)
        notificationCenter.post(notification)
    }

    func processNewANCStaticGain(data: Data) {
        guard data.count > 0 else {
            return
        }
        staticGain = Int(data[0])
        if !isLeftAdaptive {
            leftAdaptiveGain = staticGain
        }
        if !isRightAdaptive {
            rightAdaptiveGain = staticGain
        }
        let notification = GaiaNoiseCancellationPluginNotification(sender: self,
                                                                   payload: nil,
                                                                   reason: .gainChanged)
        notificationCenter.post(notification)
    }
    
    func getCurrentState() {
        let message = GaiaV3GATTPacket(featureID: .noiseCancellation,
                                       commandID: Gaia.V3NoiseCancellationCommands.getANCState.rawValue,
                                       payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func getNumberOfModes() {
        let message = GaiaV3GATTPacket(featureID: .noiseCancellation,
                                       commandID: Gaia.V3NoiseCancellationCommands.getNumANCModes.rawValue,
                                       payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func getCurrentMode() {
        let message = GaiaV3GATTPacket(featureID: .noiseCancellation,
                                       commandID: Gaia.V3NoiseCancellationCommands.getANCMode.rawValue,
                                       payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func getStaticGain() {
        let message = GaiaV3GATTPacket(featureID: .noiseCancellation,
                                       commandID: Gaia.V3NoiseCancellationCommands.getConfiguredLeakthroughGain.rawValue,
                                       payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func registerForNCNotifications() {
        let message = GaiaV3GATTPacket(featureID: .basic,
                                       commandID: Gaia.V3BasicCommands.registerForNotification.rawValue,
                                       payload: Data([GaiaDevicePluginFeatureID.noiseCancellation.rawValue]))
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func cancelNCNotificationRegistration() {
        let message = GaiaV3GATTPacket(featureID: .basic,
                                       commandID: Gaia.V3BasicCommands.unregisterForNotification.rawValue,
                                       payload: Data([GaiaDevicePluginFeatureID.noiseCancellation.rawValue]))
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }
}
