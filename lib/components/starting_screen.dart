import 'package:flutter/material.dart';
//import 'package:webview_flutter/webview_flutter.dart';
import 'package:mseva/utils/web_view_body_load.dart';

class StartingScreen extends StatelessWidget {
  const StartingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/mSeva.jpg'),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
              const Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: const Text(
                    'Welcome to mSeva app',
                    style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold), // Adjust the style as needed
                  ),
               ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                  Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => 
      const SafeArea(
        child: WebViewBodyLoad(
          pageTitle: 'mSeva',
          pageUrl: 'https://mseva.lgpunjab.gov.in/citizen/language-selection',
          headerFooterRequired: false,
        ),
      )),
    );
            },
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                      // shadowColor: Colors.blueAccent,
                      elevation: 5, 
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      ),
                     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                     ),
                      child: const Text(
                      'Citizen',
                      style: TextStyle(
                      fontSize: 18, // Font size
                      fontWeight: FontWeight.bold, // Font weight
    ),
  ),
),

                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => 
                          const SafeArea(
                            child: WebViewBodyLoad(
                              pageTitle: 'mSeva',
                              pageUrl: 'https://mseva.lgpunjab.gov.in/employee/language-selection',
                              headerFooterRequired: false,
                            ),
                          )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                      // shadowColor: Colors.blueAccent,
                      elevation: 5, 
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      ),
                     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                     ),
                      child: const Text('Employee', style: TextStyle(
                      fontSize: 18, // Font size
                      fontWeight: FontWeight.bold, // Font weight
    ),),
                    ),
                  ],
                ),
                const SizedBox(height: 20), 
              ],
            ),
          ),
        ],
      ),
    );
  }
}

