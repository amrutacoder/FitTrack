import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomNavBar({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: BottomNavClipper(),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.medical_services, 0),
                _navItem(Icons.water_drop, 1),
                SizedBox(width: 50), // Space for floating button
                _navItem(Icons.restaurant, 2),
                _navItem(Icons.calculate, 3),
              ],
            ),
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width / 2 - 30, // Center the floating button
          bottom: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.black,
            elevation: 4,
            child: Icon(Icons.home, color: Colors.white, size: 30),
            onPressed: () => onItemTapped(4),
          ),
        ),
      ],
    );
  }

  Widget _navItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Icon(
        icon,
        color: selectedIndex == index ? Colors.white : Colors.white70,
        size: 30,
      ),
    );
  }
}

class BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width * 0.4, 0);
    path.quadraticBezierTo(size.width * 0.5, 40, size.width * 0.6, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
