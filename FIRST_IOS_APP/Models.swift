import Foundation
import FirebaseFirestore

struct House
{
    var documentID: String?
    var nickname: String
    var customerName: String
    var address: String
    var updatedAt: Date?

    init(documentID: String? = nil,
         nickname: String = "",
         customerName: String = "",
         address: String = "",
         updatedAt: Date? = nil)
    {
        self.documentID = documentID
        self.nickname = nickname
        self.customerName = customerName
        self.address = address
        self.updatedAt = updatedAt
    }

    init(documentID: String, data: [String: Any])
    {
        self.documentID = documentID
        self.nickname = data["nickname"] as? String ?? ""
        self.customerName = data["customerName"] as? String ?? ""
        self.address = data["address"] as? String ?? ""

        if let timestamp = data["updatedAt"] as? Timestamp
        {
            self.updatedAt = timestamp.dateValue()
        }
        else
        {
            self.updatedAt = nil
        }
    }

    func toDictionary() -> [String: Any]
    {
        return [
            "nickname": nickname,
            "customerName": customerName,
            "address": address,
            "updatedAt": updatedAt ?? Date()
        ]
    }
}

struct Room
{
    var documentID: String?
    var name: String
    var done: Bool

    init(documentID: String? = nil,
         name: String = "",
         done: Bool = false)
    {
        self.documentID = documentID
        self.name = name
        self.done = done
    }

    init(documentID: String, data: [String: Any])
    {
        self.documentID = documentID
        self.name = data["name"] as? String ?? ""
        self.done = data["done"] as? Bool ?? false
    }

    func toDictionary() -> [String: Any]
    {
        return [
            "name": name,
            "done": done
        ]
    }
}

struct WindowSpace
{
    var documentID: String?
    var name: String
    var width: Double
    var height: Double
    var materialName: String
    var materialPrice: Double

    init(documentID: String? = nil,
         name: String = "",
         width: Double = 0,
         height: Double = 0,
         materialName: String = "",
         materialPrice: Double = 0)
    {
        self.documentID = documentID
        self.name = name
        self.width = width
        self.height = height
        self.materialName = materialName
        self.materialPrice = materialPrice
    }

    init(documentID: String, data: [String: Any])
    {
        self.documentID = documentID
        self.name = data["name"] as? String ?? ""
        self.width = data["width"] as? Double ?? 0
        self.height = data["height"] as? Double ?? 0
        self.materialName = data["materialName"] as? String ?? ""
        self.materialPrice = data["materialPrice"] as? Double ?? 0
    }

    func toDictionary() -> [String: Any]
    {
        return [
            "name": name,
            "width": width,
            "height": height,
            "materialName": materialName,
            "materialPrice": materialPrice
        ]
    }
}

struct FloorSpace
{
    var documentID: String?
    var name: String
    var width: Double
    var length: Double
    var materialName: String
    var materialPrice: Double

    init(documentID: String? = nil,
         name: String = "",
         width: Double = 0,
         length: Double = 0,
         materialName: String = "",
         materialPrice: Double = 0)
    {
        self.documentID = documentID
        self.name = name
        self.width = width
        self.length = length
        self.materialName = materialName
        self.materialPrice = materialPrice
    }

    init(documentID: String, data: [String: Any])
    {
        self.documentID = documentID
        self.name = data["name"] as? String ?? ""
        self.width = data["width"] as? Double ?? 0
        self.length = data["length"] as? Double ?? 0
        self.materialName = data["materialName"] as? String ?? ""
        self.materialPrice = data["materialPrice"] as? Double ?? 0
    }

    func toDictionary() -> [String: Any]
    {
        return [
            "name": name,
            "width": width,
            "length": length,
            "materialName": materialName,
            "materialPrice": materialPrice
        ]
    }
}
