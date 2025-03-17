import 'package:flutter/material.dart';
import 'package:scouting_app/components/CheckBox.dart';
import 'package:scouting_app/components/QrGenerator.dart';
import '../../components/slider.dart';
import '../../services/DataBase.dart';

class EndGame extends StatefulWidget {
  final MatchRecord matchRecord;
  const EndGame({super.key, required this.matchRecord});

  @override
  EndGameState createState() => EndGameState();
}

class EndGameState extends State<EndGame> {
  late bool deep_climb;
  late bool shallow_climb;
  late bool park;

  late EndPoints endPoints;

  late String assignedTeam;
  late int assignedStation;
  late String matchKey;
  late String allianceColor;
  late int matchNumber;

  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    assignedTeam = widget.matchRecord.teamNumber;
    assignedStation = widget.matchRecord.station;
    matchKey = widget.matchRecord.matchKey;
    allianceColor = widget.matchRecord.allianceColor;

    // Load values from endPoints
    deep_climb = widget.matchRecord.endPoints.Deep_Climb;
    shallow_climb = widget.matchRecord.endPoints.Shallow_Climb;
    park = widget.matchRecord.endPoints.Park;
    commentController.text = widget.matchRecord.endPoints.Comments;

    endPoints =
        EndPoints(deep_climb, shallow_climb, park, commentController.text);
  }

  void UpdateData() {
    endPoints =
        EndPoints(deep_climb, shallow_climb, park, commentController.text);
    widget.matchRecord.endPoints.Deep_Climb = deep_climb;
    widget.matchRecord.endPoints.Shallow_Climb = shallow_climb;
    widget.matchRecord.endPoints.Park = park;
    widget.matchRecord.endPoints.Comments = commentController.text;
    widget.matchRecord.endPoints = endPoints;

    saveState();
  }

  void saveState() {
    LocalDataBase.putData('endPoints', endPoints.toJson());
    // log('EndGame state saved: $endPoints');
  }

  @override
  void dispose() {
    // Make sure data is saved when navigating away
    UpdateData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(LocalDataBase.getData('Settings.apiKey'));
    // print(endPoints.Comments);
    return SingleChildScrollView(
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              buildCheckBox("Deep Climb", deep_climb, (bool value) {
                setState(() {
                  deep_climb = value;
                });
              }),
              buildCheckBox("Shallow Climb", shallow_climb, (bool value) {
                setState(() {
                  shallow_climb = value;
                });
              }),
            ]),
          ),
          buildCheckBoxFull("Parked", park, (bool value) {
            // changed 'parked' to 'park'
            setState(() {
              park = value; // changed 'parked' to 'park'
            });
          }),
          const SizedBox(height: 6),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color.fromARGB(255, 255, 255, 255),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        color: Colors.blueAccent,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Comments",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: TextField(
                    controller: commentController,
                    maxLines: 4,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                      hintText:
                          'Add any relevant notes about the team\'s performance...',
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 15),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: MediaQuery.of(context).size.width - 16,
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
                  buttonColor: Colors.yellow,
                  backgroundColor: Colors.white,
                  highlightedColor: Colors.green,
                  dismissThresholds: 0.97,
                  vibrationFlag: true,
                  width: MediaQuery.of(context).size.width - 16,
                  action: () async {
                    UpdateData();
                    MatchDataBase.PutData(
                        widget.matchRecord.matchKey, widget.matchRecord);
                    MatchDataBase.SaveAll();
                    MatchDataBase.PrintAll();
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Qrgenerator(matchRecord: widget.matchRecord),
                            fullscreenDialog: true));
                    return null;
                  },
                  label: const Text("Slide to Complete Event",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 17),
                      textAlign: TextAlign.start),
                  icon: const Icon(Icons.send_outlined,
                      size: 30, color: Colors.black),
                )),
          ),
        ],
      ),
    );
  }
}
