import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() =>  _HomePageState();
}

class  _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
      child:Column(
        children: [
          //app bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:25.0),
            child: Row
            (children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello,',
                  style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                  ),
                  
                  SizedBox(height:8)

                  Text(
                    'KavyaSri,',
                     style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              

              //profile picture
              Icon(Icons.person),
            ],
            ),
          ),

          //card--> how do u feel?

          //search bar

          //horizontal listview -> categories dentist,surgeon etc..

          //doctor list
        ],
      ),
      )
    );
  }
}