import Vapor
import Redis
import DatabaseKit

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Setting up HTTPServer
    let serverConfig = NIOServerConfig.default(hostname: "127.0.0.1")
    services.register(serverConfig)
    
    var middlewareConfig = MiddlewareConfig()
    middlewareConfig.use(ErrorMiddleware.self)
    middlewareConfig.use(SessionsMiddleware.self)
    services.register(middlewareConfig)
    
    ///Registering bot as a vapor service
    services.register(GameBot.self)
    
    ///Registering vapor routes
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Registering Redis
    try services.register(RedisProvider())

    var databases = DatabasesConfig()
    databases.add(database: RedisDatabase.self, as: .redis)
    services.register(databases)

    /// MemoryKeyedCache
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)

}
