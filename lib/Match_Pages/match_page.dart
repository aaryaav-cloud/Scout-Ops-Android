import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:scouting_app/components/MatchSelection.dart';
import 'package:scouting_app/components/ScoutersList.dart';
import 'package:scouting_app/home_page.dart';
import 'match.dart';
import '../services/DataBase.dart';
import 'package:material_symbols_icons/symbols.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  MatchPageState createState() => MatchPageState();
}

class MatchPageState extends State<MatchPage> {
  late int selectedMatchType;

  @override
  void initState() {
    super.initState();
    selectedMatchType = 0;
  }

  @override
  Widget build(BuildContext context) {
    var data = Hive.box('matchData').get('matches');
    if (data == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.red, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Match Scouting',
              style: GoogleFonts.museoModerno(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: Center(child: Text('No match data available.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () async {
              await Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                  fullscreenDialog: true,
                ),
                (Route<dynamic> route) => false,
              );

              print('Navigated back to MatchPage and removed previous pages.');
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.red, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
            child: Text(
              'Match Scouting',
              style: GoogleFonts.museoModerno(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            )),
        centerTitle: true,
      ),
      body: matchSelection(context, selectedMatchType, (int index) {
        setState(() {
          selectedMatchType = index;
        });
      }, jsonEncode(data)),
    );
  }

