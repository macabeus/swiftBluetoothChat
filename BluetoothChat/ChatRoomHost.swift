//
//  ChatCBHostRoom.swift
//  BluetoothChat
//
//  Created by Bruno Macabeus Aquino on 19/03/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import Foundation
import CoreBluetooth

class ChatRoomHost: NSObject {
    
    fileprivate var peripheralManager: CBPeripheralManager?
    let characteristicChat = CBMutableCharacteristic(
        type: CBUUID.characteristicChatMessage,
        properties: [.notify, .read, .write],
        value: nil,
        permissions: [.readable, .writeable]
    )
    var delegate: ChatRoomDelegate?

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func sendMessage(_ text: String) {
        peripheralManager!.updateValue(text.data(using: .utf8)!, for: characteristicChat, onSubscribedCentrals: nil)
    }

}

extension ChatRoomHost: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("state: \(peripheral.state)")
        
        let serviceUUID = CBUUID.serviceChat
        let service = CBMutableService(type: serviceUUID, primary: true)
        
        service.characteristics = [characteristicChat]
        peripheralManager!.add(service)
        
        let advertisementData = [CBAdvertisementDataLocalNameKey: "Test Device"]
        peripheralManager!.startAdvertising(advertisementData)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Failed… error: \(error)")
            return
        }
        
        print("Succeeded!")
        delegate!.chatLoadFinish()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic.uuid.isEqual(CBUUID.characteristicChatMessage) {
            print("lendo...")
            // Set the correspondent characteristic's value
            // to the request
            request.value = characteristicChat.value
            
            // Respond to the request
            peripheralManager!.respond(to: request, withResult: .success)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic.uuid.isEqual(CBUUID.characteristicChatMessage) {
                print("escrevendo...")
                // Set the request's value
                // to the correspondent characteristic
                characteristicChat.value = request.value
                
                delegate!.receivedMessage(String(data: request.value!, encoding: .utf8)!)
            }
        }
        peripheralManager!.respond(to: requests[0], withResult: .success)
    }
}
