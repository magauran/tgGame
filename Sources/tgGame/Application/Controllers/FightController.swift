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
            let message = update.message,
            let user = message.from
            else { return }
        let chatId: ChatId = .chat(message.chat.id)

        gameBot?.dispatcher?.add(handler: keyboardHandler)

        RedisService.shared.subscribe { (response) in
            if let responces = response {
                for resp in responces {
                    let params = Bot.SendMessageParams(chatId: chatId,
                                                       text: resp.localizedDescription,
                                                       parseMode: .markdown)
                    let _ = try! self.bot.sendMessage(params: params)
                }
            }
        }

        let params = Bot.SendMessageParams(chatId: chatId,
                                           text: "Выживай!",
                                           parseMode: .markdown)
        let _ = try bot.sendMessage(params: params).and(self.showMenu(chatId))

        let fighter = Fighter(name: "\(user.id)", username: user.firstName)
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
            let params = Bot.SendMessageParams(chatId: chatId,
                                               text: "Удар",
                parseMode: .markdown)
            let _ = try! self.bot.sendMessage(params: params)

            let fighter = Fighter(name: "\(user.id)", username: user.firstName)
            let action = Action(fighter: fighter, actionType: ActionType.hit, target: nil)
            guard let actionJson = action.json else { return }
            RedisService.shared.publish(json: actionJson)
        case .dodge:
            let params = Bot.SendMessageParams(chatId: chatId,
                                               text: "Уворот",
                parseMode: .markdown)
            let _ = try! self.bot.sendMessage(params: params)

            let fighter = Fighter(name: "\(user.id)", username: user.firstName)
            let action = Action(fighter: fighter, actionType: ActionType.dodge, target: nil)
            guard let actionJson = action.json else { return }
            RedisService.shared.publish(json: actionJson)
        case .escape:
            let params = Bot.SendMessageParams(chatId: chatId,
                                               text: "Ты успешно сбежал",
                                               parseMode: .markdown)
            let _ = try! self.bot.sendMessage(params: params)
            RedisService.shared.unsubscribe()
            let mainController = MainController(bot: bot, gameBot: gameBot)
            gameBot?.dispatcher?.remove(handler: keyboardHandler, from: .zero)
            try mainController.start(update, context)
        case .fighters:
            let fighters = Battlefield.shared.fighters.map { $0 }
            let names = fighters.map { $0.value.username }.joined(separator: "\n")
            let params = Bot.SendMessageParams(chatId: chatId,
                                               text: "В данный момент дерутся:\n\(names)",
                                               parseMode: .markdown)
            let _ = try! self.bot.sendMessage(params: params)
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

}
