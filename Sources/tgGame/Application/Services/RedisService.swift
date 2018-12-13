//
//  RedisService.swift
//  tgGame
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

    private var _publisher: EventLoopFuture<RedisClient>?
    private var publisher: EventLoopFuture<RedisClient> {
        if (_publisher == nil) {
            let group1 = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            _publisher = db.newConnection(on: group1)
        }
        return _publisher!
    }

    private var _subscriber: EventLoopFuture<RedisClient>?
    private var subscriber: EventLoopFuture<RedisClient> {
        if (_subscriber == nil) {
            let group1 = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            _subscriber = db.newConnection(on: group1)
        }
        return _subscriber!
    }

    func unsubscribe() {
        _ = self.subscriber.do({ (client) in
            client.close()
        })
        _subscriber = nil
    }

    func subscribe(_ completion: @escaping ([ActionResponse]?) -> Void) {
        _ = self.subscriber.do({ (client) in
            let _ = try! client.subscribe([self.outputChannel], subscriptionHandler: { (redisChannelData) in
                do {
                    print(redisChannelData.data.string)
                    let responses = try JSONDecoder().decode([ActionResponse].self, from: redisChannelData.data.data!)
                    completion(responses.count == 0 ? nil : responses)
                } catch {
                    completion(nil)
                }
            })
        })
    }

    func publish(json: String) {
        _ = self.publisher.do( { client in
            let publishData = RedisData.bulkString(json)
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
