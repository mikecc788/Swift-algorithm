//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var GaiaDeviceNotification = Notification.Name("GaiaDeviceNotification")
}

struct GaiaDeviceNotification: GaiaNotification {
    enum Reason {
        case rssi
        case chargerStatus
        case connectionReady
        case connectionSetupFailed
    }

    var sender: GaiaNotificationSender
    var payload: GaiaDeviceProtocol?
    var reason: Reason

    static var name: Notification.Name = .GaiaDeviceNotification
}

private enum BasicNotificationIDs: UInt8 {
    case chargerStatus = 0
}

private enum BasicCommandErrors: UInt8 {
    case invalidCommandID = 0x01
    case insufficientResources = 0x03
    case invalidParameter = 0x05
    case incorrectState = 0x06
    case featureNotSupported = 0x08
    case invalidPDU = 0x0A

    func description() -> String {
        switch self {
        case .invalidCommandID:
            return "An invalid Command ID was specified"
        case .insufficientResources:
            return "The Command was valid, but the device could not successfully carry out the command"
        case .invalidParameter:
            return "Invalid parameter"
        case .incorrectState:
            return "The device is not in the correct state to process the command"
        case .featureNotSupported:
            return "An invalid Feature ID was specified"
        case .invalidPDU:
            return "An invalid PDU was received"
        }
    }
}

class GaiaDevice: NSObject, GaiaDeviceProtocol, GaiaNotificationSender {
    private(set) var version: GaiaDeviceVersion
    private(set) var serialNumber: String = NSLocalizedString("Unknown", comment: "Unknown Value")
    private(set) var deviceVariant: String = NSLocalizedString("Unknown", comment: "Unknown Value")
    private(set) var applicationVersion: String = NSLocalizedString("Unknown", comment: "Unknown Value")
    private(set) var apiVersion: String = NSLocalizedString("Unknown", comment: "Unknown Value")
    private(set) var isCharging: Bool = false

    var secondEarbudSerialNumber: String? {
        if let earbudPlugin = plugin(featureID: .earbud) as? GaiaDeviceEarbudPluginProtocol {
            return earbudPlugin.secondEarbudSerialNumber
        } else {
            return nil
        }
    }

    private var connection: GaiaDeviceConnectionProtocol
    private let notificationCenter : NotificationCenter
    private var supportedFeaturesData = Data()

    var connected: Bool {
        connection.connected
    }
    var uuid: UUID {
        connection.uuid
    }
    var name: String {
        connection.name
    }
    var deviceType: GaiaDeviceType {
        return .earbud
    }
    var rssi: Int {
        connection.rssi
    }

    var pluginsInUse = [GaiaDevicePluginProtocol] ()

    var supportedFeatures: [GaiaDevicePluginFeatureID] {
//        print("\(uuid) pluginsInUse: \(pluginsInUse)")
        return pluginsInUse.map { $0.featureID }
    }
    
    required init(connection: GaiaDeviceConnectionProtocol,
                  notificationCenter: NotificationCenter) {
        self.connection = connection
        self.notificationCenter = notificationCenter
        self.version = .unknown

        super.init()
        self.connection.delegate = self
    }

    func plugin(featureID: GaiaDevicePluginFeatureID) -> GaiaDevicePluginProtocol? {
        return pluginsInUse.first {
            $0.featureID == featureID
        }
    }
}

extension GaiaDevice: GaiaDeviceConnectionDelegate {
    func dataReceived(_ data: Data, channel: GaiaDeviceConnectionChannel) {
        if channel == .response {
            switch version {
            case .unknown:
                if let message = GaiaV2GATTPacket(data: data) {
                    handleV2VersionReply(message, channel: channel)
                }
        	case .v2:
                print ("v2: Raw Packet Data: \(data.hexString())")
                if let message = GaiaV2GATTPacket(data: data) {
                    print ("v2: Message: \(message)")
                    if !handleV2CoreReplies(message, channel: channel) {
                        pluginsInUse.forEach {
                            $0.responseReceived(messageDescription: message.messageDescription)
                        }
                    }
                }
            case .v3:
                print ("v3: Raw Packet Data: \(data.hexString())")
                if let message = GaiaV3GATTPacket(data: data) {
                    print ("v3: Message: \(message)")
                    if !handleV3CoreReplies(message, channel: channel) {
                        pluginsInUse.forEach {
                            if message.featureID == $0.featureID {
                                $0.responseReceived(messageDescription: message.messageDescription)
                            }
                        }
                    }
                }
            }
        } else if channel == .data {
            // RWCP use data channel
            switch version {
            case .v2, .v3:
                pluginsInUse.forEach {
                    if let updaterPlugin = $0 as? GaiaDeviceUpdaterPluginProtocol {
                        updaterPlugin.dataReceived(data) // Sent as is
                    }
                }
            default:
                break
            }
        }
    }

