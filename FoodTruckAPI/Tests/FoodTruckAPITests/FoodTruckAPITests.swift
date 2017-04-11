import XCTest
@testable import FoodTruckAPI

class FoodTruckAPITests: XCTestCase {

    static var allTests = [
        ("testAddTruck", testAddAndGetTruck),
    ]
    
    var trucks: FoodTruck?
    
    override func setUp() {
        trucks = FoodTruck()
        super.setUp()
    }
    
    // Add and Get a specific truck
    func testAddAndGetTruck() {
        guard let trucks = trucks else {
            XCTFail()
            return
        }
        
        let addExpectation = expectation(description: "Add a truck item")
        
        // 1. Add a new truck (fictious truck)
        trucks.addTruck(name: "testAdd", foodType: "testType", avgCost: 0, latitude: 0, longitude: 0) { (addedTruck, err) in
            // 2. Check for errors
            guard err == nil else {
                print(err.debugDescription)
                XCTFail()
                return
            }
            // 3. Assert that the added truck equals the returned truck
            if let addedTruck = addedTruck {
                trucks.getTruck(docId: addedTruck.docId, completion: { (returnedTruck, err) in
                    XCTAssertEqual(addedTruck, returnedTruck)
                    addExpectation.fulfill()
                })
            }
        }
        // 4. Wait for expectation, wait 5 seconds.
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertNil(error, "addTruck timeout")
        }
    }
}
