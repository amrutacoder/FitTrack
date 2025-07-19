import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'appbar2.dart';

class RelaxationCountdownScreen extends StatefulWidget {
  @override
  _RelaxationCountdownScreenState createState() => _RelaxationCountdownScreenState();
}

class _RelaxationCountdownScreenState extends State<RelaxationCountdownScreen> {
  int selectedTime = 10;
  int remainingTime = 10;
  Timer? countdownTimer;
  bool isRunning = false;
  AudioPlayer audioPlayer = AudioPlayer();

  void startCountdown() async {
    setState(() {
      isRunning = true;
      remainingTime = selectedTime;
    });

    // Start playing the music when countdown begins
    playMusic();

    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
        setState(() {
          isRunning = false;
        });

        // Stop the music when countdown ends
        stopMusic();
      }
    });
  }


  void playMusic() async {
    print("Starting music...");
    try {
      await audioPlayer.play(AssetSource('relaxing_music.mp3'));
      print("Music is playing!");
    } catch (e) {
      print("Error playing music: $e");
    }
  }

  void stopMusic() async {
    print("Stopping music...");
    await audioPlayer.stop();
  }
  int _selectedIndex = 5;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on index
    // For example:
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
      // Navigate to Screen1
        Navigator.pushNamed(context, '/MRS');
        break;
      case 2:
      // Navigate to Screen2
        Navigator.pushNamed(context, '/BMI');
        break;
      case 3:
      // Navigate to Screen3
        Navigator.pushNamed(context, '/Diet');
        break;
      case 4:
      // Navigate to Screen4
        Navigator.pushNamed(context, '/water_intake');
        break;
      case 5:
      // Navigate to Screen4
        break;
    }
  }


  @override
  void dispose() {
    countdownTimer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomAppBar1(title: "Welcome",name:'Relaxation Countdown'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Select Relaxation Time",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _timeButton(10),
                _timeButton(15),
                _timeButton(20),
              ],
            ),
            SizedBox(height: 40),
            Text("$remainingTime sec",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isRunning ? null : startCountdown,
              child: Text("Start"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 40),
            if (!isRunning && remainingTime == 0)
              Column(
                children: [
                  Icon(Icons.spa, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text("Take a deep breath & relax!",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'BMI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Diet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'WaterIntake',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Relax',
          ),
        ],
      ),
    );
  }

  Widget _timeButton(int time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        onPressed: isRunning ? null : () {
          setState(() {
            selectedTime = time;
            remainingTime = time;
          });
        },
        child: Text("$time sec"),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedTime == time ? Colors.white : Colors.blue.shade900,
          foregroundColor: selectedTime == time ? Colors.black : Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
