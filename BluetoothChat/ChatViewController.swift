//
//  ChatViewController.swift
//  BluetoothChat
//
//  Created by Bruno Macabeus Aquino on 16/03/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit
import CoreBluetooth

class ChatViewController: UIViewController {
    
    @IBOutlet weak var textFieldMessage: UITextField!
    @IBOutlet weak var textViewChatLog: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ChatCB.shared.delegate = self
    }

    @IBAction func buttonSendMessage(_ sender: Any) {
        let message = textFieldMessage.text!
        ChatCB.shared.sendMessage(message)
        appendChatLog(message)
    }
    
    func appendChatLog(_ text: String) {
        textViewChatLog.text = textViewChatLog.text + "\n" + text
    }

}

extension ChatViewController: ChatCBDelegate {
    func newPeripheralDiscoved(_ peripheral: CBPeripheral) {
        print("newPeripheralDiscoved")
    }
    
    func connectPeripheralSucceeded(_ peripheral: CBPeripheral) {
        print("connectPeripheralSucceeded")
    }
    
    func connectPeripheralFailed(_ peripheral: CBPeripheral, error: Error?) {
        print("connectPeripheralFailed")
    }
    
    func createPeripheralSucceeded(_ peripheralManager: CBPeripheralManager) {
        print("createPeripheralSucceeded")
    }
    
    func receivedMessage(_ message: String) {
        appendChatLog(message)
    }
}
