//
//  FoodTruckController.swift
//  FoodTruckAPI
//
//  Created by Alex Nguyen on 2017-04-10.
//
//

import Foundation
import Kitura
import LoggerAPI
import SwiftyJSON

public final class FoodTruckController {
    public let trucks: FoodTruckAPI
    public let router = Router()
    public let trucksPath = "/api/v1/trucks"
    
    public init(backend: FoodTruckAPI) {
        trucks = backend
    }
    
    public func routeSetup() {
        router.all("/*", middleware: BodyParser())
    }
}
