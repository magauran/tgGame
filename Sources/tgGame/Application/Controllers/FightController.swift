//
//  FightController.swift
//  Async
//
//  Created by Алексей on 13/12/2018.
//

import Telegrammer
import NIO
import Redis

class FightController {

    enum Button: String {
        case hit = "Ударить"
        case dodge = "Увернуться"
        case escape = "Убежать"
    }

    private let bot: Bot
    private weak var gameBot: GameBot?
    private lazy var keyboardHandler: MessageHandler = {
        return MessageHandler(name: "Keyboard",
                              filters: Filters.text,
                              callback: self.keyboard)
    }()

    init(bot: Bot, gameBot: GameBot?) {
        self.bot = bot
        self.gameBot = gameBot
    }

    // MARK: - Handler callbacks

    func start(_ update: Update, _ context: BotContext?) throws {
        guard
            let message = update.message
            else { return }
        let chatId: ChatId = .chat(message.chat.id)

        gameBot?.dispatcher?.add(handler: keyboardHandler)

        RedisService.shared.subscribe { (response) in
            let params = Bot.SendMessageParams(chatId: chatId,
                                               text: response,
                                          parseMode: .markdown)
            let _ = try! self.bot.sendMessage(params: params)
        }

        let params = Bot.SendMessageParams(chatId: chatId,
                                           text: "Выживай!",
                                           parseMode: .markdown)
        let _ = try bot.sendMessage(params: params).and(self.showMenu(chatId))
    }

    func keyboard(_ update: Update, _ context: BotContext?) throws {
        guard
            let message = update.message,
            let text = message.text,
            let button = Button(rawValue: text)
            else { return }

        let chatId: ChatId = .chat(message.chat.id)

        switch button {
        case .hit:
            let params = Bot.SendMessageParams(chatId: chatId,
                                               text: "Удар",
                parseMode: .markdown)
            let _ = try! self.bot.sendMessage(params: params)

            RedisService.shared.publish()
        case .dodge:
            let params = Bot.SendMessageParams(chatId: chatId,
                                               text: "Уворот",
                parseMode: .markdown)
            let _ = try! self.bot.sendMessage(params: params)
        case .escape:
            let params = Bot.SendMessageParams(chatId: chatId,
                                               text: "Ты успешно сбежал",
                                               parseMode: .markdown)
            let _ = try! self.bot.sendMessage(params: params)
            RedisService.shared.unsubscribe()
            let mainController = MainController(bot: bot, gameBot: gameBot)
            gameBot?.dispatcher?.remove(handler: keyboardHandler, from: .zero)
            try mainController.start(update, context)
        }
//        if button == .settings {
//            RedisService.shared.subscribe { (response) in
//                let params = Bot.SendMessageParams(chatId: chatId,
//                                                   text: response,
//                                                   parseMode: .markdown)
//                let _ = try! self.bot.sendMessage(params: params)//.and(self.showMenu(chatId))
//            }
//        } else {
//            //let publishFuture =
//            RedisService.shared.publish()
//            //let _ = try! self.bot.sendMessage(params: params)
//        }

    }

    // MARK: - Private methods

    private func showMenu(_ chatId: ChatId) -> Future<Message> {
        let keyboardButtons = [[KeyboardButton(text: Button.hit.rawValue)],
                               [KeyboardButton(text: Button.dodge.rawValue)],
                               [KeyboardButton(text: Button.escape.rawValue)]]
        let keyboardMarkup = ReplyKeyboardMarkup(keyboard: keyboardButtons, resizeKeyboard: false, oneTimeKeyboard: true, selective: false)
        let params = Bot.SendMessageParams(chatId: chatId, text: "Выбери действие", parseMode: .markdown,  replyMarkup: .replyKeyboardMarkup(keyboardMarkup))
        return try! bot.sendMessage(params: params)
    }

}
