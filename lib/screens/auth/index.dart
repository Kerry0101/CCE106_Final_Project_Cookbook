import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookbook/screens/auth/signup.dart';
import 'package:cookbook/services/authentication.dart';
import 'package:cookbook/utils/colors.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        color: bgc1,
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: size.height * 0.45,
                width: size.width,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  color: primaryColor,
                  image: const DecorationImage(
                    image: AssetImage("lib/images/cartoon2.png"),
                  ),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.5,
              left: 0,
              right: 0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "Unlock your Cooking Potential with ",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.workSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: textColor1,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        "Culinary Chronicles",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.workSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: primaryColor3,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Your ultimate recipe manager and planner!\nGet started for free!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.workSans(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            color: textColor2,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Container(
                          height: size.height * 0.08,
                          width: size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: bgc3.withOpacity(0.9),
                            border: Border.all(
                              color: Colors.white,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.05),
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset: const Offset(0, -1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 5,
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SignUp(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: size.height * 0.08,
                                    width: size.width / 2.6,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: primaryColor2,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Sign Up",
                                        style: GoogleFonts.workSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: textColor1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const AuthenticationUser(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Log In",
                                    style: GoogleFonts.workSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: textColor1,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
