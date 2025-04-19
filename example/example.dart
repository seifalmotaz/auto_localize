import 'package:flutter/material.dart';

class DemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, User!"),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text("Login"),
              onPressed: () {},
            ),
            TextButton(
              child: Text("Forgot Password?"),
              onPressed: () {},
            ),
            ElevatedButton(
              child: Text("Sign Up"),
              onPressed: () {},
            ),
            Row(
              children: [
                Icon(Icons.info),
                Text("Need Help? Contact support."),
              ],
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                text: "Terms and Conditions apply.",
              ),
            ),
            Text("Thank you for using our app."),
            Text("Please update to the latest version."),
            Text("This feature is not available."),
            Text("Settings"),
            Text("Logout"),
          ],
        ),
      ),
    );
  }
}
