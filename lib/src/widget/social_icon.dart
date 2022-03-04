import 'package:flutter/material.dart';

class SocialIcon extends StatelessWidget {
  final List<Color> colors;
  final IconData icondata;
  final Function onPressed;

  SocialIcon({
    this.colors,
    this.icondata,
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 14.0),
      child: Container(
          width: MediaQuery.of(context).size.height* 0.06,
          height: MediaQuery.of(context).size.height* 0.06,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: colors,
              )
          ),
          child: RawMaterialButton(
              shape: CircleBorder(),
              onPressed: onPressed,
              child: Icon(icondata, color: Colors.white)
          )
      ),
    );
  }
}