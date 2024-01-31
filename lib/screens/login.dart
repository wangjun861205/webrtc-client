import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webrtc_client/apis/login.dart';
import 'package:go_router/go_router.dart';
import 'package:webrtc_client/blocs/ws.dart';
import 'package:webrtc_client/utils.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  LoginScreen({super.key});

  Widget input(
      {required TextEditingController controller,
      required Widget label,
      required String hintText,
      bool obscureText = false}) {
    return ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 300,
          minWidth: 200,
        ),
        child: TextField(
          obscureText: true,
          controller: controller,
          decoration: InputDecoration(label: label, hintText: hintText),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final ws = BlocProvider.of<WSCubit>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          input(
              controller: phoneCtrl,
              label: const Text("Phone"),
              hintText: "Please enter your phone"),
          input(
              controller: passwordCtrl,
              label: const Text("Password"),
              hintText: "Please enter your password",
              obscureText: true),
          ElevatedButton(
              onPressed: () =>
                  login(phone: phoneCtrl.text, password: passwordCtrl.text)
                      .then((token) {
                    putAuthToken(token).then((_) {
                      ws
                          .setWS(WebSocketChannel.connect(Uri.parse(
                              "ws://${dotenv.env["BACKEND_DOMAIN"]}/apis/v1/ws?auth_token=$token")))
                          .then((_) {
                        context.go("/");
                      });
                    }, onError: (err) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(err.toString())));
                    });
                  },
                          onError: (err) => ScaffoldMessenger.of(context)
                              .showSnackBar(
                                  SnackBar(content: Text(err.toString())))),
              child: const Text("Login")),
          TextButton(
              onPressed: () => context.go("/signup"),
              child: const Text("Signup"))
        ]),
      ),
    );
  }
}
