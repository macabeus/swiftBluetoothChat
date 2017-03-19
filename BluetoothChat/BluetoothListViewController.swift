//
//  BluetoothListViewController.swift
//  BluetoothChat
//
//  Created by Bruno Macabeus Aquino on 15/03/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

/*
 TODO:
 - na tableview, só deve listar o que realmente foi fala de chat
 - ao enviar mensagem, também precisa enviar o nome do usuário no iPhone
 - salas de chat podem ter nomes que, enventualmente, sejam modificadas
 - enviar fotos
 */

import UIKit
import CoreBluetooth

class BluetoothListViewController: UIViewController {
    
    @IBOutlet weak var tableChats: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableChats.delegate = self
        tableChats.dataSource = self
        
        ChatCB.shared.delegate = self
    }
    
    @IBAction func btnCreateChatRoom(_ sender: Any) {
        ChatCB.shared.createChatServices()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueChat" {
            ChatCB.shared.stopScan()
            
            //let destination = segue.destination as! ChatViewController
        }
    }
}

extension BluetoothListViewController: ChatCBDelegate {
    func newPeripheralDiscoved(_ peripheral: CBPeripheral) {
        tableChats.reloadData()
    }
    
    func connectPeripheralSucceeded(_ peripheral: CBPeripheral) {
        self.performSegue(withIdentifier: "segueChat", sender: self)
    }
    
    func connectPeripheralFailed(_ peripheral: CBPeripheral, error: Error?) {
        // TODO: mostrar um alerta na UI
        print(error ?? "error unknown")
    }
    
    func createPeripheralSucceeded(_ peripheralManager: CBPeripheralManager) {
        self.performSegue(withIdentifier: "segueChat", sender: self)
    }
    
    func receivedMessage(_ message: String) {
        print("receivedMessage")
    }
}

extension BluetoothListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatCB.shared.peripheralsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellChat", for: indexPath) as! CellChat
        
        let currentPeripheral = ChatCB.shared.peripheralsList[indexPath.row]
        if currentPeripheral.name != "" {
            cell.labelChatName.text = currentPeripheral.name
        } else {
            cell.labelChatName.text = currentPeripheral.identifier.description
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheralSelected = ChatCB.shared.peripheralsList[indexPath.row]
        
        ChatCB.shared.connect(in: peripheralSelected)
    }
}
