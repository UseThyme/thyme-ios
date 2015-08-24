//
//  Screen.swift
//  Thyme
//
//  Created by Christoffer Winterkvist on 8/24/15.
//  Copyright (c) 2015 Hyper. All rights reserved.
//

import UIKit

struct Screen {

  static var isPhone: Bool = {
    return UIDevice.currentDevice().userInterfaceIdiom == .Phone
    }()

  static var isPad: Bool = {
    return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }()

}
