//
//  FightController.swift
//  tgGame
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
        case fighters = "Посмотреть список бойцов"
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

        RedisService.shared.subscribe { (response) in
            if let responces = response {
                for resp in responces {
                    self.sendMessageToAll(text: resp.localizedDescription)
                }
            }
        }

        let params = Bot.SendMessageParams(chatId: chatId,
                                           text: "Выживай!",
                                           parseMode: .markdown)
        let _ = try bot.sendMessage(params: params).and(self.showMenu(chatId))

        let fighter = Fighter(name: "\(user.id)", username: user.firstName, chatId: Int(message.chat.id))
        let action = Action(fighter: fighter, actionType: ActionType.join, target: nil)
        Battlefield.shared.fighters["\(user.id)"] = fighter
        guard let actionJson = action.json else { return }
        RedisService.shared.publish(json: actionJson)
    }

    func keyboard(_ update: Update, _ context: BotContext?) throws {
        guard
            let message = update.message,
            let text = message.text,
            let button = Button(rawValue: text),
            let user = message.from
            else { return }

        let chatId: ChatId = .chat(message.chat.id)

        switch button {
        case .hit:
            sendMessage(chatId: chatId, text: "Удар")

            let fighter = Fighter(name: "\(user.id)", username: user.firstName, chatId: Int(message.chat.id))
            let action = Action(fighter: fighter, actionType: ActionType.hit, target: nil)
            guard let actionJson = action.json else { return }
            RedisService.shared.publish(json: actionJson)
        case .dodge:
            sendMessage(chatId: chatId, text: "Уворот")
            let fighter = Fighter(name: "\(user.id)", username: user.firstName, chatId: Int(message.chat.id))
            let action = Action(fighter: fighter, actionType: ActionType.dodge, target: nil)
            guard let actionJson = action.json else { return }
            RedisService.shared.publish(json: actionJson)
        case .escape:
            sendMessageToAll(text: "\(user.firstName) сбежал, теряя зубы")
            RedisService.shared.unsubscribe()
            let mainController = MainController(bot: bot)
            try mainController.start(update, context)
        case .fighters:
            let fighters = Battlefield.shared.fighters.map { $0 }
            let names = fighters.map { "\($0.value.username) - \($0.value.health)" }.joined(separator: "\n")
            sendMessage(chatId: chatId, text: "В замесе:\n\(names)")
        }
    }

    // MARK: - Private methods

    private func showMenu(_ chatId: ChatId) -> Future<Message> {
        let keyboardButtons = [[KeyboardButton(text: Button.hit.rawValue)],
                               [KeyboardButton(text: Button.dodge.rawValue)],
                               [KeyboardButton(text: Button.escape.rawValue)],
                               [KeyboardButton(text: Button.fighters.rawValue)]
        ]
        let keyboardMarkup = ReplyKeyboardMarkup(keyboard: keyboardButtons, resizeKeyboard: false, oneTimeKeyboard: true, selective: false)
        let params = Bot.SendMessageParams(chatId: chatId, text: "Выбери действие", parseMode: .markdown,  replyMarkup: .replyKeyboardMarkup(keyboardMarkup))
        return try! bot.sendMessage(params: params)
    }

    private func sendMessageToAll(text: String) {
        for (_ , fighter) in Battlefield.shared.fighters {
            sendMessage(chatId: .chat(Int64(fighter.chatId)), text: text)
        }
    }

    private func sendMessage(chatId: ChatId, text: String) {
        let params = Bot.SendMessageParams(chatId: chatId,
                                           text: text,
                                      parseMode: .markdown)
        let _ = try! self.bot.sendMessage(params: params)
    }

}
