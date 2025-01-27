import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import '../../../Components/constants.dart';
>>>>>>> a42de36bf9b6396daebb1932c391b5db53222835
import '../Signup/signup_screen.dart';
import '../_shared/already_have_an_account_acheck.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email = "";
  TextEditingController mailcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
<<<<<<< HEAD
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
=======
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
>>>>>>> a42de36bf9b6396daebb1932c391b5db53222835
        content: Text(
          "Password Reset Email has been sent!",
          style: TextStyle(fontSize: 20.0),
        ),
      ));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
<<<<<<< HEAD
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
=======
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
>>>>>>> a42de36bf9b6396daebb1932c391b5db53222835
          content: Text(
            "No user found for that email.",
            style: TextStyle(fontSize: 20.0),
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Bottom Decorative Image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
<<<<<<< HEAD
              'assets/images/main_bottom.png', // Replace with your bottom image path
=======
              'images/blocks/main_bottom.png', // Replace with your bottom image path
>>>>>>> a42de36bf9b6396daebb1932c391b5db53222835
              fit: BoxFit.cover,
              height: 70,
            ),
          ),
          // Main Content
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Image.asset(
                          'assets/images/forgot_pswd.webp',
                          width: 400,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(40.0),
                        child: buildForm(context, screenWidth),
                      ),
                    ),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/forgot_pswd.webp',
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        buildForm(context, screenWidth),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildForm(BuildContext context, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
<<<<<<< HEAD
      children: [
        const Text(
          "Password Recovery",
          style: TextStyle(
            fontSize: 26,
=======
      children: 
      [
        const Text(
          "Password Recovery",
          style: TextStyle(
            fontSize: 30,
>>>>>>> a42de36bf9b6396daebb1932c391b5db53222835
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
<<<<<<< HEAD
        const SizedBox(height: 10),
        const Text(
          "Enter your email to reset your password",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 30),
=======

        const SizedBox(height: pad_big),
        const Text(
          "Enter your email",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: pad_big),

>>>>>>> a42de36bf9b6396daebb1932c391b5db53222835
        Form(
          key: _formkey,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
<<<<<<< HEAD
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextFormField(
              controller: mailcontroller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
              onChanged: (value) => email = value,
              decoration: InputDecoration(
                hintText: "Email",
                prefixIcon: Icon(Icons.email, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            if (_formkey.currentState!.validate()) {
              resetPassword();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "Send Email",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account?",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: const Text(
                " Sign Up",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
=======
              borderRadius: BorderRadius.circular(50),
              border: Border.all(width: 5, color: kPrimaryColor),
            ),
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please Enter E-mail';
                return null;
              },
              controller: mailcontroller,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              textAlign: TextAlign.center,
              cursorColor: kPrimaryColor,
              onSaved: (email) {},
              
              decoration: const InputDecoration(
                hintText: "Your email",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(pad_norm),
                  child: Icon(Icons.mark_email_unread_sharp),
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.all(pad_norm),
                  child: Icon(Icons.lock_reset_outlined),
                ),
              ),
              
            ),),
        ),

        const SizedBox(height: pad_norm),
        Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(width: 5, color: Colors.blueGrey),
            ),
            child:ElevatedButton(
            onPressed: () { // add functionality to make reset passwork api call
              if (_formkey.currentState!.validate()) {
                setState(() { email=mailcontroller.text; }); 
              }
              resetPassword();
            },
            child: const Text(
                "Send Email",
                style: TextStyle(
                  color: kPrimaryLightColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),),
        ),),
        const SizedBox(height: pad_small),

        AlreadyHaveAnAccountCheck(
          login: false, social:false, // to revert back to login page
          press: () { Navigator.pop(context); },
        ),
        const SizedBox(height: pad_big),
        
        AlreadyHaveAnAccountCheck(
            //login: false, // this is a subpage of login screen => true (default)
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SignUpScreen();
                  },),
              );},),
      ],
    );
  }
}
>>>>>>> a42de36bf9b6396daebb1932c391b5db53222835
