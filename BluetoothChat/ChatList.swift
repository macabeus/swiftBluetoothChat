//
//  ChatCBList.swift
//  BluetoothChat
//
//  Created by Bruno Macabeus Aquino on 19/03/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol ChatListDelegate: class {
    func newPeripheralDiscoved()
    func connectChatRoomSucceeded(chatRoomPeripheral: ChatRoomPeripheral)
    func connectChatRoomFailed(error: Error?)
}

/**
 Classe para listar as salas de chat e se conectarmos à ela.
 */
class ChatList {
    
    let delegate: ChatListDelegate
    
    init(delegate: ChatListDelegate) {
        self.delegate = delegate
        
        // TODO: Apenas faz o attach ao observer; em nenhum momento ele é removido! Talvez isso cause problemas
        CentralBluetooth.shared.attachObserverPeripheralsList(self)
    }
    
    /**
     Método para se conectar à uma sala de chat. Será chamado o delegate connectChatRoomSucceeded(chatRoomPeripheral:) em caso de sucesso ou o connectChatRoomFailed(error:) em caso de falha.
     
     - Parameter peripheral: Periférico da sala de chat a se conectar
     */
    func connect(in peripheral: CBPeripheral) {
        // TODO: Só deve tentar realizar a conexão se o dispositivo bluetooth for de fato de uma sala de chat. Uma possibilidade seria mudar o tipo do parâmetro de entrada, de "CBPeripheral" para um novo subtipo
        
        CentralBluetooth.shared.connect(in: peripheral) { peripheral, error in
            if let error = error {
                self.delegate.connectChatRoomFailed(error: error)
                return
            }
            
            let chatRoomPeripheral = ChatRoomPeripheral(peripheral: peripheral)
            self.delegate.connectChatRoomSucceeded(chatRoomPeripheral: chatRoomPeripheral)
        }
    }
}

extension ChatList: ObserverPeripheralsList {
    
    internal func update() {
        // TODO: Só deve chamar o delegate com os dispositivos bluetooth que forem de sala de chat, e retorná-los ao delegate
        self.delegate.newPeripheralDiscoved()
    }
}