    func didSendData(channel: GaiaDeviceConnectionChannel, error: Error?) {
        if version == .v2 || version == .v3 {
            pluginsInUse.forEach {
                $0.didSendData(channel: channel, error: error)
            }
        }
    }

    func rssiDidChange() {
        notificationCenter.post(GaiaDeviceNotification(sender: self,
                                                       payload: self,
                                                       reason: .rssi))
    }

    func connectionAvailable() {
        print("Connection available - current version: \(version)")
        fetchDeviceVersion()
    }

    func connectionUnavailable() {
        print("Connection Unavailable")
        notificationCenter.post(GaiaDeviceNotification(sender: self,
                                                       payload: self,
                                                       reason: .connectionSetupFailed))
    }

    func reset() {
        version = .unknown
        pluginsInUse.forEach {
            $0.stopPlugin()
        }
        pluginsInUse.removeAll()
    }
}

private extension GaiaDevice {
    func fetchDeviceVersion() {
        print("Sending Version Request")
    	let message = GaiaV2GATTPacket(commandID: Gaia.V2Commands.getAPIVersion.rawValue,
                                       payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func handleV2VersionReply(_ packet: GaiaV2GATTPacket, channel: GaiaDeviceConnectionChannel) {
        guard channel == .response else {
			return
        }

        switch packet.messageDescription {
        case .response(let commandID, let data):
            if commandID == Gaia.V2Commands.getAPIVersion.rawValue {
                print("Get API Version replied....")
                if data.count >= 3 {
                    let protocolVersion = data[0]
                    let apiVersionMajor = data[1]
                    let apiVersionMinor = data[2]
                    apiVersion = "\(apiVersionMajor).\(apiVersionMinor)"
                    print("Success: protocol version: \(protocolVersion) API version: \(apiVersion)")
                    version = apiVersionMajor > 2 ? .v3 : .v2
                    print("Device is \(version)")
                } else {
                    print("Huh???? V2 then...")
                    version = .v2
                }
                fetchPlugins()
            }
        case .error(let commandID, _, _):
            if commandID == Gaia.V2Commands.getAPIVersion.rawValue {
                print("Error fetching version: Version 2 assumed")
                version = .v2
                notificationCenter.post(GaiaDeviceNotification(sender: self,
                                                               payload: self,
                                                               reason: .connectionSetupFailed))
                fetchPlugins()
            }
        default:
            break
        }
    }

    func handleV2CoreReplies(_ packet: GaiaV2GATTPacket, channel: GaiaDeviceConnectionChannel) -> Bool {
		return false
    }

    func handleV3CoreReplies(_ packet: GaiaV3GATTPacket, channel: GaiaDeviceConnectionChannel) -> Bool {
        guard packet.featureID == .basic else {
            return false
        }

        switch packet.messageDescription {
        case .notification(let notificationID, let payload):
            if let notification = BasicNotificationIDs(rawValue: notificationID),
                notification == .chargerStatus {

                isCharging = (payload.first ?? 0) == 1
                notificationCenter.post(GaiaDeviceNotification(sender: self,
                                                               payload: self,
                                                               reason: .chargerStatus))
            }
            return true
        case .error(_ , let errorCode, _):
            if let reason = Gaia.CommandErrorCodes(rawValue: errorCode) {
                print("Received Error: \(reason.userDescription())")
            } else {
                print("Received Error with unknown reason")
            }
            return true
        case .response(let command, let data):
            if let basicCommand = Gaia.V3BasicCommands(rawValue: command) {
                print ("Received: Basic Response: \(basicCommand) bytes: \(data.hexString())")
                switch basicCommand {
                case .getAPIVersion:
                break // We get the value from the V2 method
                case .getSupportedFeatures,
                     .getSupportedFeaturesNext:
                    if let more = data.first {
                        let featureData = (data.count > 1) ? data.advanced(by: 1) : Data()
                        supportedFeaturesData.append(featureData)
                        if more == 1 {
                            // There's more so we make another request
                            let message = GaiaV3GATTPacket(featureID: .basic,
                                                           commandID: Gaia.V3BasicCommands.getSupportedFeaturesNext.rawValue,
                                                           payload: Data())
                            connection.sendData(channel: .command, payload: message.data, responseExpected: true)
                        } else {
                            // There's no more so we process
                            processSupportedFeatureResponse()
                            requestRemainingBasicInfo()
                        }
                    }
                case .getSerialNumber:
                    serialNumber = String(data: data, encoding: .utf8) ?? "Unknown"
                case .getVariantName:
                    deviceVariant = String(data: data, encoding: .utf8) ?? "Unknown"
                case .getApplicationVersion:
                    applicationVersion = String(data: data, encoding: .utf8) ?? "Unknown"
                case .registerForNotification:
                    // Completed basic set up
                    notificationCenter.post(GaiaDeviceNotification(sender: self,
                                                                   payload: self,
                                                                   reason: .connectionReady))
                case .deviceReset,
                     .unregisterForNotification:
                    break
                }
                return true
            }
            return true
        default:
            return true
        }
    }

    func fetchPlugins() {
        pluginsInUse.removeAll()
        
        switch version {
        case .v2:
            pluginsInUse.append(GaiaDeviceUpdaterPlugin(version: 0,
                                                        device: self,
                                                        connection: connection,
                                                        notificationCenter: notificationCenter))
            pluginsInUse.forEach {
                print("\(uuid) Starting \($0.title)")
                $0.startPlugin()
            }

            print("\(uuid) Notifying readiness with \(pluginsInUse)")
            notificationCenter.post(GaiaDeviceNotification(sender: self,
                                                           payload: self,
                                                           reason: .connectionReady))
        case .v3:
            print("Requesting supported features - v3")
            // make API request for features
            supportedFeaturesData = Data()
            let message = GaiaV3GATTPacket(featureID: .basic,
                                           commandID: Gaia.V3BasicCommands.getSupportedFeatures.rawValue,
                                           payload: Data())

            connection.sendData(channel: .command, payload: message.data, responseExpected: true)
        default:
            break
        }
    }

    func processSupportedFeatureResponse() {
        guard supportedFeaturesData.count % 2 == 0 else {
            print("Supported features data has odd number of bytes")
            return
        }

        for index in stride(from: 0, to: supportedFeaturesData.count, by: 2) {
            if let featureID = GaiaDevicePluginFeatureID(rawValue: supportedFeaturesData[index]) {
                let version = supportedFeaturesData[index + 1]

                if featureID == GaiaDeviceUpdaterPlugin.featureID {
                    pluginsInUse.append(GaiaDeviceUpdaterPlugin(version: version,
                                                                device: self,
                                                                connection: connection,
                                                                notificationCenter: notificationCenter))
                }

                if featureID == GaiaDeviceEarbudPlugin.featureID {
                    pluginsInUse.append(GaiaDeviceEarbudPlugin(version: version,
                                                               device: self,
                                                               connection: connection,
                                                               notificationCenter: notificationCenter))
                }

                if featureID == GaiaDeviceNoiseCancellationPlugin.featureID {
                    pluginsInUse.append(GaiaDeviceNoiseCancellationPlugin(version: version,
                                                                          device: self,
                                                                          connection: connection,
                                                                          notificationCenter: notificationCenter))
                }

                if featureID == GaiaDeviceVoiceAssistantPlugin.featureID {
                    pluginsInUse.append(GaiaDeviceVoiceAssistantPlugin(version: version,
                                                                       device: self,
                                                                       connection: connection,
                                                                       notificationCenter: notificationCenter))
                }
            }
        }
    }

    func requestRemainingBasicInfo() {
        var message = GaiaV3GATTPacket(featureID: .basic,
                                       commandID: Gaia.V3BasicCommands.getSerialNumber.rawValue,
                                       payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)

        message = GaiaV3GATTPacket(featureID: .basic,
                                   commandID: Gaia.V3BasicCommands.getVariantName.rawValue,
                                   payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)

        message = GaiaV3GATTPacket(featureID: .basic,
                                   commandID: Gaia.V3BasicCommands.getApplicationVersion.rawValue,
                                   payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)

        message = GaiaV3GATTPacket(featureID: .basic,
                                   commandID: Gaia.V3BasicCommands.registerForNotification.rawValue,
                                   payload: Data([GaiaDevicePluginFeatureID.basic.rawValue]))
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)

        // We do this after basic requests.
        
        pluginsInUse.forEach {
            $0.startPlugin()
        }
    }
}
