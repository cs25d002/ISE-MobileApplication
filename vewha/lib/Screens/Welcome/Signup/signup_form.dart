// dependencies
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// module refs
import '../../../Components/constants.dart';
import '../_shared/already_have_an_account_acheck.dart';
// page refs
import '../Login/login_screen.dart';
import '../../Home/home_page.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpForm> {
  String email = "", password = "", name = "";
  TextEditingController namecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>(); // helps to validate each text-field

  registration() async {
    if (password.isNotEmpty &&
        namecontroller.text != "" &&
        mailcontroller.text != "") {
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          "Registered Successfully",
          style: TextStyle(fontSize: 20.0),
        )));

        Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GreetingPage(email: email),
      ),
    );
    } 
      on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too Weak",
                style: TextStyle(fontSize: 18.0),
              )));
        } 
        else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 18.0),
              )));
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text("${e.code}:${e.message}", // show other types of error
            style: const TextStyle(fontSize: 18.0),
          )));
        }
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
                if (value == null || value.isEmpty) return "Please Enter Name";
                return null;
              },
              controller: namecontroller,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              onSaved: (email) {},

              decoration: const InputDecoration(
                hintText: "Your name",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(pad_norm),
                  child: Icon(Icons.person_add),
                ),
              ),

            ),
          ),

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
                  child: Icon(Icons.email_rounded),
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
                  child: Icon(Icons.lock_open_sharp),
                ),
              ),

            ),
          ),

          const SizedBox(height: pad_norm),
          ElevatedButton(
            onPressed: () // add functionality to sign up
            {
              if (_formkey.currentState!.validate()) {
                setState(() {
                  email = mailcontroller.text;
                  name = namecontroller.text;
                  password = passwordcontroller.text;
                });
              }
              registration();
            },
            child: Text("Sign Up".toUpperCase()),
          ),
          const SizedBox(height: pad_small),

          AlreadyHaveAnAccountCheck(
            login: false, // this is a sign-up screen, this set boolean to false
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen();
                  },),
              );},),
        ],
      ),
    );
  }
}
