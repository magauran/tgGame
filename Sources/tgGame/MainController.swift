//
//  MainController.swift
//  tgGame
//
//  Created by Алексей on 25/11/2018.
//

import Foundation
import Telegrammer
import NIO

class MainController {

    private let bot: Bot

    init(bot: Bot) {
        self.bot = bot
    }

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

    func showMenu(_ chatId: ChatId) -> Future<Message> {
        let keyboardButtons = [[KeyboardButton(text: "Локации")],
                               [KeyboardButton(text: "Настройки")]]
        let keyboardMarkup = ReplyKeyboardMarkup(keyboard: keyboardButtons, resizeKeyboard: false, oneTimeKeyboard: true, selective: false)
        let params = Bot.SendMessageParams(chatId: chatId, text: "Для начала игры выбери локацию", parseMode: .markdown,  replyMarkup: .replyKeyboardMarkup(keyboardMarkup))
        return try! bot.sendMessage(params: params)
    }

}
