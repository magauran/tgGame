import Foundation
import Telegrammer

let token = Tokens.telegram
var settings = Bot.Settings(token: token)
let bot = try! Bot(settings: settings)

var userEchoModes: [Int64: Bool] = [:]

///Callback for Command handler, which send Echo mode status for user
func echoModeSwitch(_ update: Update, _ context: BotContext?) throws {
    guard let message = update.message,
        let user = message.from else { return }
    
    var onText = ""
    if let on = userEchoModes[user.id] {
        onText = on ? "OFF" : "ON"
        userEchoModes[user.id] = !on
    } else {
        onText = "ON"
        userEchoModes[user.id] = true
    }

    let params = Bot.SendMessageParams(chatId: .chat(message.chat.id), text: "Echo mode turned \(onText)")
    try bot.sendMessage(params: params)
}

///Callback for Message handler, which send echo message to user
func echoResponse(_ update: Update, _ context: BotContext?) throws {
    guard let message = update.message,
        let user = message.from,
        let on = userEchoModes[user.id],
        on == true else { return }
    let params = Bot.SendMessageParams(chatId: .chat(message.chat.id), text: message.text!)
    try bot.sendMessage(params: params)
}

do {
    let dispatcher = Dispatcher(bot: bot)
    let mainController = MainController(bot: bot)

    let commandHandler = CommandHandler(commands: ["/start"], callback: mainController.start)
    dispatcher.add(handler: commandHandler)

    _ = try Updater(bot: bot, dispatcher: dispatcher).startLongpolling().wait()
    
} catch {
    print(error.localizedDescription)
}