  Widget matchSelection(BuildContext context, int currentSelectedMatchType,
      Function onMatchTypeSelected, String matchData) {
    return Row(
      children: [
        NavigationRail(
          backgroundColor: Colors.white,
          selectedIndex: currentSelectedMatchType,
          onDestinationSelected: (int index) {
            onMatchTypeSelected(index);
          },
          labelType: NavigationRailLabelType.all,
          destinations: const <NavigationRailDestination>[
            NavigationRailDestination(
              indicatorColor: Colors.white,
              icon: Icon(Icons.sports_soccer),
              label: Text('Quals'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.sports_basketball),
              label: Text('Playoffs'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.sports_rugby),
              label: Text('Finals'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: _buildMatchList(currentSelectedMatchType, matchData),
        ),
      ],
    );
  }

  Widget _buildMatchList(int selectedMatchType, String matchData) {
    // Decode the JSON string to a Dart object
    List<dynamic> matches = jsonDecode(matchData);

    switch (selectedMatchType) {
      case 0:
        var filteredMatches = matches
            .where((match) => match['comp_level'] == 'qm')
            .toList()
          ..sort((a, b) => int.parse(a['match_number'].toString())
              .compareTo(int.parse(b['match_number'].toString())));

        return ListView.builder(
          itemCount: filteredMatches.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Container(
                width: double.infinity,
                height: 200,
                child: Card(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 6,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade300,
                          Colors.deepPurple.shade500
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Symbols.taunt, color: Colors.white, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'Every Second Insult - dont take it seriously',
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getRandomInsult(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            index -= 1;
            return ListTile(
              title: Text(
                  'Qualification ${filteredMatches[index]['match_number']}'),
              subtitle: const Text('Qualification Match'),
              leading: Icon(Icons.sports_soccer,
                  color: Theme.of(context).colorScheme.primary),
              trailing: Icon(Icons.arrow_forward_ios_rounded,
                  color: Theme.of(context).colorScheme.onSurface),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              onTap: () {
                // log(filteredMatches[index].toString());
                String _scouterName = Hive.box('settings').get('deviceName');
                String _allianceColor = Hive.box('userData').get('alliance');
                String _station = Hive.box('userData').get('position');
                String teamNNumber = filteredMatches[index]['alliances']
                        [_allianceColor.toLowerCase()]['team_keys']
                    [int.parse(_station) - 1];
                MatchRecord matchRecord = MatchRecord(
                  AutonPoints(0, 0, 0, 0, false, 0, 0,
                      BotLocation(Offset(100, 100), Size(200, 200), 0)),
                  TeleOpPoints(0, 0, 0, 0, 0, 0, 0, false),
                  EndPoints(false, false, false, ""),
                  teamNumber: teamNNumber.split(
                    'frc',
                  )[1],
                  scouterName: _scouterName,
                  matchKey: filteredMatches[index]['key'].toString(),
                  allianceColor: _allianceColor,
                  station: int.parse(_station),
                  matchNumber: filteredMatches[index]['set_number'],
                  eventKey: filteredMatches[index]['event_key'],
                );
                // print(filteredMatches[index]['match_number']);
                // (matchRecord.toString());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Match(
                            matchRecord: matchRecord,
                          ),
                      fullscreenDialog: true),
                ).then((value) => print('Returned to Match Page'));
              },
            );
          },
        );

      case 1:
        var filteredMatches =
            matches.where((match) => match['comp_level'] == 'sf').toList()
              ..sort((a, b) {
                int aValue = a['comp_level'].startsWith('sf')
                    ? int.parse(a['set_number'].toString())
                    : int.parse(a['match_number'].toString());
                int bValue = b['comp_level'].startsWith('sf')
                    ? int.parse(b['set_number'].toString())
                    : int.parse(b['match_number'].toString());
                return aValue.compareTo(bValue);
              });

        return ListView.builder(
          itemCount: filteredMatches.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Container(
                width: double.infinity,
                height: 200,
                child: Card(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 6,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade300,
                          Colors.deepPurple.shade500
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Symbols.taunt, color: Colors.white, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'Every Second Insult - dont take it seriously',
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getRandomInsult(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            index -= 1;
            return ListTile(
              title: Text(
                'Match ${filteredMatches[index]['comp_level'].startsWith('sf') ? filteredMatches[index]['set_number'] : filteredMatches[index]['match_number']}',
              ),
              subtitle: const Text('Semifinal Match'),
              leading: Icon(Icons.sports_basketball,
                  color: Theme.of(context).colorScheme.primary),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurface),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              onTap: () {
                // log(filteredMatches[index].toString());
                String _scouterName = Hive.box('settings').get('deviceName');
                String _allianceColor = Hive.box('userData').get('alliance');
                String _station = Hive.box('userData').get('position');
                String teamNNumber = filteredMatches[index]['alliances']
                        [_allianceColor.toLowerCase()]['team_keys']
                    [int.parse(_station)];
                MatchRecord matchRecord = MatchRecord(
                  AutonPoints(0, 0, 0, 0, false, 0, 0,
                      BotLocation(Offset.zero, Size.zero, 0)),
                  TeleOpPoints(0, 0, 0, 0, 0, 0, 0, false),
                  EndPoints(false, false, false, ""),
                  teamNumber: teamNNumber.split(
                    'frc',
                  )[1],
                  scouterName: _scouterName,
                  matchKey: filteredMatches[index]['key'].toString(),
                  allianceColor: _allianceColor,
                  station: int.parse(_station),
                  matchNumber: filteredMatches[index]['set_number'],
                  eventKey: filteredMatches[index]['event_key'],
                );
                print(filteredMatches[index]['set_number']);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Match(
                            matchRecord: matchRecord,
                          ),
                      fullscreenDialog: true),
                ).then((value) => print('Returned to Match Page'));
              },
            );
          },
        );

      case 2:
        var filteredMatches = matches
            .where((match) => match['comp_level'] == 'f')
            .toList()
          ..sort((a, b) => int.parse(a['match_number'].toString())
              .compareTo(int.parse(b['match_number'].toString())));

        return ListView.builder(
          itemCount: filteredMatches.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Container(
                width: double.infinity,
                height: 200,
                child: Card(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 6,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade300,
                          Colors.deepPurple.shade500
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Symbols.taunt, color: Colors.white, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'Every Second Insult - dont take it seriously',
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getRandomInsult(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            index -= 1;
            return ListTile(
              title: Text('Match ${filteredMatches[index]['match_number']}'),
              subtitle: const Text('Final Match'),
              leading: Icon(Icons.sports_rugby,
                  color: Theme.of(context).colorScheme.primary),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurface),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              onTap: () {
                // log(filteredMatches[index].toString());
                String _scouterName = Hive.box('settings').get('deviceName');
                String _allianceColor = Hive.box('userData').get('alliance');
                String _station = Hive.box('userData').get('position');
                String teamNNumber = filteredMatches[index]['alliances']
                        [_allianceColor.toLowerCase()]['team_keys']
                    [int.parse(_station)];
                MatchRecord matchRecord = MatchRecord(
                  AutonPoints(0, 0, 0, 0, false, 0, 0,
                      BotLocation(Offset.zero, Size.zero, 0)),
                  TeleOpPoints(0, 0, 0, 0, 0, 0, 0, false),
                  EndPoints(false, false, false, ""),
                  teamNumber: teamNNumber.split(
                    'frc',
                  )[1],
                  scouterName: _scouterName,
                  matchKey: filteredMatches[index]['key'].toString(),
                  allianceColor: _allianceColor,
                  station: int.parse(_station),
                  matchNumber: filteredMatches[index]['set_number'],
                  eventKey: filteredMatches[index]['event_key'],
                );
                // log(matchRecord.toString());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Match(
                            matchRecord: matchRecord,
                          ),
                      fullscreenDialog: true),
                ).then((value) => print('Returned to Match Page'));
              },
            );
          },
        );

      case 3:
        // Decode match data to extract statistics
        List<dynamic> allMatches = jsonDecode(matchData);
        int totalMatches = allMatches.length;
        int qualMatches =
            allMatches.where((m) => m['comp_level'] == 'qm').length;
        int playoffMatches =
            allMatches.where((m) => m['comp_level'] == 'sf').length;
        int finalMatches =
            allMatches.where((m) => m['comp_level'] == 'f').length;

        // Extract event information
        String eventKey =
            allMatches.isNotEmpty ? allMatches[0]['event_key'] : 'Unknown';
        String eventName = _formatEventName(eventKey);
        String eventYear = eventKey.substring(0, 4);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ScouterList(),
              // Event Information Card
              Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 8,
                shadowColor: Colors.blueAccent.withOpacity(0.3),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.7),
                        Colors.indigoAccent.withOpacity(0.8)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emoji_events,
                              color: Colors.white, size: 26),
                          const SizedBox(width: 12),
                          Text(
                            'Competition',
                            style: GoogleFonts.museoModerno(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        eventName,
                        style: GoogleFonts.museoModerno(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$eventYear Season',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Match Statistics Card
              Card(
                color: Colors.white,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'Match Statistics',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStatisticRow(
                          context,
                          Icons.sports_score,
                          'Total Matches',
                          totalMatches.toString(),
                          Colors.blue.shade800),
                      const SizedBox(height: 12),
                      _buildStatisticRow(
                          context,
                          Icons.sports_soccer,
                          'Qualification Matches',
                          qualMatches.toString(),
                          Colors.green.shade700),
                      const SizedBox(height: 12),
                      _buildStatisticRow(
                          context,
                          Icons.sports_basketball,
                          'Playoff Matches',
                          playoffMatches.toString(),
                          Colors.orange.shade700),
                      const SizedBox(height: 12),
                      _buildStatisticRow(
                          context,
                          Icons.sports_rugby,
                          'Final Matches',
                          finalMatches.toString(),
                          Colors.red.shade700),
                    ],
                  ),
                ),
              ),

              // Scouter Configuration
              Card(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                color: const Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'Scouter Profile',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2),
                            radius: 36,
                            child: Text(
                              _getInitials(Hive.box('settings')
                                  .get('deviceName', defaultValue: 'Scout')),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Hive.box('settings').get('deviceName') ??
                                      'Unknown Scout',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        Hive.box('userData').get('alliance') ==
                                                'Red'
                                            ? Colors.red.withOpacity(0.2)
                                            : Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${Hive.box('userData').get('alliance', defaultValue: 'Red')} Alliance - Position ${Hive.box('userData').get('position', defaultValue: '1')}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Hive.box('userData')
                                                  .get('alliance') ==
                                              'Red'
                                          ? Colors.red.shade700
                                          : Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MatchSelection(
                          onAllianceSelected: (String? alliance) {
                            setState(() {
                              Hive.box('userData').put('alliance', alliance);
                            });
                          },
                          onPositionSelected: (String? position) {
                            setState(() {
                              Hive.box('userData').put('position', position);
                            });
                          },
                          initAlliance: Hive.box('userData')
                              .get('alliance', defaultValue: "Red"),
                          initPosition: Hive.box('userData')
                              .get('position', defaultValue: '1')),
                    ],
                  ),
                ),
              ),

              // Tips or Fun Facts
              Card(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 6,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade300,
                        Colors.deepPurple.shade500
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: Colors.white, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'Scouting Tip',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getRandomScoutingTip(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return const Center(child: Text('Unknown Match Type'));
    }
  }

