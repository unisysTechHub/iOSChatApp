//
//  ChatMessageView.swift
//  ChatApp
//
//  Created by Ramesh kumar penta on 30/08/20.
//  Copyright © 2020 Ramesh kumar penta. All rights reserved.
//

import SwiftUI

struct ChatMessageView: View {
    var message : Message
    var body: some View {
        VStack(alignment: .leading)
            {
                HStack{
                  Text("Name : ")
                    Text(message.name).bold().foregroundColor(.blue)
                }
                
                HStack(alignment: .bottom,spacing: 10){
                  Text("Message: ")
                 Text(message.message)
                }
        }
    }
}

struct ChatMessageView_Previews: PreviewProvider {
    static var previews: some View {
        ChatMessageView(message: Message(id: "id",name: "Default name", message: "Default message"))
    }
}
