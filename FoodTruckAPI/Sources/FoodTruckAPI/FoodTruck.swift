//
//  FoodTruck.swift
//  FoodTruckAPI
//
//  Created by Alex Nguyen on 2017-04-10.
//
//

import Foundation
import SwiftyJSON
import LoggerAPI
import CouchDB

// Preprocessor
#if os(Linux)
    typealias ValueType = Any
#else
    typealias ValueType = AnyObject
#endif

public enum APICollectionError: Error {
    case ParseError
    case AuthError
}

public class FoodTruck: FoodTruckAPI {
    // MARK : Connection Properties
    let dbName = "foodtruckapi"
    let designName = "foodtruckdesign"
    let connectionProps: ConnectionProperties
    
    // MARK : Initalizers
    public init() {
        connectionProps = ConnectionProperties(host: "localhost", port: Int16(5984), secured: false, username: "alex", password: "123456")
        Log.info("Connected to localhost")
    }
    
    // MARK : Private helpers
    private func setupDb() {
    
    }
}
