import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// local references
import '../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../Signup/signup_screen.dart';
import '../../Home/home_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LogInState();
}

class _LogInState extends State<LoginForm> {
  String email = "", password = "";

  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  userLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    } 
    on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No User Found for that Email",
              style: TextStyle(fontSize: 18.0),
            )));
      } 
      else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Wrong Password Provided by User",
              style: TextStyle(fontSize: 18.0),
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Column(
        children: 
        [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: pad_small),
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please Enter E-mail';
                return null;
              },
              controller: mailcontroller,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              onSaved: (email) {},
              
              decoration: const InputDecoration(
                hintText: "Your email",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(pad_norm),
                  child: Icon(Icons.person),
                ),
              ),

            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: pad_small),
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please Enter Password';
                return null;
              },
              controller: passwordcontroller,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              
              decoration: const InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(pad_norm),
                  child: Icon(Icons.lock),
                ),
              ),

            ),
          ),
          
          const SizedBox(height: pad_norm),
          ElevatedButton(
            onPressed: () // add functionality to log in
            {
              if (_formkey.currentState!.validate()) {
                setState(() {
                  email = mailcontroller.text;
                  password = passwordcontroller.text;
                });
              }
              userLogin();
            },
            child: Text("Login".toUpperCase(),),
          ),
          const SizedBox(height: pad_tiny),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: pad_tiny),
            child: GestureDetector(
              onTap: () {}, // add functionaltiy to request reset password
              child: 
                const Text( " Forgot Password ? ",
                  style: TextStyle(color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
                )
            ),
          ),

          AlreadyHaveAnAccountCheck(
            //login: true, // this is a login screen, this set boolean to true (default)
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SignUpScreen();
                  },),
              );},),
        ],
      ),
    );
  }
}
