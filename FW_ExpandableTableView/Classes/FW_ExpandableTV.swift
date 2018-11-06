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

public class FW_ExpandableTableView: UITableView {
    
    @objc
    private lazy dynamic var parent = Node(id: "0")
    
    public lazy var datasource = [Node]()
    
    private lazy var uniqueChildKey : String = ""
    
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
    public func expandChildren(cell: FWExpandableTVCell, indexPath: IndexPath) {
        self.parent.children[indexPath.row].isExpanded = true
        let node = self.parent.children[indexPath.row]
        var updatingIndexPathGroup = [IndexPath]()
        DispatchQueue.main.async {
            if let count = node.children?.count, var childNodes = node.children  {
                for i in 0..<count {
                    // Refresh a expanding boolean to original.
                    self.refreshExpandingFlag(childNodes[i])
                    // Start from the next row of a selected row
                    self.parent.children.insert(childNodes[i], at: indexPath.row + (i+1))
                    let newIndexPath = IndexPath(row: indexPath.row + (i+1), section: 0)
                    updatingIndexPathGroup.append(newIndexPath)
                }
                DispatchQueue.main.async {
                    self.insertRows(at: updatingIndexPathGroup, with: .fade)
                    self.updateCellTapped(cell, indexPath: indexPath)
                }
            }
        }
    }
    
    // Estimate a number of children to be deleted and delete these from the array to be displayed.
    public func collapseChildren(cell: FWExpandableTVCell, indexPath: IndexPath) {
        var deletingIndexPathGroup = [IndexPath]()
        let childCount = countAllChildrenOfNodeToBeDeleted(self.parent.children[indexPath.row], indexPath: indexPath)
        DispatchQueue.main.async {
            for i in 0..<childCount {
                // Delete the next line of a selected cell
                self.parent.children.remove(at: indexPath.row + 1)
                // Remove from the next row of a selected row
                let deletingIndexPath = IndexPath(row: indexPath.row + (1+i), section: 0)
                deletingIndexPathGroup.append(deletingIndexPath)
            }
            DispatchQueue.main.async {
                // Refresh a expanding flag of a node associated with a selected cell.
                self.refreshExpandingFlag(self.parent.children[indexPath.row])
                // Delete rows and update a selected cell
                self.deleteRows(at: deletingIndexPathGroup, with: .fade)
                self.updateCellTapped(cell, indexPath: indexPath)
            }
        }
    }
    
    // Useful methods //
    
    
    // Returns the cell at the ExpandableIndexPath given.
    public func cellForRowAtIndexPath(indexPath: IndexPath) -> UITableViewCell? {
        if let cell = self.cellForRow(at: indexPath) as? FWExpandableTVCell {
            return cell
        }
        
        return UITableViewCell()
    }

    // Methods to support
    
    func refreshExpandingFlag(_ node: Node) {
        node.isExpanded = false
    }
    
    func countAllChildrenOfNodeToBeDeleted(_ node: Node, indexPath: IndexPath) -> Int {
        var count = 0
        for i in indexPath.row+1..<self.parent.children.count {
            let index = node.id.index(node.id.startIndex, offsetBy: node.id.count)
            // Children' id must contains of a parent's id as a portion of their id (parent:0-0, child:0-0-0)
            if self.parent.children[i].id.contains(node.id) &&
                node.id.count < self.parent.children[i].id.count &&
                node.id == self.parent.children[i].id[self.parent.children[i].id.startIndex..<index] {
                count += 1
            }
        }
        return count
    }
    
    // Animate to rotate downArrow button and update cell's a flag whether it is expanded
    func updateCellTapped(_ cell: FWExpandableTVCell, indexPath: IndexPath) {
        // Rotating Animation
        cell.expandingBtn.animateRotation(isExpanded: self.parent.children[indexPath.row].isExpanded, with: true)
        // Switch boolean to opposite
        cell.isExpanded = self.parent.children[indexPath.row].isExpanded ? true : false
    }
}
