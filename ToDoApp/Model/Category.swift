//
//  Category.swift
//  ToDoApp
//
//  Created by Cüneyd on 24.06.2019.
//  Copyright © 2019 J8R. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
    
}
