import Foundation
import FirebaseFirestore

struct House
{
    var documentID: String?
    var nickname: String
    var customerName: String
    var address: String
    var createdAt: Date?

    init(documentID: String? = nil,
         nickname: String = "",
         customerName: String = "",
         address: String = "",
         createdAt: Date? = nil)
    {
        self.documentID = documentID
        self.nickname = nickname
        self.customerName = customerName
        self.address = address
        self.createdAt = createdAt
    }

    init(documentID: String, data: [String: Any])
    {
        self.documentID = documentID
        self.nickname = data["nickname"] as? String ?? ""
        self.customerName = data["customerName"] as? String ?? ""
        self.address = data["address"] as? String ?? ""

        if let timestamp = data["createdAt"] as? Timestamp
        {
            self.createdAt = timestamp.dateValue()
        }
        else
        {
            self.createdAt = nil
        }
    }

    func toDictionary() -> [String: Any]
    {
        return [
            "nickname": nickname,
            "customerName": customerName,
            "address": address,
            "createdAt": createdAt ?? Date()
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
