//
//  ChatCBList.swift
//  BluetoothChat
//
//  Created by Bruno Macabeus Aquino on 19/03/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol ChatListDelegate: class {
    func newPeripheralDiscoved()
    func connectChatRoomSucceeded(chatRoomPeripheral: ChatRoomPeripheral)
    func connectChatRoomFailed(error: Error?)
}

class ChatList {
    
    let delegate: ChatListDelegate
    
    init(delegate: ChatListDelegate) {
        self.delegate = delegate
        
        CentralBluetooth.shared.attachObserverPeripheralsList(self)
    }
    
    func connect(in peripheral: CBPeripheral) {
        CentralBluetooth.shared.connect(in: peripheral) { peripheral, error in
            if let error = error {
                self.delegate.connectChatRoomFailed(error: error)
                return
            }
            
            let chatRoomPeripheral = ChatRoomPeripheral(peripheral: peripheral)
            self.delegate.connectChatRoomSucceeded(chatRoomPeripheral: chatRoomPeripheral)
        }
    }
}

extension ChatList: ObserverPeripheralsList {
    
    func update() {
        self.delegate.newPeripheralDiscoved()
    }
}
