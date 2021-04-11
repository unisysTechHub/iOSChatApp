//
//  SignIn.swift
//  ChatApp
//
//  Created by Ramesh kumar penta on 22/10/20.
//  Copyright © 2020 Ramesh kumar penta. All rights reserved.
//

import SwiftUI
import Combine
import Amplify

struct SignIn: View {
    var body: some View {
        NavigationView {
            Button(action: { signInWithWebUI()}) {
                Text("SignIn")
            }
        }.navigationTitle(Text("ChatApp")).navigationBarItems(leading: Text("Test"), trailing: Text("test"))
    }
    
    func signInWithWebUI() -> AnyCancellable {
        Amplify.Auth.signInWithWebUI(presentationAnchor: ( UIApplication.shared.delegate as! AppDelegate).window!)
            .resultPublisher
            .sink {
                if case let .failure(authError) = $0 {
                    print("Sign in failed \(authError)")
                }
            }
            receiveValue: { signResult in
                print("Sign in succeeded")
                
            }
    }

}
struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        SignIn()
    }
}
