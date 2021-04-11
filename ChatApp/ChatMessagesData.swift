//
//  ChatMessageObservable.swift
//  ChatApp
//
//  Created by Ramesh kumar penta on 30/08/20.
//  Copyright © 2020 Ramesh kumar penta. All rights reserved.
//

import Foundation
final class ChatMessagesData : ObservableObject
{
    static let shared = ChatMessagesData()
    
    private init(){}
    
   @Published var listMessage : Array<Message>? = Array<Message>()
    
}


