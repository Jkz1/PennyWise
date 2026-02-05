import 'package:flutter/material.dart';

class Glasstextfield extends StatefulWidget {
  IconData icon;
  String hint;
  bool isDarkMode;
  Color textColor;
  bool isPassword = false;
  TextEditingController? controller;
  Glasstextfield({
    super.key,
    required this.icon,
    required this.hint,
    required this.isDarkMode,
    required this.textColor,
    this.isPassword = false,
    required this.controller,
  });

  @override
  State<Glasstextfield> createState() => _GlasstextfieldState();
}

class _GlasstextfieldState extends State<Glasstextfield> {
  bool isObscured = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: TextField(
        obscureText: widget.isPassword && isObscured,
        style: TextStyle(color: widget.textColor),
        cursorColor: widget.textColor,
        controller: widget.controller,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon, color: widget.textColor.withOpacity(0.7), size: 22),
          // Suffix Icon logic for password
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    !isObscured ? Icons.visibility : Icons.visibility_off,
                    color: widget.textColor.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: (){
                    setState(() {
                      isObscured = !isObscured;
                    });
                  } ,
                )
              : null,
          hintText: widget.hint,
          hintStyle: TextStyle(color: widget.textColor.withOpacity(0.4)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );;
  }
}