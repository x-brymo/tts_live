import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:livespeechtotext/livespeechtotext.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tts_by_ai/notes_page.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('notesBox');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Livespeechtotext _livespeechtotextPlugin;
  late String _recognisedText;
  String? _localeDisplayName = '';
  StreamSubscription<dynamic>? onSuccessEvent;

  bool microphoneGranted = false;
  List<MapEntry<String, String>> _locales = [];
String? _selectedLocale;


  @override
  void initState() {
    super.initState();
    _livespeechtotextPlugin = Livespeechtotext();

    // _livespeechtotextPlugin.setLocale('ms-MY').then((value) async {
    //   _localeDisplayName = await _livespeechtotextPlugin.getLocaleDisplayName();

    //   setState(() {});
    // });
    _livespeechtotextPlugin.getSupportedLocales().then((value) {
  if (value != null) {
    value.entries.forEach((entry) {
      print('${entry.key} => ${entry.value}');
    });
  }
});
    _livespeechtotextPlugin.getSupportedLocales().then((value) {
  if (value != null) {
    setState(() {
      _locales = value.entries.toList();
      _selectedLocale = _locales.first.key;
    });
  }
});


    _livespeechtotextPlugin.getLocaleDisplayName().then(
      (value) => setState(() => _localeDisplayName = value),
    );

    // onSuccessEvent = _livespeechtotextPlugin.addEventListener('success', (text) {
    //   setState(() {
    //     _recognisedText = text ?? '';
    //   });
    // });

    binding().whenComplete(() => null);

    // _livespeechtotextPlugin
    //     .getSupportedLocales()
    //     .then((value) => value?.entries.forEach((element) {
    //           print(element);
    //         }));

    _recognisedText = '';
  }

  @override
  void dispose() {
    onSuccessEvent?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Live Speech To Text')),
        body: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple, width: 1),          
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recognised Text",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _recognisedText.isEmpty
                          ? "No text"
                          : (_recognisedText.length > 1000
                              ? _recognisedText.substring(0, 1000) + '...'
                              : _recognisedText),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              _recognisedText.isNotEmpty
                                  ? () async {
                                    final box = await Hive.openBox('notesBox');
                                    await box.add(_recognisedText);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Text saved to Hive notes",
                                        ),
                                      ),
                                    );
                                  }
                                  : null,
                          icon: const Icon(Icons.save),
                          label: const Text("Save to Notes"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed:
                              _recognisedText.isNotEmpty
                                  ? () {
                                    Clipboard.setData(
                                      ClipboardData(text: _recognisedText),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Copied to Clipboard"),
                                      ),
                                    );
                                  }
                                  : null,
                          icon: const Icon(Icons.copy),
                          label: const Text("Copy"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //Text(_recognisedText),
              if (!microphoneGranted)
                ElevatedButton(
                  onPressed: () {
                    binding();
                  },
                  child: const Text("Check Permissions"),
                ),
              ElevatedButton(
                onPressed:
                    microphoneGranted
                        ? () {
                          print("start button pressed");
                          try {
                            _livespeechtotextPlugin.start();
                          } on PlatformException {
                            print('error');
                          }
                        }
                        : null,
                child: const Text('Start'),
              ),
              ElevatedButton(
                onPressed:
                    microphoneGranted
                        ? () {
                          print("stop button pressed");
                          try {
                            _livespeechtotextPlugin.stop();
                          } on PlatformException {
                            print('error');
                          }
                        }
                        : null,
                child: const Text('Stop'),
              ),
              Text("Locale: $_localeDisplayName"),
              ElevatedButton(
                onPressed: () async {
                  var result = await _livespeechtotextPlugin.getText();
                  print(result);
                },
                child: const Text('Get Text'),
              ),
              
              Builder(
                builder: (context) {
                  return ElevatedButton.icon(
                    icon: const Icon(Icons.notes),
                    label: const Text("View Notes"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotesPage()),
                      );
                    },
                  );
                }
              ),
             if (_locales.isNotEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "اختر اللغة:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _selectedLocale,
          items: _locales.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text('${entry.value} (${entry.key})'),
            );
          }).toList(),
          onChanged: (value) async {
            if (value != null) {
              setState(() => _selectedLocale = value);
              await _livespeechtotextPlugin.setLocale(value);
              final displayName = await _livespeechtotextPlugin.getLocaleDisplayName();
              setState(() {
                _localeDisplayName = displayName;
              });
            }
          },
        ),
      ],
    ),
  ),


            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> binding() async {
    onSuccessEvent?.cancel();

    return Future.wait([])
        .then((_) async {
          // Check if the user has already granted microphone permission.
          var permissionStatus = await Permission.microphone.status;

          // If the user has not granted permission, prompt them for it.
          if (!microphoneGranted) {
            await Permission.microphone.request();

            // Check if the user has already granted the permission.
            permissionStatus = await Permission.microphone.status;

            if (!permissionStatus.isGranted) {
              return Future.error('Microphone access denied');
            }
          }

          // Check if the user has already granted speech permission.
          if (Platform.isIOS) {
            var speechStatus = await Permission.speech.status;

            // If the user has not granted permission, prompt them for it.
            if (!microphoneGranted) {
              await Permission.speech.request();

              // Check if the user has already granted the permission.
              speechStatus = await Permission.speech.status;

              if (!speechStatus.isGranted) {
                return Future.error('Speech access denied');
              }
            }
          }

          return Future.value(true);
        })
        .then((value) {
          microphoneGranted = true;

          // listen to event "success"
          onSuccessEvent = _livespeechtotextPlugin.addEventListener("success", (
            value,
          ) {
            if (value.runtimeType != String) return;
            if ((value as String).isEmpty) return;

            setState(() {
              _recognisedText = value;
            });
          });

          setState(() {});
        })
        .onError((error, stackTrace) {
          // toast
          log(error.toString());
          // open app setting
        });
  }
}
