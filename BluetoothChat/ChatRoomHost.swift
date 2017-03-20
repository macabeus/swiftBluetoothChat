//
//  ChatCBHostRoom.swift
//  BluetoothChat
//
//  Created by Bruno Macabeus Aquino on 19/03/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import Foundation
import CoreBluetooth

/**
 Classe para hostear uma sala de chat. É complementar à classe ChatRoomPeripheral.
 */
class ChatRoomHost: NSObject {
    
    fileprivate var peripheralManager: CBPeripheralManager?
    fileprivate let characteristicChat = CBMutableCharacteristic(
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
    // Esses dois métodos são para criar os services e characteristics a respeito da sala de chat.
    
    internal func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        let serviceUUID = CBUUID.serviceChat
        let service = CBMutableService(type: serviceUUID, primary: true)
        
        service.characteristics = [characteristicChat]
        peripheralManager!.add(service)
        
        let advertisementData = [CBAdvertisementDataLocalNameKey: "Test Device"] // TODO: O usuário precisa poder escolher o nome da sala de chat, ao invés de ser sempre "Test Device"
        peripheralManager!.startAdvertising(advertisementData)
    }
    
    internal func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Failed to create a chat room... Error: \(error)")
            return
        }
        
        print("Succeeded to create a chat room!")
        delegate!.chatLoadFinish() // Terminamos de criar os services e characteristics, então está tudo pronto
    }
    
    // Delegate chamado quando alguém quer *ler* os dados do meu periférico
    internal func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic.uuid.isEqual(CBUUID.characteristicChatMessage) {
            request.value = characteristicChat.value
            
            peripheralManager!.respond(to: request, withResult: .success)
        }
    }
    
    // Delegate chamado quando alguém quer *escrever* os dados do meu periférico
    internal func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic.uuid.isEqual(CBUUID.characteristicChatMessage) {
                characteristicChat.value = request.value
                
                delegate!.receivedMessage(String(data: request.value!, encoding: .utf8)!)
            }
        }
        
        peripheralManager!.respond(to: requests[0], withResult: .success)
    }
}
