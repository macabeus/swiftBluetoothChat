//
//  ChatCB.swift
//  BluetoothChat
//
//  Created by Bruno Macabeus Aquino on 15/03/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol ChatCBDelegate: class {
    func newPeripheralDiscoved(_ peripheral: CBPeripheral)
    func connectPeripheralSucceeded(_ peripheral: CBPeripheral)
    func connectPeripheralFailed(_ peripheral: CBPeripheral, error: Error?)
    func createPeripheralSucceeded(_ peripheralManager: CBPeripheralManager)
    func receivedMessage(_ message: String)
}

class ChatCB: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    static let shared = ChatCB()
    
    private var manager: CBCentralManager!
    private var peripheralChat: CBPeripheral?
    private var peripheralServiceChat: CBService?
    private var peripheralManager: CBPeripheralManager?
    weak var delegate: ChatCBDelegate?
    var peripheralsList: [CBPeripheral] = [] // todo: talvez seja melhor ser um set?
    let characteristicChatGlobal = CBMutableCharacteristic(
        type: CBUUID(string: "2222"),
        properties: [.notify, .read, .write],
        value: nil,
        permissions: [.readable, .writeable]
    )

    private override init() {
        super.init()
        
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func stopScan() {
        manager.stopScan()
    }
    
    // Receive the update of central manager’s state
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Iniciar o scan
            // Só podemos fazer isso quando o state por powered on
            manager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    // Receive the results of scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        //print("peripheral: \(peripheral)")
        if peripheralsList.contains(peripheral) == false {
            peripheralsList.append(peripheral)
            delegate!.newPeripheralDiscoved(peripheral)
        }
    }
    
    // Start connecting
    func connect(in peripheral: CBPeripheral) {
        manager.connect(peripheral, options: nil)
    }
    
    // result of connecting: Called when it succeeded
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected!")
        delegate!.connectPeripheralSucceeded(peripheral)
        
        peripheralChat = peripheral
        peripheralChat!.delegate = self
        peripheralChat!.discoverServices(nil)
    }
    
    // result of connecting: Called when it failed
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed...")
        delegate!.connectPeripheralFailed(peripheral, error: error)
    }
    
    // send message
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("error: \(error)")
            return
        }
        
        let services = peripheral.services!
        print("Found \(services.count) services! :\(services)")
        peripheralServiceChat = services.last! // todo: preciso garantir que realmente vá atribuir o <CBService: 0x170264900, isPrimary = YES, UUID = 1111>
        
        peripheralChat!.discoverCharacteristics(nil, for: peripheralServiceChat!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("error: \(error)")
            return
        }
        
        let characteristics = service.characteristics
        print("Found \(characteristics!.count) characteristics!")

        peripheralChat!.setNotifyValue(true, for: peripheralServiceChat!.characteristics!.last!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error: \(error)")
        } else {
            print("isNotifying: \(characteristic.isNotifying)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error: \(error)")
            return
        }
        
        print("characteristic UUID: \(characteristic.uuid), value: \(characteristic.value)")
        delegate!.receivedMessage(String(data: characteristic.value!, encoding: .utf8)!)
    }
    
    func sendMessage(_ text: String) {
        if let peripheralChat = peripheralChat {
            peripheralChat.writeValue(text.data(using: .utf8)!, for: peripheralServiceChat!.characteristics!.last!, type: .withResponse)
        } else {
            peripheralManager!.updateValue(text.data(using: .utf8)!, for: characteristicChatGlobal, onSubscribedCentrals: nil)
        }
        
    }
    
    func createChatServices() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("state: \(peripheral.state)")
        
        let serviceUUID = CBUUID(string: "1111")
        let service = CBMutableService(type: serviceUUID, primary: true)
        
        service.characteristics = [characteristicChatGlobal]
        peripheralManager?.add(service)

        let advertisementData = [CBAdvertisementDataLocalNameKey: "Test Device"]
        peripheralManager!.startAdvertising(advertisementData)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Failed… error: \(error)")
            return
        }
        
        print("Succeeded!")
        delegate!.createPeripheralSucceeded(peripheral)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic.uuid.isEqual(CBUUID(string: "2222")) {
            print("lendo...")
            // Set the correspondent characteristic's value
            // to the request
            request.value = characteristicChatGlobal.value
            
            // Respond to the request
            peripheralManager!.respond(to: request, withResult: .success)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic.uuid.isEqual(CBUUID(string: "2222")) {
                print("escrevendo...")
                // Set the request's value
                // to the correspondent characteristic
                characteristicChatGlobal.value = request.value
                
                delegate!.receivedMessage(String(data: request.value!, encoding: .utf8)!)
            }
        }
        peripheralManager!.respond(to: requests[0], withResult: .success)
    }
}
