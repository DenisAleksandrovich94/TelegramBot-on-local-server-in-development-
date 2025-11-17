import Vapor

// Для API из iOS-приложения
struct SendMessagePayload: Content {
    let chatId: Int64
    let text: String
}
