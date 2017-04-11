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

public class FoodTruck {
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
    fileprivate func parseTrucks(_ document: JSON) throws -> [FoodTruckItem] {
        guard let rows = document["rows"].array else { throw APICollectionError.ParseError }
        
        let trucks: [FoodTruckItem] = rows.flatMap {
            let doc = $0["value"]
            guard let id = doc[0].string,
                let name = doc[1].string,
                let foodType = doc[2].string,
                let avgCost = doc[3].float,
                let latitude = doc[4].float,
                let longitude = doc[5].float else { return nil }
            return FoodTruckItem(docId: id, name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude)
        }
        return trucks
    }
    
    fileprivate func setupDbDesign(db: Database) {
        let design: [String: Any] = [
            "_id": "_design/foodtruckdesign",
            "views": [
                "all_documents": [
                    "map": "function(doc) { emit(doc.id, [doc._id, doc._rev]); }"
                ],
                "all_trucks": [
                    "map": "function(doc) { if (doc.type == 'foodtruck') { emit(doc._id, [doc._id, doc.name, doc.foodtype, doc.avgcost, doc.latitude, doc.longitude]);}}"
                ],
                "total_trucks": [
                    "map": "function(doc) { if (doc.type == 'foodtruck') { emit(doc.id, 1); }}",
                    "reduce": "_count"
                ]
            ]
        ]
        
        db.createDesign(designName, document: JSON(design)) { (json, error) in
            if error != nil {
                Log.error("Failed to create design")
            } else {
                Log.info("Design created: \(json!)")
            }
        }
    }
    
    fileprivate func setupDb() {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        couchClient.dbExists(dbName) { (exists, error) in
            if exists {
                Log.info("DB Exists")
            } else {
                Log.error("DB does not exist \(String(describing: error))")
                couchClient.createDB(self.dbName, callback: { (database, error) in
                    if let database = database {
                        Log.info("DB Created")
                        self.setupDbDesign(db: database)
                    } else {
                        Log.error("Unable to create DB \(self.dbName): Error \(String(describing: error))")
                    }
                })
            }
        }
    }
    
    fileprivate func getIDAndRev(_ document: JSON) throws -> [(String, String)] {
        guard let rows = document["rows"].array else {
            throw APICollectionError.ParseError
        }
        return rows.flatMap {
            let doc = $0["doc"]
            let id = doc["_id"].stringValue
            let rev = doc["_rev"].stringValue
            return (id, rev)
        }
    }
}

extension FoodTruck: FoodTruckAPI {
    public func getAllTrucks(completion: @escaping ([FoodTruckItem]?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        database.queryByView("all_trucks", ofDesign: designName, usingParameters: [.descending(true), .includeDocs(true)]) { (doc, error) in
            if let doc = doc, error == nil {
                do{
                    let trucks = try self.parseTrucks(doc)
                    completion(trucks, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    public func getTruck(docId: String, completion: @escaping (FoodTruckItem?, Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        database.retrieve(docId) { (doc, error) in
            guard let doc = doc,
                let docId = doc["id"].string,
                let name = doc["name"].string,
                let foodType = doc["foodtype"].string,
                let avgCost = doc["avgcost"].float,
                let latitude = doc["latitude"].float,
                let longitude = doc["longitude"].float else {
                    completion(nil, error)
                    return
            }
            let truckItem = FoodTruckItem(docId: docId, name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude)
            completion(truckItem, nil)
        }
    }
    
    public func addTruck(name: String, foodType: String, avgCost: Float, latitude: Float, longitude: Float, completion: @escaping (FoodTruckItem?, Error?) -> Void) {
        let json: [String: Any] = [
            "type": "foodtruck",
            "name": name,
            "foodtype": foodType,
            "avgcost": avgCost,
            "latitude": latitude,
            "longitude": longitude
        ]
        
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        database.create(JSON(json)) { (id, rev, doc, error) in
            if let id = id {
                let truckItem = FoodTruckItem(docId: id, name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude)
                completion(truckItem, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    public func deleteTruck(docId: String, completion: @escaping (Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        database.retrieve(docId) { (doc, err) in
            guard let doc = doc, err == nil else {
                completion(err)
                return
            }
            
            // TODO : Fetch all reviews for the truck and delete them
            let rev = doc["_rev"].stringValue
            database.delete(docId, rev: rev, callback: { (error) in
                if err != nil {
                    completion(err)
                } else {
                    completion(nil)
                }
            })
            
        }
    }
    
    public func clearAll(completion: @escaping (Error?) -> Void) {
        let couchClient = CouchDBClient(connectionProperties: connectionProps)
        let database = couchClient.database(dbName)
        
        database.queryByView("all_documents", ofDesign: "foodtruckdesign", usingParameters: [.descending(true), .includeDocs(true)]) { (doc, error) in
            guard let doc = doc else {
                completion(error)
                return
            }
            guard let idAndRev = try? self.getIDAndRev(doc) else {
                completion(error)
                return
            }
            
            if idAndRev.count == 0 {
                completion(nil)
            } else {
                for i in 0..<idAndRev.count {
                    let truck = idAndRev[i]
                    database.delete(truck.0, rev: truck.1, callback: { (error) in
                        guard error == nil else {
                            completion(error)
                            return
                        }
                        completion(nil)
                    })
                }
            }
        }
    }
}
