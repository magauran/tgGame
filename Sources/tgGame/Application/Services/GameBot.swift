//
//  GameBot.swift
//  GameBot
//
//  Created by Алексей on 8/12/2018.
//

import Foundation
import Telegrammer
import Vapor
import Redis

final class GameBot: ServiceType {
    
    let bot: Bot
    var updater: Updater?
    var dispatcher: Dispatcher?
    
    /// Dictionary for user echo modes
    var userEchoModes: [Int64: Bool] = [:]
    
    ///Conformance to `ServiceType` protocol, fabric methhod
    static func makeService(for worker: Container) throws -> GameBot {
        let token = Secret.Token.telegram

        let settings = Bot.Settings(token: token, debugMode: true)
    
        /// Setting up webhooks https://core.telegram.org/bots/webhooks
        /// Internal server address (Local IP), where server will starts
        // settings.webhooksIp = "127.0.0.1"
        
        /// Internal server port, must be different from Vapor port
        // settings.webhooksPort = 8181
        
        /// External endpoint for your bot server
        // settings.webhooksUrl = "https://website.com/webhooks"
        
        /// If you are using self-signed certificate, point it's filename
        // settings.webhooksPublicCert = "public.pem"

        return try GameBot(settings: settings)
    }
    
    init(settings: Bot.Settings) throws {
        self.bot = try Bot(settings: settings)
        let dispatcher = try configureDispatcher()
        self.dispatcher = dispatcher
        self.updater = Updater(bot: bot, dispatcher: dispatcher)
    }
    
    /// Initializing dispatcher, object that receive updates from Updater
    /// and pass them throught handlers pipeline
    func configureDispatcher() throws -> Dispatcher {
        ///Dispatcher - handle all incoming messages
        let dispatcher = Dispatcher(bot: bot)
        let mainController = MainController(bot: bot)

        ///Creating and adding handler for command /start
        let commandHandler = CommandHandler(commands: ["/start"], callback: mainController.start)
        dispatcher.add(handler: commandHandler)

        let main = MainController(bot: bot)
        let fight = FightController(bot: bot)
        dispatcher.add(handler: main.keyboardHandler, to: HandlerGroup.init(id: 10, name: "main"))
        dispatcher.add(handler: fight.keyboardHandler, to: HandlerGroup.init(id: 11, name: "fight"))
        
        return dispatcher
    }
}
