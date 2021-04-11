//
//  Message.swift
//  ChatApp
//
//  Created by Ramesh kumar penta on 30/08/20.
//  Copyright © 2020 Ramesh kumar penta. All rights reserved.
//

import Foundation


struct Message : Codable,Hashable {
    var id : String
    var name : String
    var message : String
}
