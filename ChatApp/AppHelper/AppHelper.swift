//
//  AppHelper.swift
//  ChatApp
//
//  Created by Ramesh kumar penta on 30/08/20.
//  Copyright © 2020 Ramesh kumar penta. All rights reserved.
//

import Foundation
import UIKit
import AWSAppSync

func getAppsyncClent() -> AWSAppSyncClient?
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
   return appDelegate.appSyncClient
}


    

