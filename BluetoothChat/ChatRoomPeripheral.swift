//
//  ChatCBRoom.swift
//  BluetoothChat
//
//  Created by Bruno Macabeus Aquino on 19/03/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import Foundation
import CoreBluetooth

class ChatRoomPeripheral: NSObject {
    
    fileprivate var peripheralServiceChat: CBService?
    var delegate: ChatRoomDelegate?
    let peripheral: CBPeripheral
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        super.init()

        self.peripheral.delegate = self
        self.peripheral.discoverServices(nil)
    }
    
    func sendMessage(_ text: String) {
        peripheral.writeValue(text.data(using: .utf8)!, for: peripheralServiceChat!.characteristics!.last!, type: .withResponse)
    }
}

extension ChatRoomPeripheral: CBPeripheralDelegate {
    // esses métodos são para reconhecer o bluetooth periférico, os services e characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("error: \(error)")
            return
        }
        
        let services = peripheral.services!
        print("Found \(services.count) services! :\(services)")
        peripheralServiceChat = services.last! // todo: preciso garantir que realmente vá atribuir o <CBService: 0x170264900, isPrimary = YES, UUID = 1111>
        
        peripheral.discoverCharacteristics(nil, for: peripheralServiceChat!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("error: \(error)")
            return
        }
        
        let characteristics = service.characteristics
        print("Found \(characteristics!.count) characteristics!")
        
        peripheral.setNotifyValue(true, for: peripheralServiceChat!.characteristics!.last!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error: \(error)")
        } else {
            print("isNotifying: \(characteristic.isNotifying)")
            delegate!.chatLoadFinish()
        }
    }
    
    //
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error: \(error)")
            return
        }
        
        print("characteristic UUID: \(characteristic.uuid), value: \(characteristic.value)")
        delegate!.receivedMessage(String(data: characteristic.value!, encoding: .utf8)!)
    }
}
