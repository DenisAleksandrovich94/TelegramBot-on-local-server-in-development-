import Vapor
import Fluent
import FluentPostgresDriver


public func configure(_ app: Application) throws {
    guard let token = Environment.get("TELEGRAM_BOT_TOKEN") else {
        fatalError("TELEGRAM_BOT_TOKEN не задан. Запустите: TELEGRAM_BOT_TOKEN=xxx swift run")
    }
    
    guard let databaseURL = Environment.get("DATABASE_URL") else {
        fatalError("DATABASE_URL не задан")
    }
    

    app.databases.use(try .postgres(url: databaseURL), as: .psql)
    
    
    app.migrations.add(CreateTelegramUser())
    app.migrations.add(CreateProduct())
    
    // Запуск бота
    Task {
        await sharedTelegramBot.startLongPolling(app: app, token: token)
    }
    
    // API
    app.post("sendMessage") { req async throws -> HTTPStatus in
        let payload = try req.content.decode(SendMessagePayload.self)
        await TelegramAPI.sendText(token: token, chatId: payload.chatId, text: payload.text)
        return .ok
    }
}
