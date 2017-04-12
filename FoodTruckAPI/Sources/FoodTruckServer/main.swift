import Foundation
import Kitura
import HeliumLogger
import LoggerAPI
import FoodTruckAPI

HeliumLogger.use() // Setup Helium Logger

let trucks: FoodTruck

trucks = FoodTruck()

let controller = FoodTruckController(backend: trucks)

#if os(Linux)
    let myCertPath = "/creds/Self-Signed/cert.pem"
    let myKeyPath = "/creds/Self-Signed/key.pem"
    
    let mySSLConfig =  SSLConfig(withCACertificateDirectory: nil, usingCertificateFile: myCertPath, withKeyFile: myKeyPath, usingSelfSignedCerts: true)
    mySSLConfig.cipherSuite = "ALL"
    Kitura.addHTTPServer(onPort: 8080, with: controller.router, withSSL: mySSLConfig)
#else
    let port = Int(8080)
    Log.verbose("Assigned port \(port)")
    Kitura.addHTTPServer(onPort: port, with: controller.router)
    Kitura.run()
#endif
