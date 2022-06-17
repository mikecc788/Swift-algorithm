//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

enum SettingRow {
    case title(String)
    case titleAndSubtitle(title: String, subtitle: String)
    case titleAndSwitch(title: String, switchOn: Bool)
    case titleSubtitleAndStepper(title: String, subtitle: String, value: Int, max: Int, step: Int)
}
