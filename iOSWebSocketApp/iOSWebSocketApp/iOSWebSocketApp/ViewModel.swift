//
//  ViewModel.swift
//  iOSWebSocketApp
//
//  Created by Arthur Nsereko Kahwa on 7/16/23.
//

import Foundation

@MainActor
class ViewModel: ObservableObject {
    @Published var messages: [MessageModel] = []
    @Published var isConnected = false
    
    private let session = URLSession.shared
    private var socket: URLSessionWebSocketTask?
    private let endpoint = "ws://localhost:3000"
    
    private func connectionStatus() {
        socket?.sendPing(pongReceiveHandler: { error in
            guard error == nil
            else {
                DispatchQueue.main.async {
                    self.isConnected = false
                }
                
                return
            }
            
            DispatchQueue.main.async {
                self.isConnected = true
            }
        })
    }
    
    func connect() async {
        guard let url = URL(string: endpoint)
        else {
            return
        }
        
        socket = session.webSocketTask(with: url)
        socket?.resume()
        
        connectionStatus()
        
        await receive()
        
        socket?.sendPing { error in
            if error != nil {
                DispatchQueue.main.async {
                    self.isConnected = false
                }
            }
        }
    }
    
    /// See RFC6455 for close codes
    /// https://datatracker.ietf.org/doc/html/rfc6455#section-7.4.1
    func disconnect() async {
        socket?.cancel(with: .normalClosure, reason: "Normal application close".data(using: .utf8))
        
        connectionStatus()
    }
    
    func receive() async {
        socket?.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    if let message = try? JSONDecoder().decode(MessageModel.self, from: data) {
                        self.messages.append(message)
                    }
                    
                case .string(let string):
                    if let data = string.data(using: .utf8),
                        let message = try? JSONDecoder().decode(MessageModel.self, from: data) {
                        self.messages.append(message)
                    }
                    
                @unknown default:
                    break
                }
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    
    func send(message: String) async {
        guard !message.isEmpty
        else {
            return
        }
        
        socket?.send(.string(message)) { error in
            if let error = error {
                print(String(describing: error))
            }
        }
        
        await receive()
    }
    
    func sortedMessageList(of unsortedMessages: [MessageModel]) -> [MessageModel] {
        return unsortedMessages.sorted {
            return $0.timestamp > $1.timestamp
        }
    }
}
