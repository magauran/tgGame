//
//  RedisService.swift
//  Async
//
//  Created by Алексей on 12/12/2018.
//

import Redis
import Vapor

class RedisService {

    static let shared = RedisService()
    private let inputChannel = "input"
    private let outputChannel = "output"

    private lazy var db: RedisDatabase = {
        let redisConfigURL = URL(string: Secret.Config.redis)!
        let redisConfig = RedisClientConfig(url: redisConfigURL)
        return try! RedisDatabase(config: redisConfig)
    }()

    private lazy var publisher: EventLoopFuture<RedisClient>? = {
        let group1 = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        return db.newConnection(on: group1)
    }()

    private var subscriberClient: RedisClient?

    func connect() {
        let group1 = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.subscriberClient = try! self.db.newConnection(on: group1).wait()
    }

    func close() {
        self.subscriberClient!.close()
    }

    func subscribe(_ completion: @escaping (String) -> Void) {

        do {
            let _ = try self.subscriberClient!.subscribe(["output"], subscriptionHandler: { redisChannelData in
                var str = redisChannelData.data.string ?? "Что-то пошло не так"
                if str == "[]" { str = "upd" }
                print(str)
                completion(str)
            })

        } catch {
            print(error)
        }

    }

    func publish() {
        _ = self.publisher?.do( { client in
            let publishData = RedisData.bulkString("{\"nick\": \"blabla\", \"action\": 2, \"target\": \"blabla\"}")
            _ = client.publish(publishData, to: self.inputChannel)
        })
    }
}


extension Dictionary {
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
}
