import Foundation
import Telegrammer

try app(.detect()).run()
// ниже всё надо убрать

let token = Tokens.telegram
var settings = Bot.Settings(token: token)
let bot = try! Bot(settings: settings)
