import Fluent

struct CreateTelegramUser: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("telegram_users")
            .id()
            .field("telegram_id", .int64, .required)
            .field("username", .string)
            .field("first_name", .string)
            .field("last_name", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "telegram_id") // ← КЛЮЧЕВОЙ ИНДЕКС — обеспечивает уникальность!
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("telegram_users").delete()
    }
}
