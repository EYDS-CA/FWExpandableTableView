//
//  ViewController.swift
//  FW_ExpandableTableView
//
//  Created by sksmszhdzk@gmail.com on 10/31/2018.
//  Copyright (c) 2018 sksmszhdzk@gmail.com. All rights reserved.
//

import UIKit
import FW_ExpandableTableView

class ViewController: UIViewController {    
    @IBOutlet weak var fwTableView: FW_ExpandableTV!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUpTableView()
        setUpDataForTableView(childKeyToFind: "children")
    }
    
    private func parseJSONFromLocalStorage(completion: @escaping ([[String : Any]]) -> ()) {
        if let path = Bundle.main.path(forResource: "FWExpandable_example", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                guard let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [[String : Any]] else { return }
                completion(jsonResult)
            } catch {
                // handle error
            }
        }
    }
    
    func setUpDataForTableView(childKeyToFind: String) {
        parseJSONFromLocalStorage { (result) in
            // Pass an array of a dictionary type data and a child key to find child node data in data structure.
            self.fwTableView.setUpDataSource(jsonArray: result, childKeyToFind: "children")
            self.fwTableView.reloadData()
        }
    }
    
    func setUpTableView() {
        // Require
        fwTableView.register(FW_ExpandableTVCell.self, forCellReuseIdentifier: String(describing: FW_ExpandableTVCell.self))
        // Options
        fwTableView.backgroundColor = .white
        fwTableView.separatorStyle = .none
        fwTableView.showsVerticalScrollIndicator = false
        fwTableView.showsHorizontalScrollIndicator = false
        fwTableView.isScrollEnabled = true
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fwTableView.datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FW_ExpandableTVCell.self), for: indexPath) as? FW_ExpandableTVCell {
            cell.configureWithChild(fwTableView.datasource[indexPath.row])
            // Customzie FWExpandableTVCell here.
            // cell.titleLabel.text = yourData
            // Or
            // cell.customizableView = yourCustomView
            
            // optional methods
            
            // cell.removeLeftSideInset()
            // cell.removeDefaultViewSetting()
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? FW_ExpandableTVCell, cell.isExpandable {
            fwTableView.updateCell(cell, atIndexPath: indexPath, shouldCollapse: cell.isExpanded)
        }
    }
}


