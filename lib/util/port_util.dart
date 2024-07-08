import 'dart:io';

Future<bool> isPortInUse(int port) async {
  try {
    var serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    await serverSocket.close();
    return false; // 端口没有被占用
  } catch (e) {
    return true; // 端口已被占用
  }
}
