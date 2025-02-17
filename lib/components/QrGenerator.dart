import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:slider_button/slider_button.dart';

import '../Match_Pages/match_page.dart';
import '../Plugins/plugin_state_manager.dart';
import 'DataBase.dart';
import 'compactifier.dart';

class Qrgenerator extends StatefulWidget {
  const Qrgenerator({super.key});

  @override
  QrCoder createState() => QrCoder();
}

class QrCoder extends State<Qrgenerator> {
  final LocalDataBase dataMaster = LocalDataBase();
  final PluginStateManager pluginStateManager = PluginStateManager();
  @override
  Widget build(BuildContext context) {
    print(LocalDataBase.getData('Settings.apiKey'));

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code',
            style: GoogleFonts.museoModerno(
              fontSize: 25,
            )),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImageView(
              data: jsonEncode(jsonDecode(
                  correctJsonFormat(LocalDataBase.getMatchData().toString()))),
              version: QrVersions.auto,
              size: MediaQuery.of(context).size.width - 40,
              semanticsLabel: 'QR code',
              // eyeStyle: const QrEyeStyle(
              //   eyeShape: QrEyeShape.circle,
              //   color: Colors.red,
              // ),
              gapless: false,
              // dataModuleStyle: const QrDataModuleStyle(
              //   dataModuleShape: QrDataModuleShape.circle,
              //   color: Colors.blue,
              // ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            const Text(
              'Scan the QR code to submit the data',
              style: TextStyle(fontSize: 20.0),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 8, right: 8),
              child: Container(
                width: MediaQuery.of(context).size.width - 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SliderButton(
                  buttonColor: const Color(0xFFFFD700), // Golden color
                  backgroundColor: Colors.white,
                  highlightedColor: Colors.red,
                  buttonSize: 70,
                  dismissThresholds: 0.97,
                  vibrationFlag: true,
                  width: MediaQuery.of(context).size.width - 40,
                  action: () async {
                    MatchLogs.addLog(LocalDataBase.getMatchData().toString());
                    await InititiateTransactions(
                        LocalDataBase.getMatchData().toString());
                    return true;
                  },
                  label: const Text(
                    "Slide to Scout Next Match",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  icon: const Icon(
                    Icons.send_outlined,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> InititiateTransactions(String qrData) async {
    var box = Hive.box('settings');
    String? ipAddress = box.get('ipAddress');
    String? deviceName = box.get('deviceName');

    print('IP Address: $ipAddress');
    print('Device Name: $deviceName');

    bool serverStatus =
        await pluginStateManager.getPluginState("intergrateWithPyintelScoutz");
    if (serverStatus) {
      if (ipAddress != null && deviceName != null) {
        String url = 'http://$ipAddress/send_data';
        try {
          print('Attempting to send data...');
          final response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'device_name': deviceName, 'data': qrData}),
          );

          print('Response status: ${response.statusCode}');
          if (response.statusCode == 200) {
            final responseBody = jsonDecode(response.body);
            print('Response body: $responseBody');

            // Confirm function completion
            print('Data sent successfully.');

            // Example: Confirm whether data clearing and navigation are happening
            LocalDataBase.clearData();
            print(LocalDataBase.getData('Settings.apiKey'));

            print("Data Cleared");

            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MatchPage(),
                  fullscreenDialog: true),
            );

            // Confirm navigation completion
            print('Navigation to HomePage completed.');
          } else {
            // Handle non-200 responses
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content:
                      Text('Server returned an error: ${response.statusCode}'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MatchPage(),
                              fullscreenDialog: true),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
        } catch (e) {
          print('Error: $e');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Failed to communicate with the server.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      LocalDataBase.clearData();
                      print(LocalDataBase.getData('Settings.apiKey'));
                      print("Data Cleared");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MatchPage(),
                            fullscreenDialog: true),
                      );
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        // IP address or device name not found in Hive
        print('IP address or device name not found in Hive.');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('IP address or device name not configured.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MatchPage(),
                          fullscreenDialog: true),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      print('Server is not running.');
      LocalDataBase.clearData();
      print(LocalDataBase.getData('Settings.apiKey'));
      print("Data Cleared");

      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const MatchPage(), fullscreenDialog: true),
      );
    }
  }
}
