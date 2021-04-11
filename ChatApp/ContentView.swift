//
//  ContentView.swift
//  ChatApp
//
//  Created by Ramesh kumar penta on 27/08/20.
//  Copyright © 2020 Ramesh kumar penta. All rights reserved.
//

import SwiftUI
import AWSAppSync
import Amplify

struct ContentView: View {
    @EnvironmentObject var chatMessageData : ChatMessagesData
    @State var appSyncCleint : AWSAppSyncClient?
    @State var subscriberWatcher : AWSAppSyncSubscriptionWatcher<OnCreateMessageSubscription>?


    init() {
        self.appSyncCleint = getAppsyncClent()
    }
    var body: some View {
        ScrollView(.vertical, showsIndicators: true)  {
            
        VStack(alignment: .leading, spacing: 20 )
            {
                ForEach(chatMessageData.listMessage! , id: \.id)
        { (message) in
            ChatMessageView(message: Message(id: message.id, name: message.name, message: message.message))
                }
                Spacer()
                
             sendMessageView()
//           // Button(action: {self.onRefresh()}, label: {Text("Refresh")
//            }).padding(.all,10)
        }.padding(20).onAppear(perform: {  self.onRefresh()})
        }
    }
     func onRefresh() {
        
        //fetchEventFromCache()
        subsribeToMutationEvent()
        
    }
     func  subsribeToMutationEvent()
    {
//        var subscriberWatcher : AWSAppSyncSubscriptionWatcher<OnCreateMessageSubscription>?
        let resultHandler = {   (_ result: GraphQLResult<OnCreateMessageSubscription.Data>?, _ transaction: ApolloStore.ReadWriteTransaction?, _ error: Error?) -> Void
            in
            print("deliveed to subscriber")
                            guard let result = result else
                            {
                             print("result nil")
                                return
                            }
                            guard let resultData = result.data else
                            {
                                print("data nil")
                                return
                            }
                        if let onCreateMessage = resultData.onCreateMessage  {
                                print("@Subscription " + onCreateMessage.name! + " " + onCreateMessage.message!)
                                if let name = onCreateMessage.name,
                                    let message  = onCreateMessage.message
                                {
                                    self.chatMessageData.listMessage?.append(Message(id: String(onCreateMessage.id), name: name, message: message))
                                }

                         }
                            else if let error = error {
                                print(error.localizedDescription)
                            }
                }




        do
        {
            self.subscriberWatcher = try self.appSyncCleint?.subscribe(subscription: OnCreateMessageSubscription(), resultHandler: resultHandler)

        }
        catch {
                       print("Error starting subscription: \(error.localizedDescription)")

        }
        print("@Subscription ")
        print(subscriberWatcher.debugDescription)
       
        // In your app code
//        do {
//            self.subscriberWatcher = try appSyncClient?.subscribe(subscription: OnCreateMessageSubscription()) { [weak self] result, transaction, error in
//
//                guard let result = result else
//                {
//                 print("result nilt")
//                    return
//                }
//                guard let resultData = result.data else
//                {
//                    print("data nil")
//                    return
//                }
//            if let onCreateMessage = resultData.onCreateMessage  {
//                    print("@Subscription " + onCreateMessage.name! + " " + onCreateMessage.message!)
//                    if let name = onCreateMessage.name,
//                        let message  = onCreateMessage.message
//                    {
//                        self!.chatMessageData.listMessage?.append(Message(id: String(onCreateMessage.id), name: name, message: message))
//                    }
//
//             }
//                else if let error = error {
//                    print(error.localizedDescription)
//                }
//            }
//
//        } catch {
//            print("Error starting subscription: \(error.localizedDescription)")
//        }

    print(subscriberWatcher.debugDescription)
    }
    }

struct sendMessageView : View {
  @State  var newMessage  = "Enter message"

    var body: some View
    {
        
        VStack{
            
        HStack(alignment: .firstTextBaseline, spacing: 10.0)
        {
            
            TextField("message", text: $newMessage).padding(.all, 10.0)
            
            Spacer()
            Button(action: {self.onSend()}, label: {Text("send")
            }).padding(.all,10)
        }.padding(.all)
            
        }
        
        
    }
    
    func onSend() -> Void
    {
        let identifier = GraphQLID().randomElement()
                
        let mutationInput = CreateMessageInput( name: Amplify.Auth.getCurrentUser()?.username, message :$newMessage.wrappedValue)
        print($newMessage.wrappedValue)
        
        getAppsyncClent()!.perform(mutation: CreateMessageMutation(input: mutationInput)) { (result, error) in
            
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
                return
            }
                
                if let error = error as? AWSAppSyncClientError {
                    print("Error occurred: \(error.localizedDescription )")
                }
            else
            {
                print(result?.data?.snapshot["createMessage"] as? String ?? "no message")
                guard let name = result?.data?.createMessage?.name else { return }
                                guard let message = result?.data?.createMessage?.message else { return }
                                guard let id = result?.data?.createMessage?.id else { return }
                                
                                ChatMessagesData.shared.listMessage?.append(Message(id: id, name: name, message: message))            }
            
                
            
        }

        
    }

    
    
    func fetchEventFromCache() {
        doFetchWithCachePolicy(.returnCacheDataDontFetch)
    }
    
    func doFetchWithCachePolicy(_ cachePolicy: CachePolicy)
    {    var msgList = Array<Message>()


        //Run a query
        getAppsyncClent()?.fetch(query: ListMessagesQuery(), cachePolicy: cachePolicy)  { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            result?.data?.listMessages?.items!.forEach { print(($0?.name)! + " " + ($0?.message)!)
                if let name = $0?.name,
                    let id   = $0?.id ,
                    let message  = $0?.message
                {
                   msgList.append( Message(id: id, name: name, message: message))
                }
                else
                {
                   
                }
                
              }
            ChatMessagesData.shared.listMessage? = msgList
            
                 
        }
    }
   
}

    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
