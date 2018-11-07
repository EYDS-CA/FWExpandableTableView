//
//  FW_ExpandableTV.swift
//  FW_ExpandableTableView
//
//  Created by gisu kim on 2018-10-31.
//

import Foundation
import UIKit

@objc
public class Node : NSObject {
    // An identifier.
    public let id : String!
    
    // Child nodes belonging to.
    @objc
    public dynamic var children: [Node]!
    
    // A boolean whether a cell associated with the node is expanded.
    public var isExpanded: Bool!
    // A Storage of whatever data is desired.
    public var object: [String: Any]?
    
    init(id: String) {
        self.id = id
        self.isExpanded = false
        self.children = [Node]()
    }
}

public class FW_ExpandableTV: UITableView {
    // A placeholder where all data is stored.
    @objc
    private lazy dynamic var parent = Node(id: "0")
    // Datasource available from users.
    public lazy var datasource = [Node]()
    // A key to find a child nodes in dynamic tree.
    private lazy var uniqueChildKey : String = ""
    
    // Keeping track on changes on the parent property and delivering a update to datasource.
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(parent.children) { self.datasource = parent.children }
    }
    
    // Iterate through an array of a dictionary and define data to be used for FWExpandableTV.
    public func setUpDataSource(jsonArray: [[String: Any]], childKeyToFind: String) {
        addObserver(self, forKeyPath: #keyPath(parent.children), options: [.old, .new], context: nil)
        self.uniqueChildKey = childKeyToFind
        
        func createChildren(withParent node : Node? = nil, jsonArray : [[String : Any]], isParentIteration : Bool) {
            for i in 0..<jsonArray.count {
                let child = Node(id: "\(node?.id != nil ? (node?.id)! : "0")-\(i)")
                child.object = jsonArray[i]
                node?.children.append(child)
                if let children = jsonArray[i][self.uniqueChildKey] as? [[String: Any]], children.count > 0 {
                    createChildren(withParent: child, jsonArray: children, isParentIteration: false)
                }
                isParentIteration ? self.parent.children.append(child) : ()
            }
        }

        createChildren(jsonArray: jsonArray, isParentIteration: true)
    }
    
    // Estimate a number of children to be added and add these to the array to be displayed.
    private func expandChildren(cell: FW_ExpandableTVCell, indexPath: IndexPath) {
        let node = self.parent.children[indexPath.row]
        if node.isExpanded == false {
            // Update a isExpanded flag.
            node.isExpanded = true
            var insertingIndexPathGroup = [IndexPath]()
            if let childNode = node.children {
                for i in 0..<childNode.count {
                    let subchildNode = childNode[i]
                    // Refresh a expanding boolean to original.
                    subchildNode.isExpanded = false
                    // Add from the next row of a selected row.
                    let newIndexPath = IndexPath(row: indexPath.row + (i+1), section: 0)
                    self.parent.children.insert(subchildNode, at: newIndexPath.row)
                    insertingIndexPathGroup.append(newIndexPath)
                }
                DispatchQueue.main.async {
                    self.insertRows(at: insertingIndexPathGroup, with: .fade)
                    self.updateCellTapped(cell, indexPath: indexPath)
                }
            }
        }
    }
    
    // Estimate a number of children to be deleted and delete these from the array to be displayed.
    private func collapseChildren(cell: FW_ExpandableTVCell, indexPath: IndexPath) {
        let node = self.parent.children[indexPath.row]
        if node.isExpanded {
            // Update a isExpanded flag.
            node.isExpanded = false
            var deletingIndexPathGroup = [IndexPath]()
            for i in 0..<numberOfChildrenRows(forNode: self.parent.children[indexPath.row], shallCountItself: false) {
                // Delete the next line of a selected cell.
                self.parent.children.remove(at: indexPath.row + 1)
                // Remove from the next row of a selected row.
                let deletingIndexPath = IndexPath(row: indexPath.row + (i+1), section: 0)
                deletingIndexPathGroup.append(deletingIndexPath)
            }
            DispatchQueue.main.async {
                // Delete rows and update the selected cell.
                self.deleteRows(at: deletingIndexPathGroup, with: .fade)
                self.updateCellTapped(cell, indexPath: indexPath)
            }
        }
    }
    
    // Loop through a node associated with a cell tapped on and count all chilren are current in the table.
    private func numberOfChildrenRows(forNode node : Node, shallCountItself countItself : Bool) -> Int {
        var count = countItself ? 1 : 0
        node.children.forEach { (child) in
            count += child.isExpanded ? self.numberOfChildrenRows(forNode: child, shallCountItself: true) : 1
        }
        return count
    }
    
    // Animate to rotate downArrow button and update cell's a flag whether it is expanded.
    private func updateCellTapped(_ cell: FW_ExpandableTVCell, indexPath: IndexPath) {
        // Rotating Animation
        cell.expandingBtn.rotateByAngle(requiresIdentityAngle: !self.parent.children[indexPath.row].isExpanded)
        // Switch boolean to opposite
        cell.isExpanded = self.parent.children[indexPath.row].isExpanded
    }
    
    // Returns the cell at the ExpandableIndexPath given.
    public func cellForRowAtIndexPath(indexPath: IndexPath) -> FW_ExpandableTVCell? {
        return self.cellForRow(at: indexPath) as? FW_ExpandableTVCell
    }
    
    // Update the tableViewCell depend on a boolean property in a cell selected.
    public func updateCell(_ cell : FW_ExpandableTVCell, atIndexPath indexPath : IndexPath, shouldCollapse collapse : Bool) {
        collapse ? self.collapseChildren(cell: cell, indexPath: indexPath) :  self.expandChildren(cell: cell, indexPath: indexPath)
    }
}
