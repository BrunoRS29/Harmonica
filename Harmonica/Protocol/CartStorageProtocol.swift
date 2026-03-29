import Foundation
import CoreData

protocol CartStorageProtocol {
    func fetch(userEmail: String) -> [CartItem]
    func add(item: CartItem)
    func delete(item: CartItem)
    func deleteAll(items: [CartItem])
    func save() throws
}
