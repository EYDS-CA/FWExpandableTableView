//
//  UIButton+Ext.swift
//  FW_ExpandableTableView
//
//  Created by gisu kim on 2018-10-31.
//

import UIKit

extension UIButton {
    func animateRotation(isExpanded: Bool, with animation: Bool) {
        if animation {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.transform = isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
            }, completion: nil)
        } else {
            self.transform = isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
        }
    }
}

