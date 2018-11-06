//
//  UIButton+Ext.swift
//  FW_ExpandableTableView
//
//  Created by gisu kim on 2018-10-31.
//

import UIKit

extension UIButton {
    
    func rotateByAngle(requiresIdentityAngle isIdentity : Bool, requiresAnimation : Bool = true) {
        UIView.animate(withDuration: requiresAnimation ? 0.2 : 0.0) {
            self.transform = isIdentity ? .identity : CGAffineTransform(rotationAngle: .pi)
        }
    }

}
