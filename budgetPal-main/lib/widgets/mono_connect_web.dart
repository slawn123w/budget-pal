import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'dart:convert';

typedef MonoCodeCallback = void Function(String code);

class MonoConnectWebDialog extends StatefulWidget {
  final String url;
  final MonoCodeCallback onCode;
  const MonoConnectWebDialog({super.key, required this.url, required this.onCode});

  @override
  State<MonoConnectWebDialog> createState() => _MonoConnectWebDialogState();
}

class _MonoConnectWebDialogState extends State<MonoConnectWebDialog> {
  html.EventListener? _listener;

  @override
  void initState() {
    super.initState();
    _listener = (event) {
      if (event is html.MessageEvent) {
        dynamic data = event.data;
        // If data is a JSON string, decode it
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (_) {}
        }
        if (data is Map && data['type'] == 'mono.code' && data['code'] != null) {
          widget.onCode(data['code']);
          Navigator.of(context).pop();
        }
      }
    };
    html.window.addEventListener('message', _listener!);
  }

  @override
  void dispose() {
    if (_listener != null) {
      html.window.removeEventListener('message', _listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Register a view type for the iframe
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'mono-connect-iframe',
      (int viewId) => html.IFrameElement()
        ..src = widget.url
        ..style.border = 'none'
        ..width = '100%'
        ..height = '100%'
        ..allow = 'clipboard-read; clipboard-write',
    );
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 400,
        height: 600,
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(color: Colors.white),
            ),
            HtmlElementView(viewType: 'mono-connect-iframe'),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
