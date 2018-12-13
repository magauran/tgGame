# tgGame

Недалеко началась драка! Участвуешь?
Игра - это драка между всеми участниками. Хочешь набить морду одногруппнику? Или увернуться от крутых ударов твоего соседа? Вперед, к победе, замочи всех, чтобы получить зачет!

The game is implemented using microservices and telegram. 2 microservices are used: the first (frontend) implements the telegram bot interface, processes user requests, sends them to the [second](https://gitlab.com/vahriin/tggame) (backend). Backend implements the physics of the game and gives the results of the frontend round. Frontend translates internal messages into text and sends them to the user via telegram.
Communication between services is carried out with the help of [Redis](https://redislabs.com/).

<img src="https://github.com/magauran/tgGame/blob/master/ezgif.com-video-to-gif.gif" width="400">

### Used frameworks  
* [SwiftNIO](https://github.com/apple/swift-nio): Event-driven network application framework for high performance protocol servers & clients, non-blocking.
* [Telegrammer](https://github.com/givip/Telegrammer): Telegram Bot Framework.
* [Vapor](https://github.com/vapor/vapor): A server-side Swift web framework. 
* [Vapor/redis](https://github.com/vapor/redis): Non-blocking, event-driven Redis client.
