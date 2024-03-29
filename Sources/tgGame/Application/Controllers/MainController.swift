//
//  MainController.swift
//  tgGame
//
//  Created by Алексей on 25/11/2018.
//

import Foundation
import Telegrammer
import NIO
import Redis

class MainController {

    enum Button: String {
        case join = "Присоединиться"
        case settings = "Настройки"
    }

    private let bot: Bot
    lazy var keyboardHandler: MessageHandler = {
        return MessageHandler(name: "Keyboard",
                              filters: Filters.text,
                              callback: self.keyboard)
    }()

    init(bot: Bot) {
        self.bot = bot
    }

    // MARK: - Handler callbacks

    func start(_ update: Update, _ context: BotContext?) throws {
        guard
            let message = update.message,
            let user = message.from
            else { return }
        let chatId: ChatId = .chat(message.chat.id)

        let params = Bot.SendMessageParams(chatId: chatId,
                                          text: "Привет, \(user.firstName)!",
                                          parseMode: .markdown)
        let _ = try bot.sendMessage(params: params).and(self.showMenu(chatId))
    }

    func keyboard(_ update: Update, _ context: BotContext?) throws {
        guard
            let message = update.message,
            let text = message.text,
            let button = Button(rawValue: text)
            else { return }

        switch button {
        case .join:
            let fightController = FightController(bot: bot)
            try fightController.start(update, context)
        case .settings:
            break
        }

    }

    // MARK: - Private methods

    private func showMenu(_ chatId: ChatId) -> Future<Message> {
        let keyboardButtons = [[KeyboardButton(text: Button.join.rawValue)],
                               [KeyboardButton(text: Button.settings.rawValue)]]
        let keyboardMarkup = ReplyKeyboardMarkup(keyboard: keyboardButtons, resizeKeyboard: false, oneTimeKeyboard: true, selective: false)
        let params = Bot.SendMessageParams(chatId: chatId, text: "Недалеко началась драка", parseMode: .markdown,  replyMarkup: .replyKeyboardMarkup(keyboardMarkup))
        return try! bot.sendMessage(params: params)
    }

}
