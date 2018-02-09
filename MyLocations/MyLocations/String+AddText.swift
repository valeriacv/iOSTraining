//
//  String+AddText.swift
//  MyLocations
//
//  Created by Vale Calderon  on 4/17/17.
//  Copyright © 2017 Vale Calderon . All rights reserved.
//

extension String {
    
    mutating func add(text: String?, separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text }
    }

}
