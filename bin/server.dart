import 'dart:io';

Future<void> main() async {
  var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8000);
  print('Listening on localhost:${server.port}');

  List<WebSocket> websockets = [];

  sendAllClients(String message) {
    print(message);
    print(websockets.length);

    for (var element in websockets) {
      element.add('echo $message');
    }
  }

  await for (HttpRequest request in server) {
    print(request.requestedUri);
    if (request.uri.path == '/') {
      // Upgrade an HttpRequest to a WebSocket connection
      var socket = await WebSocketTransformer.upgrade(request);
      websockets.add(socket);
      print('Client connected!');

      // Listen for incoming messages from the client
      socket.listen((message) {
        print('Received message: $message');
        sendAllClients(message);
        // socket.add('echo $message');
      });
    } else {
      request.response.statusCode = HttpStatus.forbidden;
      request.response.close();
    }
  }
}
