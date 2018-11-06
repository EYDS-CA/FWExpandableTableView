# FWExpandableTableView

# Introduction
FW_ExpandableTableView is easier and less-coding to achieve UITableViewCell expandable and collapsable. Unlikely, it supports as much levels of UITableViewCell expanding as your data structured. You can fully customize FWExpandingTableViewCell as you need.


![fwexpandabletv_demo](https://user-images.githubusercontent.com/16994445/48033026-87dd0200-e10e-11e8-9725-58e1cca5ed9e.gif)
# Requirements
 - Swift 4.0+
 - iOS 8.0+ 
 - Xcode 8.0+
# Installation

**CocoaPods**

FW_ExpandableTableView is available  through CocoaPods. To install it, simply add the following line to your Podfile:
```pod
pod 'FW_ExpandableTableView'
```
and import the library in a page where you use 
```swift
import FW_ExpandableTableView
```

# Usage
**Storyboard**

![screen shot 2018-11-05 at 4 05 48 pm](https://user-images.githubusercontent.com/16994445/48034570-ce355f80-e114-11e8-9bda-1255203396b8.jpg)

![screen shot 2018-11-05 at 4 06 00 pm](https://user-images.githubusercontent.com/16994445/48034592-e2795c80-e114-11e8-85d6-64dd2eafba2d.jpg)


**Programmatically**

```swift
  lazy var fwTableView : FW_ExpandableTableView = {
        let tv = FW_ExpandableTableView()
        // Require
        tv.register(FWExpandableTVCell.self, forCellReuseIdentifier: String(describing: FWExpandableTVCell.self))
        // Options
        tv.backgroundColor = .white
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.showsHorizontalScrollIndicator = false
        tv.isScrollEnabled = true

        return tv
    }()
```

**Inject data to FW_ExpandableTableView**

- Assign [[String: Any]] type data to the FW_ExpandableTV by calling setUpDataSource().
- setUpDataSource() requires two parameters; first is data and second is a key to find a child node in dynamic tree.
```swift
func setUpDataForTableView(childKeyToFind: String) {
        APIManager.sharedInstance.fetchData { (result) in
            // Pass an array of a dictionary type data and a child key to find child node data in data structure.
            fwTableView.setUpDataSource(jsonArray: result, childKeyToFind: childKeyToFind)
            fwTableView.reloadData()
        }
    }
```
- Dynamic tree
```json
[
	{
		"name": "0-0",
		"children": [
			{
				"name": "0-0-0",
				"children": [
					{
						"name": "0-0-0-0",
						"children": [
							{
								"name": "0-0-0-0-0"
							},
							{
								"name": "0-0-0-0-1"
							},
						]	
					},
					{
						"name": "0-0-0-1"
					},
					{
						"name": "0-0-0-2"
					}
				]	
			}
		]
	}
]

```
- TableViewDelegate and TableViewDataSource are simple enough and customizable.  

```swift
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fwTableView.datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FWExpandableTVCell.self), for: indexPath) as? FWExpandableTVCell {
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
        if let cell = tableView.cellForRow(at: indexPath) as? FWExpandableTVCell, cell.isExpandable {
            // Expand or collapse children
            if cell.isExpanded {
                fwTableView.collapseChildren(cell: cell, indexPath: indexPath)
            } else {
                fwTableView.expandChildren(cell: cell, indexPath: indexPath)
            }
        }
    }
```



# Author
 [Gisu Kim](https://www.linkedin.com/in/gisu-kim-b162a0127/) (Author)
 
 [Tushar Agarwal](https://www.linkedin.com/in/tusharagarwal10/) (Special Thanks for Code Review)
 
 [Skyler Smith](https://www.linkedin.com/in/skyler-smith-670979103/) (Special Thanks for an idea in the logic)
# License
FW_ExpandableTableView is available under the MIT license. See the LICENSE file for more info.
