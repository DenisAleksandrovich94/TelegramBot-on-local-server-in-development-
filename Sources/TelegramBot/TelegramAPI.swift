import Foundation

enum TelegramAPI {
    static func makeGetUpdatesURL(token: String, offset: Int? = nil, timeout: Int = 30) -> URL? {
        var comps = URLComponents(string: "https://api.telegram.org/bot\(token)/getUpdates")!
        var query: [URLQueryItem] = []
        if let offset = offset {
            query.append(URLQueryItem(name: "offset", value: "\(offset + 1)"))
        }
        query.append(URLQueryItem(name: "timeout", value: String(timeout)))
        comps.queryItems = query
        return comps.url
    }

    static func makeSendMessageURL(token: String) -> URL {
        return URL(string: "https://api.telegram.org/bot\(token)/sendMessage")!
    }

    static func sendText(token: String, chatId: Int64, text: String) async {
        let url = makeSendMessageURL(token: token)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let body: [String: Any] = ["chat_id": chatId, "text": text]
            
            // Serialize the body to JSON Data
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            req.httpBody = jsonData
            
            let (_, response) = try await URLSession.shared.data(for: req)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP Error: \(httpResponse.statusCode)")
                return
            }
            print("Message sent successfully.")
        } catch {
            print("Error sending message: \(error)")
        }
    }
    
    static func sendTelegramMessageWithKeyboard(token: String, chatId: Int64, text: String, keyboard: [[String]]) async {
        let url = URL(string: "https://api.telegram.org/bot\(token)/sendMessage")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let replyMarkup: [String: Any] = [
            "keyboard": keyboard,
            "resize_keyboard": true,
            "one_time_keyboard": true
        ]
        
        let body: [String: Any] = [
            "chat_id": chatId,
            "text": text,
            "reply_markup": replyMarkup
        ]
        
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        _ = try? await URLSession.shared.data(for: req)
    }
}
