//
//  Constants.swift
//  BluetoothChat
//
//  Created by Bruno Macabeus Aquino on 19/03/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import Foundation
import CoreBluetooth


extension CBUUID {
    static let serviceChat = CBUUID(string: "1000")
    static let characteristicChatMessage = CBUUID(string: "1001")
}
