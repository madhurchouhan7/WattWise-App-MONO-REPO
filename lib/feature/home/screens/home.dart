import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
// Import your theme

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0; // Tracks which tab is active

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fontSize = width / 60;
        return Scaffold(
          // 1. Top App Bar
          appBar: AppBar(
            // disable the default back button
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,",

                  style: GoogleFonts.poppins(
                    fontSize: fontSize * 2.2,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  "Madhur Chouhan",
                  style: GoogleFonts.poppins(
                    fontSize: fontSize * 3.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            actions: [
              CircleAvatar(
                
                radius: fontSize * 2.5,
                backgroundImage: const NetworkImage(
                  "https://avatars.githubusercontent.com/u/30585596?s=400&u=f003965be0a53be549780f833f556bed3a3e95b6&v=4",
                ),
              ),
              SizedBox(width: fontSize * 3),
            ],
          ),

          // 2. The Body (Just a placeholder for now)
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bolt, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  "Dashboard Content Goes Here",
                  style: GoogleFonts.poppins(
                    fontSize: fontSize * 2.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          bottomNavigationBar: SalomonBottomBar(
            margin: EdgeInsets.all(22),
            itemPadding: EdgeInsets.all(18),
            curve: Curves.easeInOut,
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.home_outlined),
                title: const Text("Home"),
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.insights_outlined),
                title: const Text("Insights"),
              ),

              SalomonBottomBarItem(
                icon: const Icon(Icons.receipt_long_rounded),
                title: const Text("Bills"),
              ),

              SalomonBottomBarItem(
                icon: const Icon(Icons.person_outline_rounded),
                title: const Text("Profile"),
              ),
            ],
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}
