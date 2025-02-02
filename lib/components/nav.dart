import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scouting_app/Experiment/experiment.dart';
import 'package:scouting_app/main.dart';

import '../Match_Pages/about_page.dart';
import '../Match_Pages/logs.dart';
import '../Match_Pages/match_page.dart';
import '../settings_page.dart';
import '../home_page.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: isdarkmode() ? Colors.white : Colors.black,
      width: MediaQuery.of(context).size.width *
          1, // Drawer width is 60% of the screen width
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.grey, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              // This makes the width of the header fill the drawer
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white30, // Red avatar background
                    radius: 30,
                    child: Image(
                        image: AssetImage('assets/logo.png'),
                        height: 50,
                        width: 50,
                        fit: BoxFit.fill),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FEDS 201',
                    style: GoogleFonts.museoModerno(
                      fontSize: 24,
                      color: isdarkmode()
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : invertColor(
                              const Color.fromARGB(255, 255, 255, 255)),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scout Ops v.1.5',
                    style: GoogleFonts.museoModerno(
                      fontSize: 14,
                      color: isdarkmode()
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : invertColor(
                              const Color.fromARGB(255, 255, 255, 255)),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.home_outlined,
                  title: 'Home',
                  page: const HomePage(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.sports_score_outlined,
                  title: 'Match',
                  page: const MatchPage(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.list_alt_outlined,
                  title: 'Logs',
                  page: const LogsPage(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  page: const SettingsPage(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  page: const AboutPage(),
                ),
              ],
            ),
          ),
          _buildNavItem(context,
              icon: Icons.science_outlined,
              title: 'Experimental',
              page: const Experiment()),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context,
      {required IconData icon, required String title, required Widget page}) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      leading: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Colors.red, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
      title: Text(
        title,
        style: GoogleFonts.museoModerno(
          fontSize: 18,
          color: !isdarkmode()
              ? const Color.fromARGB(255, 255, 255, 255)
              : invertColor(const Color.fromARGB(255, 255, 255, 255)),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
