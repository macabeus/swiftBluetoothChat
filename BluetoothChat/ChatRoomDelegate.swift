//
//  ChatRoomDelegate.swift
//  BluetoothChat
//
//  Created by Bruno Macabeus Aquino on 19/03/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import Foundation

protocol ChatRoomDelegate: class {
    func receivedMessage(_ message: String)
    func chatLoadFinish()
}
