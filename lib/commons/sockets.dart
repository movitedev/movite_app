import 'package:movite_app/commons/preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'env.dart';

class MySockets{

  static IO.Socket chatSocket, messageSocket;

  Future init() async {

    chatSocket = IO.io(environment['url'] + '/chats', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'token': await MyPreferences.getAuthCode()}
    });

    messageSocket = IO.io(environment['url'] + '/messages', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'token': await MyPreferences.getAuthCode()}
    });

  }

}

