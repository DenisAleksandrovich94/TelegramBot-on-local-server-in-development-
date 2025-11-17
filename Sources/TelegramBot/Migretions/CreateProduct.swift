import Fluent

struct CreateProduct: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("products")
            .id()
            .field("title", .string, .required)
            .field("price", .custom("numeric(10,2)"), .required)
            .field("description", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime) // ← добавим updated_at сразу
            .create()
    }
    
    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("products").delete()
    }
}
