import Vapor
import Fluent

final class Product: Model, @unchecked Sendable {
    static let schema = "products"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String?

    @Field(key: "price")
    var price: Double  // можно заменить на Decimal128 при интеграции с PostgreSQL

    @Field(key: "stock_quantity")
    var stockQuantity: Int  // количество на складе

    @Field(key: "is_available")
    var isAvailable: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    // MARK: - Init

    init() { }

    init(
        id: UUID? = nil,
        name: String,
        description: String? = nil,
        price: Double,
        stockQuantity: Int = 0,
        isAvailable: Bool = true
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.stockQuantity = stockQuantity
        self.isAvailable = isAvailable
    }
}
