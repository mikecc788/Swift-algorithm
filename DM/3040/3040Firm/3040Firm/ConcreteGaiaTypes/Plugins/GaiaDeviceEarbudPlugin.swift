//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var GaiaDeviceEarbudPluginNotification = Notification.Name("GaiaDeviceEarbudPluginNotification")
}

struct GaiaDeviceEarbudPluginNotification: GaiaNotification {
    struct Payload {
        let device: GaiaDeviceProtocol?
        let handoverDelay: Int
        let handoverIsStatic: Bool
    }
    enum Reason {
        case secondSerial
        case handoverAboutToHappen
    }

    var sender: GaiaNotificationSender
    var payload: Payload?
    var reason: Reason

    static var name: Notification.Name = .GaiaDeviceEarbudPluginNotification
}

class GaiaDeviceEarbudPlugin: GaiaDeviceEarbudPluginProtocol, GaiaNotificationSender {
    static let featureID: GaiaDevicePluginFeatureID = .earbud

    let title = NSLocalizedString("Earbud", comment: "Plugin title")
    let subtitle: String? = nil

    private let devicePluginVersion: UInt8
    private weak var device: GaiaDeviceProtocol!
    private let connection: GaiaDeviceConnectionProtocol
    private let notificationCenter : NotificationCenter

    private(set) var secondEarbudSerialNumber: String?
    private(set) var leftEarbudIsPrimary: Bool = true

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
        getWhichEarbudIsPrimary()
        getSecondarySerialNumber()
        registerForEarbudNotifications()
    }

    func stopPlugin() {
    }

    func responseReceived(messageDescription: IncomingMessageDescription) {
        switch messageDescription {
        case .notification(let notificationID, let data):
            if let id = Gaia.V3EarbudNotification(rawValue: notificationID),
                id == .primaryEarbudWillChange {
                if let type = data.first {
                    let delay = data.count > 1 ? data[1] : 5
                    let handoverPayload = GaiaDeviceEarbudPluginNotification.Payload(device: device,
                                                                                     handoverDelay: Int(delay),
                                                                                     handoverIsStatic: type == 0)
                    let notification = GaiaDeviceEarbudPluginNotification(sender: self,
                                                                          payload: handoverPayload,
                                                                          reason: .handoverAboutToHappen)
                    notificationCenter.post(notification)
                }

            }
        case .response(let command, let data):
            if let id = Gaia.V3EarbudCommands(rawValue: command) {
                switch id {
                case .getSecondarySerialNumber:
                    if let newValue = String(data: data, encoding: .utf8) {
                        secondEarbudSerialNumber = newValue
                        let notification = GaiaDeviceEarbudPluginNotification(sender: self,
                                                                              payload: nil,
                                                                              reason: .secondSerial)
                        notificationCenter.post(notification)
                    }
                case .getWhichEarbudIsPrimary:
                    if let value = data.first {
						leftEarbudIsPrimary = value == 0
                    }
                }
           }
        case .error(let command, _, _):
            if let id = Gaia.V3EarbudCommands(rawValue: command),
                id == .getSecondarySerialNumber {
				secondEarbudSerialNumber = nil
                let notification = GaiaDeviceEarbudPluginNotification(sender: self,
                                                                      payload: nil,
                                                                      reason: .secondSerial)
                notificationCenter.post(notification)
            }

        default:
            break
        }
    }

    func didSendData(channel: GaiaDeviceConnectionChannel, error: Error?) {
    }
}

private extension GaiaDeviceEarbudPlugin {
    func getWhichEarbudIsPrimary() {
        let message = GaiaV3GATTPacket(featureID: .upgrade,
                                       commandID: Gaia.V3EarbudCommands.getWhichEarbudIsPrimary.rawValue,
                                       payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func getSecondarySerialNumber() {
        let message = GaiaV3GATTPacket(featureID: .upgrade,
                                       commandID: Gaia.V3EarbudCommands.getSecondarySerialNumber.rawValue,
                                       payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func registerForEarbudNotifications() {
        let message = GaiaV3GATTPacket(featureID: .basic,
                                       commandID: Gaia.V3BasicCommands.registerForNotification.rawValue,
                                       payload: Data([GaiaDevicePluginFeatureID.earbud.rawValue]))
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func cancelEarbudNotificationRegistration() {
        let message = GaiaV3GATTPacket(featureID: .basic,
                                       commandID: Gaia.V3BasicCommands.unregisterForNotification.rawValue,
                                       payload: Data([GaiaDevicePluginFeatureID.earbud.rawValue]))
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }
}