// Helper method to format event name
  String _formatEventName(String eventKey) {
    // Extract event code (e.g., "2024nyro" becomes "NYRO")
    String eventCode = eventKey.substring(4);

    // Convert to proper format
    Map<String, String> eventNames = {
      // Michigan District Events
      "miket": "Kettering University District",
      "micen": "Center Line District",
      "misjo": "St. Joseph District",
      "mitvc": "Traverse City District",
      "miwat": "Waterford District",
      "mitry": "Troy District",
      "milak": "Lakeview District",
      "miken": "East Kentwood District",
      "miliv": "Livonia District",
      "mimas": "Mason District",
      "mialp": "Alpena District",
      "mimid": "Midland District",
      "mimon": "Monroe District",
      "mimil": "Milford District",
      "misou": "Southfield District",
      "miann": "Ann Arbor District",
      "mijac": "Jackson District",
      "miwoo": "Woodhaven District",
      "mimac": "Macomb District",
      "mibel": "Belleville District",
      "misag": "Saginaw Valley District",
      "migib": "Gibraltar District",
      "migul": "Gull Lake District",
      "mical": "Calvin District",
      "miesc": "Escanaba District",
      "mifor": "Fordson District",
      "mibri": "Brighton District",
      "mimtp": "Mt. Pleasant District", // Added Mt. Pleasant
      "mipla": "Placeholder District",

      // Michigan State Championship
      "micmp": "Michigan State Championship",
      "micha": "Michigan State Championship",

      // Other popular events Michigan teams might attend
      "chs": "Chesapeake District Championship",
      "ont": "Ontario Provincial Championship",
      "in": "Indiana State Championship",
      "oh": "Ohio State Championship",
      "first": "FIRST Championship",
      "arc": "Archimedes Division",
      "car": "Carson Division",
      "cur": "Curie Division",
      "dal": "Daly Division",
      "dar": "Darwin Division",
      "gal": "Galileo Division",
      "hop": "Hopper Division",
      "new": "Newton Division",
      "roe": "Roebling Division",
      "tur": "Turing Division",
      "cmptx": "FIRST Championship - Houston",
      "cmpmi": "FIRST Championship - Detroit",

      // Add more event codes and names as needed
      "isde": "Isreal District Event",
      "isdc": "Isreal District Championship",
      "isw": "Isreal World Championship",
    };

    return eventNames[eventCode] ?? "Event ${eventCode.toUpperCase()}";
  }

