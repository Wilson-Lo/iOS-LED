//
//  UIColor.swift
//  LED
//
//  Created by GoMax on 2021/2/22.
//  Copyright © 2021 gomax. All rights reserved.
//

import UIKit

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}
