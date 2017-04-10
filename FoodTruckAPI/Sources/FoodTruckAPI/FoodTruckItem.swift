//
//  FoodTruckItem.swift
//  FoodTruckAPI
//
//  Created by Alex Nguyen on 2017-04-10.
//
//

import Foundation

typealias JSONDictionary = [ String : Any ]

protocol DictionaryConvertible {
    func toDict() -> JSONDictionary
}

public struct FoodTruckItem {
    public let docId : String
    public let name: String
    public let foodType: String
    public let avgCost: Float
    public let latitude: Float
    public let longitude: Float
}

extension FoodTruckItem: Equatable {
    public static func == (lhs: FoodTruckItem, rhs: FoodTruckItem) -> Bool {
        return lhs.docId == rhs.docId &&
            lhs.name == rhs.name &&
            lhs.foodType == rhs.foodType &&
            lhs.avgCost == rhs.avgCost &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == lhs.longitude
    }
}

extension FoodTruckItem: DictionaryConvertible {
    func toDict() -> JSONDictionary {
        var result = JSONDictionary()
        result["id"] = docId
        result["name"] = name
        result["foodtype"] = foodType
        result["avgCost"] = avgCost
        result["latitude"] = latitude
        result["longitude"] = longitude
        return result
    }
}

extension Array where Element: DictionaryConvertible {
    func toDict()-> [JSONDictionary] {
        return self.map({ $0.toDict() })
    }
}
