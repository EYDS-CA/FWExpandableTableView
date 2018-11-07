//
//  FW_ExpandableTVCell.swift
//  FW_ExpandableTableView
//
//  Created by gisu kim on 2018-10-31.
//

import UIKit
import Foundation

public class PaddingLabel: UILabel {
    override public func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 12, dy: 0))
    }
}

public class FW_ExpandableTVCell: UITableViewCell {
    
    // Show if the cell is expanded or not
    public internal(set) var isExpanded : Bool = false
    // Show if the cell is expandable or not
    public var isExpandable : Bool  = false
    // Default colors of each level for the first 10 levels.
    public var colorsForEachLevel = [#colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1), #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1), #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)]
    
    public let customizableView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public let titleLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.backgroundColor = .clear
        return label
    }()
    
    // Get an image asset from pod library bundle
    private let podsBundle : Bundle = {
        let bundle = Bundle(for: FW_ExpandableTVCell.self)
        return Bundle(url: bundle.url(forResource: "FW_ExpandableTVCell",
                                      withExtension: "bundle")!)!
    }()
    
    private func imageFor(name imageName: String) -> UIImage {
        return UIImage(named: imageName, in: podsBundle, compatibleWith: nil)!
    }
    
    public var downArrowImage: UIImage {
        return imageFor(name: "downArrow")
    }
    
    public lazy var expandingBtn: UIButton = {
        let button = UIButton()
        button.setImage(self.downArrowImage, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        button.isHidden = true
        
        return button
    }()
    
    var customizableViewLeftAnchor: NSLayoutConstraint?
    var customizableViewWidthAnchorAnchor: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        selectionStyle = .none
        
        addSubview(customizableView)
        customizableView.addSubview(expandingBtn)
        customizableView.addSubview(titleLabel)
        
        if #available(iOS 9.0, *) {
            customizableView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            customizableView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            customizableViewWidthAnchorAnchor = customizableView.widthAnchor.constraint(equalTo: widthAnchor)
            customizableViewWidthAnchorAnchor?.isActive = true
            customizableViewLeftAnchor = customizableView.leftAnchor.constraint(equalTo: leftAnchor)
            customizableViewLeftAnchor?.isActive = true
            
            expandingBtn.centerYAnchor.constraint(equalTo: customizableView.centerYAnchor).isActive = true
            expandingBtn.rightAnchor.constraint(equalTo: customizableView.rightAnchor, constant: -16).isActive = true
            expandingBtn.widthAnchor.constraint(equalToConstant: 36).isActive = true
            expandingBtn.heightAnchor.constraint(equalToConstant: 36).isActive = true
            
            titleLabel.centerYAnchor.constraint(equalTo: customizableView.centerYAnchor).isActive = true
            titleLabel.rightAnchor.constraint(equalTo: customizableView.rightAnchor).isActive = true
            titleLabel.heightAnchor.constraint(equalTo: customizableView.heightAnchor).isActive = true
            titleLabel.leftAnchor.constraint(equalTo: customizableView.leftAnchor, constant: 8).isActive = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    public func configureWithChild(_ node: Node, color: UIColor?=nil) {
        let level = node.id.split(separator: "-").count - 2
        
        // Assign child's data
        titleLabel.text = node.id
        isExpanded = node.isExpanded
        isExpandable = !node.children.isEmpty ? true : false
        expandingBtn.isHidden = !node.children.isEmpty ? false : true
        expandingBtn.rotateByAngle(requiresIdentityAngle: !node.isExpanded, requiresAnimation: false)
        if let color = color {
            customizableView.backgroundColor = color
        } else {
            customizableView.backgroundColor = level >= colorsForEachLevel.count ? colorsForEachLevel[0] : colorsForEachLevel[level]
        }
        // Calculate a left inset for each level
        if let count = node.id?.split(separator: "-").count {
            customizableViewLeftAnchor?.constant = CGFloat(count-2) * 10
            customizableViewWidthAnchorAnchor?.constant = -(CGFloat(count-2) * 10)
        }
    }
    
    // Optional methods
    
    public func removeLeftSideInset() {
        customizableViewLeftAnchor?.constant = 0
        customizableViewWidthAnchorAnchor?.constant = 0
        self.layoutIfNeeded()
    }
    
    public func removeDefaultViewSetting() {
        titleLabel.removeFromSuperview()
        expandingBtn.removeFromSuperview()
        self.layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

