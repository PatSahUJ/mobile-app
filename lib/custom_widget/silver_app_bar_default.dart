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
      expandedHeight: MediaQuery.of(context).size.width * 0.18,
      flexibleSpace: Stack(
        children: [
          Positioned(
              top: MediaQuery.of(context).size.height * 0.025,
              right: 10,
              child: Row(
                children: [
                  const SizedBox(
                    height: 20,
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
              top: MediaQuery.of(context).size.height * 0.1,
              child: Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(79, 66, 66, 66),
                        blurRadius: 9,
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
