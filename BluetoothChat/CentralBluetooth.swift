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

/**
 Singleton para manipular o CBCentralManager. Essa classe é responsável por listar os dispostivos bluetooths próximos e realizar a conexão com ele.
 Essa classe é um singleton para poder compartilhar por toda a aplicação os dispositivos bluetooths encontrados, não precisando localizá-lo novamente, e não haver problemas ao passar um periférico de uma instancia para outra.
 */
class CentralBluetooth: NSObject, CBCentralManagerDelegate {
    static let shared = CentralBluetooth()
    
    fileprivate var manager: CBCentralManager!
    
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
        print("Scan for peripheral stoped")
        manager.stopScan()
    }
    
    /**
     Podemos adicionar observers para sermos notificados quando um novo dispositivo bluetooth for encontrado.
     Para isso, precisamos assinar o protocolo ObserverPeripheralsList e então anexá-lo com esse método.
     
     - Parameter newObserver: Objeto que será notificado quando um novo periférico for encontrado
     */
    func attachObserverPeripheralsList(_ newObserver: ObserverPeripheralsList) {
        observersPeripheralsList.append(newObserver)
    }
    
    // Receive the update of central manager’s state
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Iniciar o scan. Só podemos fazer isso quando o state for powered on.
            print("Start scan for peripherals")
            manager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    // Um periférico foi encontrado
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        if peripheralsList.contains(peripheral) == false {
            peripheralsList.append(peripheral)
        }
    }
    
    /**
     Método para tentar realizar a conexão com algum periférico listado na propriedade peripheralsList.
     
     - Parameter peripheral: Periférico em que deseja conectar
     - Parameter callback: Closure que será executado quando a conexão for processada
     */
    func connect(in peripheral: CBPeripheral, callback: @escaping (_ peripheral: CBPeripheral, _ error: Error?) -> ()) {
        print("Trying connect in peripheral...")
        
        waitPeripheralConnectionCallback[peripheral] = callback
        manager.connect(peripheral, options: nil)
    }
    
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Success to connect in peripheral")
        
        waitPeripheralConnectionCallback[peripheral]!(peripheral, nil)
        waitPeripheralConnectionCallback.removeValue(forKey: peripheral)
    }
    
    internal func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect in peripheral!")
        
        waitPeripheralConnectionCallback[peripheral]!(peripheral, error)
        waitPeripheralConnectionCallback.removeValue(forKey: peripheral)
    }
}
