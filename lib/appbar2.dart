import 'package:flutter/material.dart';
import 'dart:ui';

class CustomAppBar1 extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String name;

  CustomAppBar1({required this.title,required this.name});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: Text(
            "$name",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        Positioned(
          top: 50,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            child: Icon(Icons.person, color: Colors.blue.shade900),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(150);
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 4, size.height, size.width / 2, size.height - 30);
    path.quadraticBezierTo(size.width * 3 / 4, size.height - 60, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
