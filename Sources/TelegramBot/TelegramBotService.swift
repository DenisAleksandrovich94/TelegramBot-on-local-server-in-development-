// TelegramBotService.swift
import Vapor
import Foundation

actor TelegramBotService {
    private var lastUpdateId: Int?
    
    func startLongPolling(app: Application, token: String) async {
        app.logger.info("Запуск Telegram бота (long polling)...")
        while !Task.isCancelled {
            do {
                guard let url = TelegramAPI.makeGetUpdatesURL(token: token, offset: lastUpdateId) else {
                    app.logger.error("Некорректный URL для getUpdates")
                    try await Task.sleep(for: .seconds(5))
                    continue
                }
                
                let (data, _) = try await URLSession.shared.data(from: url)
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                guard let ok = json?["ok"] as? Bool, ok,
                      let updates = json?["result"] as? [[String: Any]] else {
                    try await Task.sleep(for: .seconds(5))
                    continue
                }
                
                for update in updates {
                    if let id = update["update_id"] as? Int {
                        lastUpdateId = max(lastUpdateId ?? 0, id)
                    }
                    
                    if let msg = update["message"] as? [String: Any],
                       let chat = msg["chat"] as? [String: Any],
                       let chatId = chat["id"] as? Int64 {
                        
                        // 👇 Парсим данные пользователя из msg["from"]
                        let userDict = msg["from"] as? [String: Any] ?? [:]
                        let userId = (userDict["id"] as? Int64) ?? 0
                        let username = userDict["username"] as? String
                        let firstName = userDict["first_name"] as? String
                        let lastName = userDict["last_name"] as? String
                        
                        // 🎯 СОХРАНЯЕМ / ОБНОВЛЯЕМ пользователя
                        if userId != 0 {
                            await saveUserIfNew(
                                app: app,
                                telegramId: userId,
                                username: username,
                                firstName: firstName,
                                lastName: lastName
                            )
                        }
                        
                        // Обработка команд
                        if let text = msg["text"] as? String {
                            if text == "/start" {
                                let keyboard = [
                                    ["/swift", "/ping"],
                                    ["🛒 Товары", "📦 Заказы"],
                                    ["❓ Помощь"]
                                ]
                                await TelegramAPI.sendTelegramMessageWithKeyboard(
                                    token: token,
                                    chatId: chatId,
                                    text: "Выберите команду:",
                                    keyboard: keyboard
                                )
                                continue
                            } else {
                                let response: String
                                switch text {
                                case "❓ Помощь": response = "Доступные команды: \n/swift,\n/ping"
                                case "/ping": response = "Pong!"
                                case "/swift": response = "Отличный выбор!"
                                default: response = "Вы написали: \(text)"
                                }
                                await TelegramAPI.sendText(token: token, chatId: chatId, text: response)
                            }
                        }
                    }
                }
            } catch {
                app.logger.error("Ошибка Telegram: \(error)")
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }
    
    // 🔑 Основной метод: сохранить, если нового; обновить — если есть
    private func saveUserIfNew(
        app: Application,
        telegramId: Int64,
        username: String?,
        firstName: String?,
        lastName: String?
    ) async {
        guard telegramId > 0 else { return }
        
        do {
            // Пытаемся найти по telegram_id
            if let existing = try await TelegramUser.query(on: app.db)
                .filter("telegram_id", .equal, telegramId)
                .first() {
                // 👤 Обновляем данные (если изменились)
                existing.username = username
                existing.firstName = firstName
                existing.lastName = lastName
                try await existing.save(on: app.db)
                app.logger.info("Обновлён пользователь: \(telegramId)")
            } else {
                // ➕ Создаём нового
                let newUser = TelegramUser(
                    telegramId: telegramId,
                    username: username,
                    firstName: firstName,
                    lastName: lastName
                )
                try await newUser.save(on: app.db)
                app.logger.info("Создан новый пользователь: \(telegramId)")
            }
        } catch {
            app.logger.error("Ошибка сохранения пользователя \(telegramId): \(error)")
        }
    }
}

let sharedTelegramBot = TelegramBotService()
