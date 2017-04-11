public protocol FoodTruckAPI {
    
    // MARK : Getters
    func getAllTrucks(completion: @escaping ([FoodTruckItem]?, Error?) -> Void)
    
    func getTruck(docId: String, completion: @escaping ([FoodTruckItem]?, Error?) -> Void)
    
    // MARK : Actions
    func addTruck(name: String, foodType: String, avgCost: Float, latitude: Float, longitude: Float, completion: @escaping ([FoodTruckItem]?, Error?) -> Void)
    
    func deleteTruck(docId: String, completion: @escaping (Error?) -> Void)
    
    func clearAll(completion: @escaping (Error?) -> Void)
}
