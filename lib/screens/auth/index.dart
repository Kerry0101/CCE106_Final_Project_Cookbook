import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookbook/screens/auth/signup.dart';
import 'package:cookbook/screens/auth/login.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:cookbook/utils/page_transitions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToAuth(bool isSignUp) {
    Navigator.pushReplacement(
      context,
      SlidePageRoute(
        page: isSignUp ? const SignUp() : const LogIn(),
        direction: AxisDirection.left,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: bgc1,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => _navigateToAuth(false),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.workSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              
              // PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildOnboardingScreen(
                      size: size,
                      image: 'lib/images/cartoon2.png',
                      title: 'Welcome to\nCulinary Chronicles',
                      subtitle: 'Your ultimate recipe manager and cooking companion',
                      description: 'Discover, save, and create amazing recipes all in one place!',
                    ),
                    _buildOnboardingScreen(
                      size: size,
                      image: 'lib/images/iconpng.png',
                      title: 'Discover Delicious\nRecipes',
                      subtitle: 'Explore thousands of recipes',
                      description: 'From quick weeknight dinners to gourmet meals, find recipes that match your taste and skill level.',
                      icon: Icons.restaurant_menu,
                      iconColor: Colors.orange,
                    ),
                    _buildOnboardingScreen(
                      size: size,
                      image: 'lib/images/iconpng.png',
                      title: 'Save & Organize\nYour Favorites',
                      subtitle: 'Build your personal cookbook',
                      description: 'Create collections, add notes, and keep all your favorite recipes organized and easy to find.',
                      icon: Icons.favorite,
                      iconColor: Colors.red,
                    ),
                    _buildOnboardingScreen(
                      size: size,
                      image: 'lib/images/cartoon2.png',
                      title: 'Share with\nThe Community',
                      subtitle: 'Connect with food lovers',
                      description: 'Share your culinary creations, get inspired by others, and grow your cooking skills together!',
                      icon: Icons.people,
                      iconColor: Colors.blue,
                    ),
                  ],
                ),
              ),
              
              // Page indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _totalPages,
                  effect: ExpandingDotsEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    activeDotColor: primaryColor,
                    dotColor: Colors.grey.withOpacity(0.5),
                    expansionFactor: 3,
                  ),
                ),
              ),
              
              // Bottom buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    // Get Started / Next button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _totalPages - 1) {
                            _navigateToAuth(true);
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                          style: GoogleFonts.workSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Already have an account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            color: textColor2,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _navigateToAuth(false),
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.workSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingScreen({
    required Size size,
    required String image,
    required String title,
    required String subtitle,
    required String description,
    IconData? icon,
    Color? iconColor,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image or Icon
          Container(
            height: size.height * 0.3,
            width: size.width * 0.75,
            constraints: BoxConstraints(
              maxHeight: 280,
              minHeight: 200,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgc1, bgc2, bgc3, bgc4],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    image,
                    fit: BoxFit.cover,
                  ),
                  if (icon != null)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 60,
                            color: iconColor ?? primaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: size.height * 0.03),
          
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: textColor1,
            ),
          ),
          const SizedBox(height: 8),
          
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontSize: 15,
              color: textColor2,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Keep the old IndexPage name for backward compatibility
class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPage();
  }
}