// Helper method to build statistic row
  Widget _buildStatisticRow(BuildContext context, IconData icon, String label,
      String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

// Helper method to get initials from name
  String _getInitials(String name) {
    if (name.isEmpty) return "Ri";

    List<String> nameParts = name.split(" ");
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

// Helper method to get random scouting tip
// Helper method to get random scouting tip
  String _getRandomScoutingTip() {
    List<String> tips = [
      "Focus on one robot at a time to get accurate data.",
      "Note unusual strategies that might affect alliance selection.",
      "Watch for consistent performance rather than best/worst matches.",
      "Pay attention to robot speed and maneuverability during matches.",
      "Defense capability can be just as valuable as scoring ability.",
      "Track cycle times for repetitive actions to gauge efficiency.",
      "Note any technical issues that might indicate reliability problems.",
      "Watch for effective communication between alliance partners.",
      "Be aware of the field layout and how it affects robot movement.",
      "Take note of any unique features or strategies used by teams.",
      "Scouting is only as hard as you make it. You can always give up. 😁",
      "Data drives decisions—scout smart, strategize smarter.",
      "Scouting isn't just collecting numbers; it's unlocking victories.",
      "Great teams don't guess—they scout.",
      "Every match tells a story. It's your job to read it.",
      "Championships are built on good scouting.",
      "Scouting today wins matches tomorrow.",
      "Your data is your weapon—use it wisely.",
      "Precision in scouting leads to domination on the field.",
      "The best alliances are chosen, not given.",
      "To defeat the ops, you must scout them using Scout Ops.",
      "Numbers don't lie—trust the data, trust the process.",
      "If this app breaks, it's your fault not ours",
      "Agents, remember a goup of spies is always better then a hivemind",
      "Every match you scout is a step closer to seeing your strategy come to life.",
      "The robots may be on the field, but the future is in your notes.",
      "A great match starts with great data; your observations lay the foundation for victory.",
      "The more you know, the better you grow. Scout with precision, compete with confidence.",
      "Behind every winning strategy is a team that never stopped analyzing.",
      "Scouting isn’t just about watching robots, it’s about understanding the rhythm of the game.",
      "Success in FRC is built on the small moments captured in your scouting sheets.",
      "In scouting, every detail matters — it’s the difference between a good match and a great one.",
      "When you see the game clearly, you can outthink the competition.",
      "Scouting is the quiet hero of every FRC match — it's the knowledge that wins the battle.",
      "Every match you scout is a step closer to seeing your strategy come to life.",
      "The robots may be on the field, but the future is in your notes.",
      "A great match starts with great data; your observations lay the foundation for victory.",
      "The more you know, the better you grow. Scout with precision, compete with confidence.",
      "Behind every winning strategy is a team that never stopped analyzing.",
      "Scouting isn’t just about watching robots, it’s about understanding the rhythm of the game.",
      "Success in FRC is built on the small moments captured in your scouting sheets.",
      "In scouting, every detail matters — it’s the difference between a good match and a great one.",
      "When you see the game clearly, you can outthink the competition.",
      "Scouting is the quiet hero of every FRC match — it's the knowledge that wins the battle.",
      "Follow our lord and savior, Ritesh Raj, for a scouting advantage",
      "Just like the beat of Dandanakka, Ritesh Raj Arul Selvan’s app brings the rhythm to your scouting, making every match easier to analyze and every strategy stronger!",
      "In the rhythm of scouting, we don’t just follow the beat; we create it—just like Dandanakka!",
      "Just like Dandanakka’s catchy beat, every piece of scouting data adds to the flow that leads to victory!",
      "When the competition feels overwhelming, remember: keep the tempo steady, just like Dandanakka, and success will follow.",
      "Every match you scout adds a layer to your strategy, just like the layers of rhythm in Dandanakka—steady, strong, and unstoppable.",
      "Just as Dandanakka captures your attention, the details in every match you scout will grab your team's focus and lead them to greatness.",
      "Keep your scouting as sharp as Dandanakka’s beat, and you’ll compose a strategy that moves with power and precision!",
      "In the Reefscape, your scouting knowledge is the bassline that keeps the strategy in sync, just like Dandanakka keeps the crowd moving.",
      "Like the infectious groove of Dandanakka, your scouting energy fuels the team's drive to perform with confidence.",
      "As Dandanakka's rhythm builds to a crescendo, your insights will shape a strategy that rises above the competition.",
      "The best teams in Reefscape move with precision—just like the rhythm of Dandanakka, they know when to strike and when to adapt.",
      "In the Reefscape, every team is a unique species—scouting helps you understand their strengths and weaknesses.",
      "Scouting is like mapping the ocean’s currents; the more you understand, the smoother your journey to victory.",
      "A healthy reef thrives on diversity—your scouting insights bring together the unique strengths of every team.",
      "In the depths of competition, your scouting knowledge is the lighthouse guiding your team toward success.",
      "Just as a reef is built by countless tiny pieces, a winning strategy is formed from the details you discover through scouting.",
      "Like coral in a reef, each match provides another layer of insight to strengthen your team's foundation.",
      "Dive deep into the data—every match is an opportunity to uncover the hidden treasures of strategy.",
      "In the Reefscape, the best teams don’t just survive—they adapt and thrive by learning from every match.",
      "The ocean of competition is vast, but your scouting maps the best path to victory.",
    ];

    return tips[DateTime.now().microsecond % tips.length];
  }

  String _getRandomInsult() {
    List<String> insults = [
      // memes:
      //Timothy
      "Timothy, oh Timothy,Tripped on a rock and lost his tea!(Now he's just mothy, sipping air instead of coffee.) ",
      "Timothy, the gym is free But he’d rather nap under a tree. (Workout? Nah. Dreaming of snacks instead.)",
      "Timothy, the symphony, Played his trumpet in disharmony. (They said stop, but he played non-stop.) ",
      "Timothy, full of energy, Tripped and spilled his cup of tea. (Now he’s just Tim-oh-pee, sad and tea-free.) ",
      "Timothy, the referee, Accidentally called a foul on a tree (The tree protested, but Tim stood firmly.) ",
// SPREAD SHEETS SPREADSHEETS SPREADSHEETS
// Bring back the buzz
// Shorty king
// Do you need someone to reach the top shelf
// Lock-in...

      //Sukhesh
      "Sukhesh, oh Sukhesh,Thinks he’s cool, but he's just a mess.(Tripped on air, spilled his drink—now he’s drenched, no less! )",
      "Sukhesh tried to flex his cash,Turns out it's all just fake mustache.(Big talk, small wallet—living life on borrowed stash. )",
      "Sukhesh says he’s fast and fresh,But even a turtle makes him stress.(Slow-motion legend, breaking records in reverse. )",
      "Sukhesh thinks he's got that drip,But his style looks like a garage sale flip.(Mismatched socks and a shirt that rips—fashion police, please assist! )",
      "Sukhesh, the king of trash talk,But runs away when it’s time to walk.",

      //Adit
      "Adit, oh Adit, Hit his head on a door—just a bit!(Now he ducks, but still gets stuck.)",
      "Adit, the Aussie lad, Tried to surf but wiped out bad.(Water said nope, and down he sloped.)",
      "Adit, so very tall,Bumped the fan and broke the wall. (His height’s a gift… until ceilings exist.)",
      "Adit, the BBQ king,  Burnt the snags and lost his zing. (Flames went high, now sausages fly.)",

      //ritesh
      "Ritesh, oh Ritesh, he thinks he's Rizztesh but he's Ritech",

      //clifford
      "Clifford, eyes open wide,Typing fast with zero pride. (Sleep is a myth, just one more line… or fifth.)"

          //Avanti
          "Avanti, Asked for water, got ‘wa’er’ instead.(British depression and vowels got harmed.)"

          //Rishi

          "Rishi, always on the go, Writes one line, then says ‘Uh-oh.’ (Fixes none, but claims he’s done.)",

      //Nisha
      "Nisha Misha Dish Pisha Gisha Jisha Yisha Risha Bisa"

          //Sacheth
          "Sacheth’s mustache is so peachy, even peaches are filing a copyright claim.",
      "His hair is so greasy, McDonald's is trying to use it for frying fries.",
      "Every time Sacheth laughs, dolphins in the ocean get confused and start looking for their lost cousin.",
      "If oil prices keep rising, Sacheth’s scalp might become the next major fuel source.",
      "NASA picked up Sacheth’s laugh on their radio signals and thought they discovered an alien species.",
      "Even his mustache is trying to leave his face—it’s just too embarrassed to be there.",
      "His hair is like his future—stuck, messy, and in desperate need of a wash.",

      //Shree k
      "Shree spends more time in Brawl Stars than in real life—someone tell him his social skills need a respawn!",
      "If Shree’s mustache had a job, it’d be the mascot for every corny joke on the internet.",
      "He thinks he’s a Brawl Stars pro, but the only thing he’s good at is getting bullied in every match.",
      "Shree plays Brawl Stars like he’s on a 5-year-old's account—never gets any better, always stuck in low ranks.",
      "When Shree joins a Brawl Stars match, it’s like an instant 2v3—his teammates just pray he doesn’t feed the enemy team.",
      "Shree’s tactics are like his hair—completely unorganized and all over the place.",
      "Shree’s strategy with Kenji is simple—run in, miss every attack, then get eliminated while trying to look cool. ",
      "Kenji might be a fighter, but Shree’s gameplay makes him look like a punching bag.",

      //akilan
      "Akilan’s snacks are more valuable to him than his friendships—don’t even think about asking for one, or he’ll act like you’re asking for his last breath. ",
      "Akilan kicks balls in his sleep, but he can’t seem to manage a simple task while he’s awake.",
      "His MacBook's battery life is better than his ability to keep it from crashing every five minutes.",
      "Akilan’s sleep kicks are like his mind—chaotic, unpredictable, and always causing a bit of trouble.",
      "Akilan’s got so much energy, he’s like a high-voltage cable—constantly sparking, but never quite landing anywhere.",

      //ikshita
      "She plays tennis like she’s in slow motion, and plays violin like she’s trying to break every string on purpose.",
      "Ikshita might be short, but her ego’s about 10 feet tall—too bad she can’t see over it. ",
      "Ikshita’s tennis game is so weak, even the ball’s trying to avoid her racket.",
      "She’s so short, when she plays tennis, she’s practically under the net instead of over it.",

      //rishi
      "Rishi’s idea of making a move is sending a ceiling snap instead of actually talking to his crush.",
      "He’s got the lowest ego—so low, even his self-esteem needs a ladder to reach ground level.",
      "He leaves meetings early like he's got somewhere important to be... but we all know he’s just avoiding doing any work.",
      "Rishi’s programming knowledge is like a work in progress—he’s getting there, just needs a bit more time.",

      //laney
      "Laney’s so short, she needs a step stool just to reach her Starbucks order.",
      "She’s obsessed with Starbucks, but I’m pretty sure her cats are the ones actually managing the resources in that mobile game. ",
      "Laney spent money on a mobile game about cats—guess the game’s the only thing getting the ‘purr-fect’ treatment.",
      "Laney’s idea of a balanced diet is a tall latte in one hand and her phone in the other, tracking her Starbucks rewards.",
      "Laney’s jokes are like her phone battery—always dying at the worst moments.",

      //clifford
      "He can program robots, but can’t seem to program himself to remember where he put his water bottle.",
      "He’s always acting like he’s got all the answers, but couldn’t even figure out where his water bottle was in the shop.",
      "Clifford’s idea of exercising is lifting his gaming console to the couch.",
      "Clifford might be obsessed with Rock Band, but Clifford the Big Red Dog could probably rock a real guitar better than he can.",
      "Clifford the Big Red Dog has tons of friends because he’s a big, friendly dog—Clifford here has his Rock Band skills, but not much else to bring to the table.",

      //gunhong
      "Gunhong loves trash talking so much, he probably talks more than he swims—though, I’m sure he’s good at both. ",
      "Gunhong’s dedication to swimming is impressive, but he’s even more dedicated to making everyone feel bad with his trash talk. ",
      "Gunhong eats 1 dog every meal? At this point, he’s probably part of a dog’s worst nightmare.",
      "He’s dedicated to swimming, but I think the only thing he’s really good at floating is his ego.",
      "He doesn’t care about anything, except maybe finishing his dog every meal. G-money’s a man of simple tastes.",

      //avanti
      "She’s always skipping meetings but wants to be a doctor—good luck diagnosing anything when you can’t even diagnose a meeting on your calendar. ",
      "Avanti’s British accent might sound like she knows what she’s talking about, but her ability to show up to meetings says otherwise.",
      "Avanti’s always skipping meetings, but at least she’s got the British accent to make it sound like she’s doing something important. ",
      "Her British accent makes everything sound smarter, but it’s hard to take her seriously when she’s never around for the important stuff. ",
      "Avanti and Gunhong argue more than they actually get anything done—at this point, they should just start a podcast about their beef. ",
      "The only thing more consistent than Avanti skipping meetings is her ongoing beef with Gunhong.",

      //shreevaishnavi
      "Shreevaishnavi wants to be a doctor but spends more time diagnosing which Starbucks drink to get.",
      "Shreevaishnavi’s love for Starbucks is so strong, I’m starting to think her future diagnosis will be 'Addicted to caffeine.'",
      "She buys a drink, sips a little, and tosses it—looks like Starbucks is just an accessory to her, not a necessity.",
      "She’s got the Starbucks addiction, but at least she doesn’t have to finish the drink—because why waste a full cup when you can just waste a few sips? ",
      "Shreevaishnavi’s weird accent shows up like an unexpected plot twist—you never know when it’s coming, but it always leaves you confused",

      //ritesh
      "Ritesh might be programming in his free time, but in class, he’s more of an expert at snoozing than coding.",
      "Ritesh’s girlfriend is AI, but I think he’s the one who needs an upgrade—especially during class when he’s asleep instead of paying attention.",
      "Ritesh says something bad, then immediately takes it back—guess he’s still learning how to program his mouth to stop talking",
      "He sleeps through school, works at night, and lives on coffee—Ritesh is proving that ‘living the dream’ is just an endless loop of caffeine and code.",
      "Ritesh trades sleep for work at night—he’s out here living the ‘sleep is optional’ life, but coffee is mandatory. ",

      //andrew salmopnson
    ];
    return insults[DateTime.now().microsecond % insults.length];
  }
}
