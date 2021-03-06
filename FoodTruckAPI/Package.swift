// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "FoodTruckAPI",
   targets: [
	Target(
           name: "FoodTruckServer",
	   dependencies: [ .Target(name: "FoodTruckAPI") ]
	),
	Target(
	   name: "FoodTruckAPI"
	)
   ],
   dependencies: [
	.Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 7),
	.Package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git", majorVersion: 1, minor: 7),
   ]
)
