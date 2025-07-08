        // C:\Users\user\Desktop\0703flutter_v2\lib\core\base_screen.dart

        import 'package:flutter/material.dart';

        abstract class BaseScreen<T extends StatefulWidget> extends State<T> {
          bool _loading = false;

          void showLoading([bool show = true]) {
            setState(() {
              _loading = show;
            });
          }

          Widget buildBody(BuildContext context);

          @override
          Widget build(BuildContext context) {
            return Stack(
              children: [
                buildBody(context),
                if (_loading)
                  const Opacity(
                    opacity: 0.6,
                    child: ModalBarrier(dismissible: false, color: Colors.black),
                  ),
                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          }
        }
        