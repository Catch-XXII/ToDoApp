//
//  Items.swift
//  ToDoApp
//
//  Created by Cüneyd on 24.06.2019.
//  Copyright © 2019 J8R. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    @objc dynamic var color: String = ""
    var parentCatogery = LinkingObjects(fromType: Category.self, property: "items")
}
