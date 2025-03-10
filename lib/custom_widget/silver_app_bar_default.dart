import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SilverAppBarDefault extends StatelessWidget {
  const SilverAppBarDefault({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      pinned: true,
      floating: true,
      centerTitle: false,
      stretch: false,
      automaticallyImplyLeading: false,
      expandedHeight: 50,
      flexibleSpace: Stack(
        children: [
          Positioned(
              top: MediaQuery.of(context).size.height * 0.02,
              right: 10,
              child: Row(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  IconButton(
                    icon: Image.asset('asset/icons/loupe.png', width: 40),
                    onPressed: () {
                      // Define the action when search icon is pressed
                    },
                  ),
                  IconButton(
                    alignment: Alignment.center,
                    icon: Image.asset('asset/icons/setting.png', width: 50),
                    onPressed: () {
                      Navigator.pushNamed(context, '/setting');
                    },
                  ),
                ],
              )),
          Positioned.fill(
              top: MediaQuery.of(context).size.height * 0.09,
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(79, 66, 66, 66),
                        blurRadius: 5,
                        spreadRadius: -2,
                        offset: Offset(0.0, -12.0),
                      )
                    ]),
              ))
        ],
      ),
      //actions: <Widget>[],
    );
  }
}
