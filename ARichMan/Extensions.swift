//
//  Extensions.swift
//  ARichMan
//
//  Created by 宋 奎熹 on 2017/9/11.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

extension Float {

    static func random(_ precision: Int) -> Float {
        let bigInt = (10 ^ precision)
        return Float(Int(arc4random()) % bigInt) / Float(bigInt)
    }

}

extension UIColor {

    @nonobjc class var myYellowColor: UIColor {
        return UIColor(red: 250.0 / 255.0, green: 207.0 / 255.0, blue: 93.0 / 255.0, alpha: 1.0)
    }

}
