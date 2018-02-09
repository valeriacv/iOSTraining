//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Vale Calderon  on 3/28/17.
//  Copyright © 2017 Vale Calderon . All rights reserved.
//

import Foundation

class ChecklistItem: NSObject, NSCoding{
    var text = ""
    var checked = false
    
    required init?(coder aDecoder: NSCoder) {
        text = aDecoder.decodeObject(forKey: "Text") as! String
        checked = aDecoder.decodeBool(forKey: "Checked")
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    func toggleChecked() {
        checked = !checked
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: "Text")
        aCoder.encode(checked, forKey: "Checked")
    }
}
