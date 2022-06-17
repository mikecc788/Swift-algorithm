//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

enum ReplayFileCommand: String {
    case connect = "O"
    case disconnect = "X"
    case fromCommand = "<C"
    case fromResponse = "<R"
    case fromData = "<D"
    case toCommand = ">C"
    case toResponse = ">R"
    case toData = ">D"
    case error = "E"
    case timeout = "T"
    case unknown = "!"

    static func decodeFileString(fileString: String) -> (command: ReplayFileCommand, remainder: String) {
        if let firstCharacter = fileString.first {
            var testStr = String(firstCharacter)
            if let testResult = ReplayFileCommand(rawValue: testStr) {
                return (testResult, String(fileString.dropFirst()))
            } else if fileString.count > 1 {
                testStr = String(fileString.prefix(2))
                if let testResult = ReplayFileCommand(rawValue: testStr) {
                    return (testResult, String(fileString.dropFirst(2)))
                }
            }
        }
        return (Self.unknown, fileString)
    }

    func string(value: String) -> String {
        return self.rawValue + value
    }
}

class GaiaReplayScriptDeviceConnection: NSObject, GaiaDeviceConnectionProtocol {
    weak var delegate: GaiaDeviceConnectionDelegate?

    private(set) var uuid: UUID = UUID()

    private(set) var name: String = "Replay Script Device"

    private(set) var connected: Bool = false

    private(set) var available: Bool = false

    private(set) var rssi: Int = 0

    private(set) var isDataLengthExtensionSupported: Bool = true
    private(set) var maximumWriteLength: Int = 23
    private(set) var maximumWriteWithoutResponseLength: Int = 23

    weak var scriptDelegate: ScriptConnectionDelegate?

    private let fileContents: [String]
    private var fileContentsIndex = -1
    private let fileAccessQueue = DispatchQueue(label: "com.qualcomm.qti.newgaiacontrol.replayfile") // serial

	private var sendQueue = [String]()

    init(path: URL) {
        var str = ""
        do {
            str = try String(contentsOf: path)
        } catch (let e) {
			print("Couldn't read replay file: \(path)\nError: \(e)")
        }
        fileContents = str.components(separatedBy: .newlines)
    }

    func sendData(channel: GaiaDeviceConnectionChannel, payload: Data, responseExpected: Bool) {
        fileAccessQueue.async { [weak self] in
            self?.processSend(channel: channel, payload: payload)
        }
    }

    func fetchValue(channel: GaiaDeviceConnectionChannel) {
        // Fetches are coded as "To" Messages without data
        sendData(channel: channel, payload: Data(), responseExpected: true)
    }

    func connect() {
        assert(!connected)
        queueNextLine()
    }

    func disconnect() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.fileContentsIndex = -1
            self.connected = false
            self.available = false
            self.delegate?.connectionUnavailable()
            self.scriptDelegate?.scriptDisconnected()
        }
    }
}

private extension GaiaReplayScriptDeviceConnection {
    func processSend(channel: GaiaDeviceConnectionChannel, payload: Data) {
        guard fileContentsIndex < fileContents.count else {
            return
        }

        // Are we sat waiting for a send?

        let hex = payload.hexString()
        var code: ReplayFileCommand = .unknown
        switch channel {
        case .command:
            code = .toCommand
        case .response:
            code = .toResponse
        case .data:
            code = .toData
        }

        let stringToSend = code.rawValue + hex
        sendQueue.append(stringToSend)

        let line = fileContents[fileContentsIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let decoded = ReplayFileCommand.decodeFileString(fileString: line)

        if decoded.command == .toCommand || decoded.command == .toResponse || decoded.command == .toData {
			// We are currently waiting for a send - what good luck.
            processLineFromReplay()
        }
    }

    func queueNextLine() {
        fileContentsIndex = fileContentsIndex + 1
        fileAccessQueue.asyncAfter(deadline:.now() + 0.1) { [weak self] in
            self?.processLineFromReplay()
        }
    }

    func processLineFromReplay() {
        dispatchPrecondition(condition: .onQueue(fileAccessQueue))

        guard fileContentsIndex < fileContents.count else {
            return
        }

        let line = fileContents[fileContentsIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let decoded = ReplayFileCommand.decodeFileString(fileString: line)

        switch decoded.command {
        case .connect:
            connected = true
            available = true
            DispatchQueue.main.async { [weak self] in
                self?.scriptDelegate?.scriptConnected()
                self?.delegate?.connectionAvailable()
            }
            queueNextLine()
        case .disconnect:
            disconnect()
        case .fromCommand:
            if let data = decoded.remainder.fromHex() {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.dataReceived(data, channel: .command)
                }
            }
            queueNextLine()
        case .fromResponse:
            if let data = decoded.remainder.fromHex() {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.dataReceived(data, channel: .response)
                }
            }
            queueNextLine()
        case .fromData:
            if let data = decoded.remainder.fromHex() {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.dataReceived(data, channel: .data)
                }
            }
            queueNextLine()
        case .toCommand,
             .toResponse,
             .toData:

            if let firstWaiting = sendQueue.first {
                // We need to wait for the incoming message from the app so we do nothing here
                if firstWaiting != line {
                    print("Unexpected Send!\nExpected: \(line)\nGot: \(firstWaiting)")
                }
                sendQueue.removeFirst()
                queueNextLine()
            } // else we need to wait for the incoming message from the app so we do nothing here
        case .unknown,
             .error:
            queueNextLine()
        case .timeout:
            if let delay = Double(decoded.remainder) {
                fileAccessQueue.asyncAfter(deadline:.now() + delay) { [weak self] in
                    self?.queueNextLine()
                }
            } else {
                print("No timeout value - skipping")
                queueNextLine()
            }
        }
    }
}

extension Data {
    func hexString() -> String {
        return self.reduce("", { $0 + String(format: "%02x", $1) } )
    }
}

extension String {
    func fromHex() -> Data? {
        if count % 2 != 0 {
            return nil
        }

        let hexChars = ["0", "1", "2", "3", "4", "5", "6", "7",
                         "8","9", "A", "B", "C", "D", "E", "F"]
        let uppercaseArray = Array(self.uppercased())
        let bytesStrArray = stride(from: 0, to: uppercaseArray.count, by: 2).map { String(uppercaseArray[$0..<$0+2]) }
        var resultBytes = [UInt8] ()
        bytesStrArray.forEach { pair in
            let firstCharIndex = hexChars.firstIndex(of: String(pair.first!)) ?? 0
            let secondCharIndex = hexChars.firstIndex(of: String(pair.last!)) ?? 0
            resultBytes.append(UInt8((firstCharIndex * 16) + secondCharIndex))
        }
		return Data(resultBytes)
    }
}
