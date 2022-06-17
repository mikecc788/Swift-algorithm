//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var GaiaDeviceVoiceAssistantPluginNotification = Notification.Name("GaiaDeviceVoiceAssistantPluginNotification")
}

struct GaiaDeviceVoiceAssistantPluginNotification: GaiaNotification {
    enum Reason {
//        case enabledChanged
        case optionChanged
    }

    var sender: GaiaNotificationSender
    var payload: GaiaDeviceProtocol?
    var reason: Reason

    static var name: Notification.Name = .GaiaDeviceVoiceAssistantPluginNotification
}

class GaiaDeviceVoiceAssistantPlugin: GaiaDeviceVoiceAssistantPluginProtocol, GaiaNotificationSender {
    static let featureID: GaiaDevicePluginFeatureID = .voiceAssistant

    let title = NSLocalizedString("Voice Control", comment: "Plugin title")
    var subtitle: String? {
        return selectedOption.userVisibleString
    }

    private let devicePluginVersion: UInt8
    private weak var device: GaiaDeviceProtocol!
    private let connection: GaiaDeviceConnectionProtocol
    private let notificationCenter : NotificationCenter

    private static let noneOption: AssistantInfo = (0x00, NSLocalizedString("None", comment: "Voice Option"))
    private let possibleAssistantOptions: [AssistantInfo] = [
        noneOption,
        (0x01, NSLocalizedString("Audio Tuning", comment: "Voice Option")),
        (0x02, NSLocalizedString("GAA", comment: "Voice Option")),
        (0x03, NSLocalizedString("AMA", comment: "Voice Option"))
    ]


    private(set) var availableAssistantOptions: [AssistantInfo] = [noneOption]
	var selectedOption: AssistantInfo {
        return option(identifier: assistantID) ?? Self.noneOption
    }

    private var assistantID: UInt8 = 0

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
        getAssistantOptions()
        getSelectedAssistant()
        registerForVANotifications()
    }

    func stopPlugin() {
        cancelVANotificationRegistration()
    }

    func responseReceived(messageDescription: IncomingMessageDescription) {
        switch messageDescription {
        case .notification(let notificationID, let data):
            if let id = Gaia.V3VoiceAssistantNotification(rawValue: notificationID),
                id == .assistantChanged {
                if let aId = data.first {
                    if aId < possibleAssistantOptions.count {
                        assistantID = aId
                    } else {
                        assistantID = 0
                    }
                    let notification = GaiaDeviceVoiceAssistantPluginNotification(sender: self,
                                                                                  payload: nil,
                                                                                  reason: .optionChanged)
                    notificationCenter.post(notification)
                }
            }
        case .response(let command, let data):
            if let id = Gaia.V3VoiceAssistantCommands(rawValue: command) {
                switch id {
                case .getSelectedAssistant:
                    if let aId = data.first {
                        assistantID = aId
                        let notification = GaiaDeviceVoiceAssistantPluginNotification(sender: self,
                                                                                      payload: nil,
                                                                                      reason: .optionChanged)
                        notificationCenter.post(notification)
                    }
                case .getAssistantOptions:
                    if let numberOfOptions = data.first {
                        if numberOfOptions == 0 {
                            availableAssistantOptions = [Self.noneOption]
                        } else {
                            availableAssistantOptions = []
                            let opts = min(data.count - 1, Int(numberOfOptions))
                            for i in 0..<opts {
                                let id = data[i + 1]
                                if let option = option(identifier: id) {
                                    availableAssistantOptions.append(option)
                                }
                            }
                        }
                    }
                default:
                    break
                }
            }
        case .error(_ , _, _):
            break
        default:
            break
        }
    }

    func didSendData(channel: GaiaDeviceConnectionChannel, error: Error?) {

    }
}

private extension GaiaDeviceVoiceAssistantPlugin {
    func option(identifier: UInt8) -> AssistantInfo? {
        return possibleAssistantOptions.first(where: { option in
            option.identifier == identifier
        })
    }
}

extension GaiaDeviceVoiceAssistantPlugin {
    func selectOption(_ option: AssistantInfo) {
        // Look up true identifier
        let message = GaiaV3GATTPacket(featureID: .voiceAssistant,
                                       commandID: Gaia.V3VoiceAssistantCommands.setSelectedAssistant.rawValue,
                                       payload: Data([option.identifier]))
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }
}

private extension GaiaDeviceVoiceAssistantPlugin {
    func getSelectedAssistant() {
        let message = GaiaV3GATTPacket(featureID: .voiceAssistant,
                                       commandID: Gaia.V3VoiceAssistantCommands.getSelectedAssistant.rawValue,
                                       payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func getAssistantOptions() {
        let message = GaiaV3GATTPacket(featureID: .voiceAssistant,
                                       commandID: Gaia.V3VoiceAssistantCommands.getAssistantOptions.rawValue,
                                       payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func registerForVANotifications() {
        let message = GaiaV3GATTPacket(featureID: .basic,
                                       commandID: Gaia.V3BasicCommands.registerForNotification.rawValue,
                                       payload: Data([GaiaDevicePluginFeatureID.voiceAssistant.rawValue]))
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func cancelVANotificationRegistration() {
        let message = GaiaV3GATTPacket(featureID: .basic,
                                       commandID: Gaia.V3BasicCommands.unregisterForNotification.rawValue,
                                       payload: Data([GaiaDevicePluginFeatureID.voiceAssistant.rawValue]))
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }
}

