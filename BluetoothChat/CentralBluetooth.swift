//
//  ChatCB.swift
//  BluetoothChat
//
//  Created by Bruno Macabeus Aquino on 15/03/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol ObserverPeripheralsList {
    func update()
}

class CentralBluetooth: NSObject, CBCentralManagerDelegate {
    static let shared = CentralBluetooth()
    
    private var manager: CBCentralManager!
    
    private var observersPeripheralsList: [ObserverPeripheralsList] = []
    var peripheralsList: [CBPeripheral] = [] {
        didSet {
            for observer in observersPeripheralsList {
                observer.update()
            }
        }
    }
    
    private var waitPeripheralConnectionCallback: [CBPeripheral: (_ peripheral: CBPeripheral, _ error: Error?) -> ()] = [:]

    private override init() {
        super.init()
        
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func stopScan() {
        manager.stopScan()
    }
    
    func attachObserverPeripheralsList(_ newObserver: ObserverPeripheralsList) {
        observersPeripheralsList.append(newObserver)
    }
    
    // Receive the update of central manager’s state
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Iniciar o scan
            // Só podemos fazer isso quando o state por powered on
            manager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        if peripheralsList.contains(peripheral) == false {
            peripheralsList.append(peripheral)
        }
    }
    
    func connect(in peripheral: CBPeripheral, callback: @escaping (_ peripheral: CBPeripheral, _ error: Error?) -> ()) {
        waitPeripheralConnectionCallback[peripheral] = callback
        manager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected!")
        
        waitPeripheralConnectionCallback[peripheral]!(peripheral, nil)
        waitPeripheralConnectionCallback.removeValue(forKey: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed...")
        
        waitPeripheralConnectionCallback[peripheral]!(peripheral, error)
        waitPeripheralConnectionCallback.removeValue(forKey: peripheral)
    }
}
