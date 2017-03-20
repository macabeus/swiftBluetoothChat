//
//  BluetoothListViewController.swift
//  BluetoothChat
//
//  Created by Bruno Macabeus Aquino on 15/03/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothListViewController: UIViewController {
    
    @IBOutlet weak var tableChats: UITableView!
    var chatList: ChatList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableChats.delegate = self
        tableChats.dataSource = self
        
        chatList = ChatList(delegate: self)
    }
    
    @IBAction func btnCreateChatRoom(_ sender: Any) {
        self.performSegue(withIdentifier: "segueChat", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueChat" {
            CentralBluetooth.shared.stopScan()
            
            let destination = segue.destination as! ChatViewController
            if let chatRoomPeripheral = sender as? ChatRoomPeripheral {
                destination.chatRoomPeripheral = chatRoomPeripheral
            }
        }
    }
}

extension BluetoothListViewController: ChatListDelegate {
    func newPeripheralDiscoved() {
        tableChats.reloadData()
    }
    
    func connectChatRoomSucceeded(chatRoomPeripheral: ChatRoomPeripheral) {
        self.performSegue(withIdentifier: "segueChat", sender: chatRoomPeripheral)
    }
    
    func connectChatRoomFailed(error: Error?) {
        // TODO: mostrar um alerta na UI
        print(error ?? "error unknown")
    }
}

extension BluetoothListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CentralBluetooth.shared.peripheralsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellChat", for: indexPath) as! CellChat
        
        let currentPeripheral = CentralBluetooth.shared.peripheralsList[indexPath.row]
        if currentPeripheral.name != "" {
            cell.labelChatName.text = currentPeripheral.name
        } else {
            cell.labelChatName.text = currentPeripheral.identifier.description
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheralSelected = CentralBluetooth.shared.peripheralsList[indexPath.row]
        
        chatList!.connect(in: peripheralSelected)
    }
}
