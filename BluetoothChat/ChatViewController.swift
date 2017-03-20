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
    var chatRoomPeripheral: ChatRoomPeripheral?
    var chatRoomHost: ChatRoomHost?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let chatRoomPeripheral = chatRoomPeripheral {
            // se estiver conectado a uma sala de chat externa, apenas precisamos setar o delegate
            chatRoomPeripheral.delegate = self
        } else {
            // caso contrário, vamos criar a nossa sala de chat aqui
            chatRoomHost = ChatRoomHost()
            chatRoomHost!.delegate = self
        }
    }

    @IBAction func buttonSendMessage(_ sender: Any) {
        let message = textFieldMessage.text!
        appendChatLog(message)
        
        // TODO: Talvez seja bom usar polimorfismo para não precisar desse if
        if let chatRoomPeripheral = chatRoomPeripheral {
            chatRoomPeripheral.sendMessage(message)
        } else if let chatCBHostRoom = chatRoomHost {
            chatCBHostRoom.sendMessage(message)
        }
    }
    
    func appendChatLog(_ text: String) {
        textViewChatLog.text = textViewChatLog.text + "\n" + text
    }

}

extension ChatViewController: ChatRoomDelegate {
    func receivedMessage(_ message: String) {
        appendChatLog(message)
    }
    
    func chatLoadFinish() {
        appendChatLog("CHAT PRONTO PARA USAR!")
    }
}
