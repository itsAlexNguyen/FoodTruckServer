import Foundation
import Kitura
import HeliumLogger
import LoggerAPI
import FoodTruckAPI

HeliumLogger.use() // Setup Helium Logger

let trucks: FoodTruck

trucks = FoodTruck()

let controller = FoodTruckController(backend: trucks)

let port = Int(5984)
Log.verbose("Assigned port \(port)")
Kitura.addHTTPServer(onPort: port, with: controller.router)
Kitura.run()
