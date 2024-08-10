

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

import '../components/DataBase.dart';
import '../components/localmatchLoader.dart';
import '../components/nav.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool isLocationGranted = false;
  bool isBluetoothGranted = false;
  bool isNearbyDevicesGranted = false;

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();
  }

  Future<void> _checkInitialPermissions() async {
    var locationStatus = await Permission.location.status;
    var bluetoothStatus = await Permission.bluetooth.status;
    var nearbyDevicesStatus = await Permission.bluetoothAdvertise.status;

    setState(() {
      isLocationGranted = locationStatus.isGranted;
      isBluetoothGranted = bluetoothStatus.isGranted;
      isNearbyDevicesGranted = nearbyDevicesStatus.isGranted;
    });
  }

  Future<void> _requestPermission(Permission permission, bool currentValue,
      Function(bool) onChanged) async {
    if (currentValue) {
      if (await permission.request().isGranted) {
        onChanged(true);
      } else {
        onChanged(false);
      }
    } else {
      onChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color.fromARGB(255, 241, 255, 241),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: TextEditingController()
                  ..text =
                      Hive.box('userData').get('scouterName', defaultValue: ''),
                decoration: InputDecoration(
                  labelText: 'Scouter Name',
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                onSubmitted: (String value) {
                  Hive.box('userData').put('scouterName', value);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 241, 255, 241),
              ),
              child: Column(
                children: [
                  // Switch for Location permission
                  SwitchListTile(
                    tileColor: const Color.fromARGB(255, 241, 255, 241),
                    contentPadding: const EdgeInsets.only(left: 10, right: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    title: const Text("Location"),
                    thumbIcon: thumbIcon,
                    value: isLocationGranted,
                    onChanged: (bool value) {
                      _requestPermission(Permission.location, value,
                          (newValue) {
                        setState(() {
                          isLocationGranted = newValue;
                        });
                      });
                    },
                    activeTrackColor: const Color.fromARGB(255, 11, 243, 11),
                    activeColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  // Switch for Bluetooth permission
                  SwitchListTile(
                    tileColor: const Color.fromARGB(255, 241, 255, 241),
                    contentPadding: const EdgeInsets.only(left: 10, right: 10),
                    thumbIcon: thumbIcon,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    title: const Text("Bluetooth"),
                    value: isBluetoothGranted,
                    onChanged: (bool value) {
                      _requestPermission(Permission.bluetooth, value,
                          (newValue) {
                        setState(() {
                          isBluetoothGranted = newValue;
                        });
                      });
                    },
                    activeTrackColor: const Color.fromARGB(255, 11, 243, 11),
                    activeColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  // Switch for Nearby Devices permission
                  SwitchListTile(
                    tileColor: const Color.fromARGB(255, 241, 255, 241),
                    contentPadding: const EdgeInsets.only(left: 10, right: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    title: const Text("Nearby Devices"),
                    thumbIcon: thumbIcon,
                    value: isNearbyDevicesGranted,
                    onChanged: (bool value) {
                      _requestPermission(Permission.bluetoothAdvertise, value,
                          (newValue) {
                        setState(() {
                          isNearbyDevicesGranted = newValue;
                        });
                      });
                    },
                    activeTrackColor: const Color.fromARGB(255, 11, 243, 11),
                    activeColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 11, 243, 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                              builder: (context) => const localmatchLoader())
                          as Route<Object?>,
                    );
                  },
                  child: const Text('Load Match',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                      textAlign: TextAlign.center),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 11, 243, 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Hive.box('matchData').deleteAll;
                    Hive.box('pitData').delete('teams');
                  },
                  child: const Text('Reset Match',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Hive.box('userData').deleteAll;
                    Hive.box('matchData').deleteAll;
                    Hive.box('settings').deleteAll;
                    Hive.box('pitData').deleteAll;
                    LocalDataBase.clearData();
                    MatchLogs.clearLogs();
                  },
                  child: const Text('Delete Learnt Data',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                      textAlign: TextAlign.center),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

final WidgetStateProperty<Icon?> thumbIcon =
    WidgetStateProperty.resolveWith<Icon?>(
  (Set<WidgetState> states) {
    if (states.contains(WidgetState.selected)) {
      return const Icon(Icons.check);
    }
    return const Icon(Icons.close);
  },
);
