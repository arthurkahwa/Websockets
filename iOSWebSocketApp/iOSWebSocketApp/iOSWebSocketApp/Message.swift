//
//  Message.swift
//  iOSWebSocketApp
//
//  Created by Arthur Nsereko Kahwa on 7/16/23.
//

import Foundation

struct MessageModel: Codable, Hashable {
  let id: String
  let timestamp: String
  let myMessage: String
  let yourMessage: String?
}
