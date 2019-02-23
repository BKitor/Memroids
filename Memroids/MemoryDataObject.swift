//
//  MemoryDataObject.swift
//  Memroids
//
//  Created by Paul Kitor on 2018-07-10.
//  Copyright © 2018 bkitor. All rights reserved.
//

import Foundation
import UIKit

class MemoryDataObject: NSObject, NSCoding{
    
    var title:String
    var subtitle:String? = nil
    var images:[UIImage?] = []
    var dateCreated:Date
    var reminderDate:Date? = nil
    
    override init(){
        self.title = ""
        self.dateCreated = Date()
        super.init()
    }
    
    init(_ name:String){
        self.title = name
        self.dateCreated = Date()
        super.init()
    }
    
    //Two functions required for NSCoding protocol
    required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.subtitle = aDecoder.decodeObject(forKey: "sub") as? String
        self.images = (aDecoder.decodeObject(forKey: "images") as? [UIImage])!
        self.dateCreated = aDecoder.decodeObject(forKey: "dateCreated") as! Date
        self.reminderDate = aDecoder.decodeObject(forKey: "reminderDate") as? Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.subtitle, forKey: "sub")
        aCoder.encode(self.images, forKey: "images")
        aCoder.encode(self.dateCreated, forKey: "dateCreated")
        aCoder.encode(self.reminderDate, forKey: "reminderDate")
    }
    
}
