//
//  ShoppingList.swift
//  Shopping List-383
//
//  Created by Jeremiah Steidinger on 5/5/18.
//  Copyright © 2018 Blue Diamond Developers. All rights reserved.
//

import Foundation

class ShoppingListItem: NSObject, NSCoding
{
    var item: String
    var checked: Bool
    
    public init(item: String)
    {
        self.item = item
        self.checked = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        if let item = aDecoder.decodeObject(forKey: "item") as? String
        {
            self.item = item
        }
        else
        {
            return nil
        }
        
        if aDecoder.containsValue(forKey: "checked")
        {
            self.checked = aDecoder.decodeBool(forKey: "checked")
        }
        else
        {
            return nil
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.item, forKey: "item")
        aCoder.encode(self.checked, forKey: "checked")
    }
}

extension Collection where Iterator.Element == ShoppingListItem
{
    private static func persistencePath() -> URL?
    {
        let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)
        
        return url?.appendingPathComponent("shoppingListItems.bin")
    }
    
    func writeToPersistence() throws
    {
        if let url = Self.persistencePath(), let array = self as? NSArray
        {
            let data = NSKeyedArchiver.archivedData(withRootObject: array)
            try data.write(to: url)
        }
        else
        {
            throw NSError(domain: "com.Steidinger.Shopping List-383", code: 10, userInfo: nil)
        }
    }
    
    static func readFromPersistence() throws -> [ShoppingListItem]
    {
        if let url = persistencePath(), let data = (try Data(contentsOf: url) as Data?)
        {
            if let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? [ShoppingListItem]
            {
                return array
            }
            else
            {
                throw NSError(domain: "com.Steidinger.Shopping List-383", code: 11, userInfo: nil)
            }
        }
        else
        {
            throw NSError(domain: "com.Steidinger.Shopping List-383", code: 12, userInfo: nil)
        }
    }
}
