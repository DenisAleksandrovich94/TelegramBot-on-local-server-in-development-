import Vapor
import Fluent

final class TelegramUser: Model, @unchecked Sendable {
    static let schema = "telegram_users"

   
    @ID(key: .id)
    var id: UUID?

    @Field(key: "telegram_id")
    var telegramId: Int64

    @Field(key: "username")
    var username: String?

    @Field(key: "first_name")
    var firstName: String?

    @Field(key: "last_name")
    var lastName: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        telegramId: Int64,
        username: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil
    ) {
        self.id = id
        self.telegramId = telegramId
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
    }
}
