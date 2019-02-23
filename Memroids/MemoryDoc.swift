//
//  MemoryDocument.swift
//  Memroids
//
//  Created by Paul Kitor on 2018-07-16.
//  Copyright © 2018 bkitor. All rights reserved.
//

import UIKit

class MemoryDoc: UIDocument {
    var memories = [MemoryDataObject]()
    
    //load() and contents() functions to save and retriv ememories array as data
    override func load(fromContents contents: Any, ofType typeName: String?) throws{
        print("load got called")
        guard let data:Data = contents as? Data else {
            print("Couldn't get data from contents")
            return
        }
        guard let arr:[MemoryDataObject] = NSKeyedUnarchiver.unarchiveObject(with:data) as? [MemoryDataObject] else {
                print("NSkey archiver didn't work")
                return
            }
        self.memories = arr
    }
    
    override func contents(forType typeName: String) throws -> Any {
        print("Contents got called")
        let data = NSKeyedArchiver.archivedData(withRootObject: self.memories)
        return data
    }
}

