//
//  ContentView.swift
//  iOSWebSocketApp
//
//  Created by Arthur Nsereko Kahwa on 7/16/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var message = ""
    
    var body: some View {
        VStack {
            VStack {
                if viewModel.isConnected {
                    TextField(text: $message) {
                        Text("Your Werbung Here!")
                    }
                    
                    Button {
                        Task {
                            await viewModel.send(message: message)
                            
                            message = ""
                        }
                    } label: {
                        Text("Send")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .scaleEffect(1.0)
                    .animation(.easeIn, value: 1.0)
                }
                else {
                    Text("Not Connected.")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
            .scaleEffect(1.0)
            .animation(.easeIn, value: 1.0)
            .padding()
            
            Spacer()
            
            List(viewModel.sortedMessageList(of: viewModel.messages), id: \.self) { message in
                Text(message.myMessage)
                    .font(.title3)
                
            }
            .scaleEffect(1.0)
            .animation(.easeIn, value: 1.0)
            
            Spacer()
            
            Button {
                if viewModel.isConnected {
                    Task {
                        await viewModel.disconnect()
                    }
                }
                else {
                    Task {
                        await viewModel.connect()
                    }
                }
            } label: {
                Text(viewModel.isConnected ? "Disconnect" : "Connect")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .scaleEffect(1.0)
            .animation(.easeIn, value: 1.0)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
