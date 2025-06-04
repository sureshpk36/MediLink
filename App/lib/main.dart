import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'prescription.dart'; // Assumed screen for "Prescription" card
import 'lab_test.dart'; // Assumed screen for "Test Booking" card
import 'ai_therapy.dart'; // Assumed screen for "AI Therapy" card
import 'medibot.dart'; // Contains ChatScreen()
import 'track_vitals.dart'; // Assumed screen for "Track Vitals" card
import 'pharmacy.dart'; // Assumed screen for "Pharmacy" card
import 'sos_screen.dart'; // Contains EmergencySosScreen()
import 'community.dart'; // Assumed screen for "Community" card
import 'profile.dart'; // Contains ProfilePage()
import 'appointment.dart'; // Contains AppointmentScreen()

// --- Placeholder Screens (Replace with your actual screen widgets) ---
// If these are not defined elsewhere, create basic placeholder widgets
// for testing until your real screens are ready.

// Example placeholder:
// class ChatScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(appBar: AppBar(title: Text("Chat")), body: Center(child: Text("Chat Screen")));
//   }
// }
// class AppointmentScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(appBar: AppBar(title: Text("Appointments")), body: Center(child: Text("Appointment Screen")));
//   }
// }
// class ProfilePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(appBar: AppBar(title: Text("Profile")), body: Center(child: Text("Profile Page")));
//   }
// }
// class EmergencySosScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(appBar: AppBar(title: Text("SOS")), body: Center(child: Text("Emergency SOS Screen")));
//   }
// }
// --- End Placeholder Screens ---

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: GoogleFonts.montserrat().fontFamily,
        scaffoldBackgroundColor: const Color(0xFFF0F4FF),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: GoogleFonts.nunito(),
          bodyMedium: GoogleFonts.nunito(),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4742DE),
          secondary: Color(0xFF41C8DD),
          tertiary: Color(0xFFFF6E7F),
          background: Color(0xFFF0F4FF),
          surface: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Helper function for responsive sizing (optional, but can simplify)
  double _getResponsiveValue(
      double baseValue, double screenDimension, double scaleFactor) {
    return baseValue * (screenDimension / 375.0) * scaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // --- Responsive constants ---
    final double horizontalPadding = screenWidth * 0.05;
    final double verticalPadding = screenHeight * 0.02;
    final double headerExpandedHeight = screenHeight * 0.3;
    final double searchBarHeight = 50.0;
    final double bottomNavHeight = 76.0 + bottomPadding;
    final double fabSize = 60.0;
    final double fabBottomOffset =
        bottomNavHeight / 2 - fabSize / 2 + 16; // Center FAB + margin

    return Scaffold(
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Image.network(
              'https://transparenttextures.com/patterns/cubes.png',
              repeat: ImageRepeat.repeat,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.03),
            ),
          ),
          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar - Modified
              SliverAppBar(
                expandedHeight: headerExpandedHeight,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeader(
                      context, screenWidth, screenHeight, topPadding),
                ),
              ),
              // Search Bar
              SliverPersistentHeader(
                pinned: false,
                floating: true,
                delegate: _SearchBarDelegate(
                  minHeight: searchBarHeight + (verticalPadding * 1.5),
                  maxHeight: searchBarHeight + (verticalPadding * 1.5),
                  child: Container(
                    color: Theme.of(context).colorScheme.background,
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding * 0.75),
                    child: _buildSearchBar(context, screenWidth),
                  ),
                ),
              ),
              // Section title
              SliverToBoxAdapter(
                child: Container(
                  color: Theme.of(context).colorScheme.background,
                  padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      verticalPadding * 1.5,
                      horizontalPadding,
                      verticalPadding * 0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Health Services",
                        style: TextStyle(
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      // "View All" Button
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding * 0.6,
                            vertical: verticalPadding * 0.3),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "View All",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.01),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: screenWidth * 0.03,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Feature grid
              SliverPadding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding,
                    horizontalPadding, bottomNavHeight + fabSize / 2 + 20),
                sliver: _buildFeatureGrid(context, screenWidth),
              ),
            ],
          ),
          // Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavBar(
              context,
              screenWidth,
              bottomNavHeight - bottomPadding,
              bottomPadding,
            ),
          ),
          // Floating Action Button
          Positioned(
            left: 0,
            right: 0,
            bottom: fabBottomOffset,
            child: Center(
              child: _buildFloatingActionButton(context, fabSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double screenWidth,
      double screenHeight, double topPadding) {
    final titleFontSize = screenWidth * 0.05;
    final nameFontSize = screenWidth * 0.07;
    final dateFontSize = screenWidth * 0.04;
    final avatarSize = screenWidth * 0.11;
    final verticalSpacingSmall = screenHeight * 0.01;
    final verticalSpacingLarge = screenHeight * 0.03;

    // Get current date
    final now = DateTime.now();
    final formattedDate = "${[
      "",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ][now.weekday]}, ${[
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ][now.month]} ${now.day}";

    return Container(
      padding: EdgeInsets.fromLTRB(
          screenWidth * 0.05,
          topPadding + screenHeight * 0.03,
          screenWidth * 0.05,
          screenHeight * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4742DE),
            const Color(0xFF644CE1),
            const Color(0xFF41C8DD),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.65, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: App Title, Notification, Avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MediLink",
                style: GoogleFonts.poppins(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.025),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: screenWidth * 0.055,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Container(
                    height: avatarSize,
                    width: avatarSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://cdn-icons-png.flaticon.com/512/9187/9187604.png'), // Placeholder image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: verticalSpacingLarge),
          Text(
            "Hello, Suresh 👋", // Consider making name dynamic
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: nameFontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: verticalSpacingSmall),
          Text(
            formattedDate, // Display current date
            style: GoogleFonts.nunito(
              color: Colors.white.withOpacity(0.9),
              fontSize: dateFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, double screenWidth) {
    final hintFontSize = screenWidth * 0.038;
    final iconSize = screenWidth * 0.05;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: "Search for services...",
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: hintFontSize,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade400,
            size: iconSize,
          ),
          suffixIcon: Container(
            margin: EdgeInsets.all(screenWidth * 0.015),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: Theme.of(context).colorScheme.secondary,
              size: iconSize * 0.9,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, double screenWidth) {
    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = 4;
    } else if (screenWidth >= 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    final double crossAxisSpacing = screenWidth * 0.04;
    final double mainAxisSpacing = screenWidth * 0.05;
    final double childAspectRatio = (crossAxisCount > 2) ? 0.95 : 1.0;

    final List<FeatureCard> features = [
      FeatureCard(
        title: "Prescription",
        subtitle: "Manage & refill",
        iconData: Icons.medical_services_rounded,
        gradientStart: const Color(0xFF6E8EFB),
        gradientEnd: const Color(0xFF4A6FEB),
        iconColor: Colors.white,
        svgIcon: "assets/icons/prescription.svg",
      ),
      FeatureCard(
        title: "Test Booking",
        subtitle: "Lab & diagnostics",
        iconData: Icons.science_rounded,
        gradientStart: const Color(0xFFFF8B95),
        gradientEnd: const Color(0xFFFF5E6A),
        iconColor: Colors.white,
        svgIcon: "assets/icons/lab.svg",
      ),
      FeatureCard(
        title: "AI Therapy",
        subtitle: "Mental wellness",
        iconData: Icons.psychology_rounded,
        gradientStart: const Color(0xFF6FDFBE),
        gradientEnd: const Color(0xFF2ABB96),
        iconColor: Colors.white,
        svgIcon: "assets/icons/ai.svg",
      ),
      FeatureCard(
        title: "Medibot",
        subtitle: "AI diagnostics",
        iconData: Icons.smart_toy_rounded,
        gradientStart: const Color(0xFF7F7FD5),
        gradientEnd: const Color(0xFF5F72BD),
        iconColor: Colors.white,
        svgIcon: "assets/icons/robot.svg",
        isGlassmorphic: true,
      ),
      FeatureCard(
        title: "Track Vitals",
        subtitle: "Health metrics",
        iconData: Icons.favorite_rounded,
        gradientStart: const Color(0xFFF783AC),
        gradientEnd: const Color(0xFFE64980),
        iconColor: Colors.white,
        svgIcon: "assets/icons/heart.svg",
      ),
      FeatureCard(
        title: "Pharmacy",
        subtitle: "Order medicines",
        iconData: Icons.local_pharmacy_rounded,
        gradientStart: const Color(0xFF56CCF2),
        gradientEnd: const Color(0xFF2F80ED),
        iconColor: Colors.white,
        svgIcon: "assets/icons/pharmacy.svg",
      ),
      FeatureCard(
        title: "SOS",
        subtitle: "Emergency help",
        iconData: Icons.emergency_rounded,
        gradientStart: const Color(0xFFFF512F),
        gradientEnd: const Color(0xFFDD2476),
        iconColor: Colors.white,
        svgIcon: "assets/icons/emergency.svg",
      ),
      FeatureCard(
        title: "Community",
        subtitle: "Support groups",
        iconData: Icons.group_rounded,
        gradientStart: const Color(0xFF9D50BB),
        gradientEnd: const Color(0xFF6E48AA),
        iconColor: Colors.white,
        svgIcon: "assets/icons/community.svg",
      ),
    ];

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final delay = index * 0.1;
              final slideAnimation = Tween(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    delay.clamp(0.0, 0.9),
                    (delay + 0.5).clamp(0.0, 1.0),
                    curve: Curves.easeOutQuint,
                  ),
                ),
              );
              final fadeAnimation = Tween(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    delay.clamp(0.0, 0.9),
                    (delay + 0.5).clamp(0.0, 1.0),
                    curve: Curves.easeOut,
                  ),
                ),
              );
              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: _buildFeatureCardWidget(
                      context, screenWidth, features[index]),
                ),
              );
            },
          );
        },
        childCount: features.length,
      ),
    );
  }

  Widget _buildFeatureCardWidget(
      BuildContext context, double screenWidth, FeatureCard feature) {
    final double internalPadding = screenWidth * 0.04;
    final double iconContainerPadding = screenWidth * 0.035;
    final double iconSize = screenWidth * 0.1;
    final double titleFontSize = screenWidth * 0.045;
    final double subtitleFontSize = screenWidth * 0.032;
    final double verticalSpacingMedium = screenWidth * 0.04;
    final double verticalSpacingSmall = screenWidth * 0.01;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // --- Navigation based on FeatureCard title ---
        Widget? targetScreen;
        switch (feature.title) {
          case "Prescription":
            targetScreen = const PrescriptionScreen(); // Replace if needed
            break;
          case "Test Booking":
            targetScreen = MedicalTestBookingApp(); // Replace if needed
            break;
          case "AI Therapy":
            targetScreen = AudioCallScreen(); // Replace if needed
            break;
          case "Medibot":
            targetScreen = ChatScreen();
            break;
          case "Track Vitals":
            targetScreen = EnhancedHealthDashboard(); // Replace if needed
            break;
          case "Pharmacy":
            targetScreen = PharmacyApp(); // Replace if needed
            break;
          case "SOS":
            targetScreen = EmergencySosScreen();
            break;
          case "Community":
            targetScreen = HealthCommunityApp(); // Replace if needed
            break;
        }

        if (targetScreen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen!),
          );
        } else {
          // Fallback for unhandled cards
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${feature.title} selected (No screen assigned)'),
              duration: const Duration(milliseconds: 800),
              backgroundColor: feature.gradientEnd,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.fromLTRB(
                  screenWidth * 0.04, 0, screenWidth * 0.04, 80),
            ),
          );
        }
      },
      child: TweenAnimationBuilder(
        tween:
            Tween(begin: 1.0, end: 1.0), // Can be used for tap animation later
        duration: const Duration(milliseconds: 200),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [feature.gradientStart, feature.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: feature.gradientEnd.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
            ],
          ),
          child: feature.isGlassmorphic
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: _buildCardContent(
                        context,
                        feature,
                        internalPadding,
                        iconContainerPadding,
                        iconSize,
                        titleFontSize,
                        subtitleFontSize,
                        verticalSpacingMedium,
                        verticalSpacingSmall),
                  ),
                )
              : _buildCardContent(
                  context,
                  feature,
                  internalPadding,
                  iconContainerPadding,
                  iconSize,
                  titleFontSize,
                  subtitleFontSize,
                  verticalSpacingMedium,
                  verticalSpacingSmall),
        ),
      ),
    );
  }

  Widget _buildCardContent(
      BuildContext context,
      FeatureCard feature,
      double internalPadding,
      double iconContainerPadding,
      double iconSize,
      double titleFontSize,
      double subtitleFontSize,
      double verticalSpacingMedium,
      double verticalSpacingSmall) {
    return Container(
      padding: EdgeInsets.all(internalPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: feature.isGlassmorphic
            ? Border.all(color: Colors.white.withOpacity(0.2))
            : null,
        color: feature.isGlassmorphic
            ? Colors.white.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(iconContainerPadding),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              feature.iconData,
              size: iconSize,
              color: feature.iconColor,
            ),
          ),
          SizedBox(height: verticalSpacingMedium),
          Text(
            feature.title,
            style: GoogleFonts.montserrat(
              color: feature.iconColor,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: verticalSpacingSmall),
          Text(
            feature.subtitle,
            style: GoogleFonts.nunito(
              color: feature.iconColor.withOpacity(0.85),
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, double screenWidth,
      double navBarHeight, double bottomSafePadding) {
    final double horizontalMargin = screenWidth * 0.04;

    return Container(
      height: navBarHeight + bottomSafePadding,
      margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 0),
      padding: EdgeInsets.only(bottom: bottomSafePadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
            top: const Radius.circular(28),
            bottom: Radius.circular(bottomSafePadding > 0 ? 0 : 28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(context, screenWidth, 0, Icons.home_rounded, "Home"),
          _buildNavItem(context, screenWidth, 1, Icons.message_rounded, "Chat"),
          SizedBox(width: screenWidth * 0.18), // Spacer for FAB
          _buildNavItem(context, screenWidth, 2, Icons.calendar_month_rounded,
              "Schedule"),
          _buildNavItem(
              context, screenWidth, 3, Icons.person_rounded, "Profile"),
        ],
      ),
    );
  }

  // MODIFIED: Added Navigation Logic
  Widget _buildNavItem(BuildContext context, double screenWidth, int index,
      IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final double iconSize = screenWidth * 0.065;
    final double fontSize = screenWidth * 0.03;
    final double verticalPadding = screenWidth * 0.03;
    final double horizontalPadding = screenWidth * 0.04;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        // Update state to reflect selection visually (optional for navigation)
        setState(() {
          // Only update selected index if it's NOT the current one AND it's the Home tab
          // Or if we just want to visually update the tapped item before navigating
          // Let's update visually regardless, then navigate.
          // If staying on Home, the selection should stick.
          _selectedIndex = index;
        });

        // --- Navigation Logic ---
        Widget? targetScreen;
        switch (index) {
          case 0: // Home - Already on HomeScreen, do nothing extra
            break;
          case 1: // Chat
            targetScreen = ChatScreen();
            break;
          case 2: // Schedule
            targetScreen = AppointmentScreen();
            break;
          case 3: // Profile
            targetScreen = ProfilePage();
            break;
        }

        // Perform navigation if a target screen is set
        if (targetScreen != null) {
          // Prevent pushing the same screen type multiple times if the user taps quickly
          // This basic check works if you don't need complex stack management.
          // For more robust solutions, consider routing packages like go_router.
          // NOTE: This simple check might prevent navigating *back* to a screen type
          // already in the stack. Adjust if that behaviour is needed.
          bool screenAlreadyOpen = ModalRoute.of(context)?.settings.name ==
              targetScreen.runtimeType.toString();

          if (!screenAlreadyOpen) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => targetScreen!,
                  // Optional: Give the route a name for checking
                  settings:
                      RouteSettings(name: targetScreen.runtimeType.toString())),
            );
          }
        }
        // --- End Navigation Logic ---
      },
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: verticalPadding * 0.8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade400,
              size: iconSize,
            ),
            SizedBox(height: screenWidth * 0.01),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade500,
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, double fabSize) {
    final iconSize = fabSize * 0.55;
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true, // Allows sheet to take more height
            builder: (context) => _buildSOSSheet(
                context,
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).padding.bottom),
          );
        },
        child: Container(
          width: fabSize,
          height: fabSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF512F), Color(0xFFDD2476)], // SOS gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDD2476).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
            ],
          ),
          // Changed Icon to reflect "Quick Actions" more generally
          child: Icon(
            Icons
                .add_rounded, // Or Icons.dashboard_customize_rounded, Icons.widgets_rounded
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  Widget _buildSOSSheet(
      BuildContext context, double screenWidth, double bottomPadding) {
    // Ensure sheet content is adaptive and scrollable if needed
    final double horizontalPadding = screenWidth * 0.06;
    final double verticalPadding = screenWidth * 0.06;
    final double titleFontSize = screenWidth * 0.055;
    final double spacing = screenWidth * 0.06;
    final double smallSpacing = screenWidth * 0.03;

    return Padding(
      // Add padding to avoid system intrusions (like notch or bottom bar)
      padding: EdgeInsets.only(
          bottom: bottomPadding > 0
              ? bottomPadding
              : smallSpacing), // Ensure some padding even without safe area
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: verticalPadding * 0.8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Take only needed vertical space
          children: [
            // Handle for dragging down
            Container(
              width: screenWidth * 0.15,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            SizedBox(height: spacing),
            Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: spacing),
            // --- Quick Action Buttons ---
            _buildQuickActionButton(
              context: context,
              screenWidth: screenWidth,
              icon: Icons.local_hospital_rounded, // SOS Icon
              title: "Emergency SOS",
              subtitle: "Contact emergency services",
              color: const Color(0xFFFF5E6A), // Reddish color for SOS
            ),
            SizedBox(height: smallSpacing),
            _buildQuickActionButton(
              context: context,
              screenWidth: screenWidth,
              icon: Icons.calendar_today_rounded, // Appointment Icon
              title: "Book Appointment",
              subtitle: "Schedule a doctor visit",
              color: const Color(0xFF2ABB96), // Greenish color
            ),
            SizedBox(height: smallSpacing),
            // Keep Quick Prescription or add others as needed
            _buildQuickActionButton(
              context: context,
              screenWidth: screenWidth,
              icon: Icons.medication_rounded, // Prescription Icon
              title: "Quick Prescription",
              subtitle: "Renew your medications",
              color: const Color(0xFF4A6FEB), // Bluish color
            ),
            SizedBox(height: spacing * 0.5), // Bottom padding inside the sheet
          ],
        ),
      ),
    );
  }

  // MODIFIED: Added Navigation Logic for Book Appointment
  Widget _buildQuickActionButton({
    required BuildContext context,
    required double screenWidth,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final double horizontalPadding = screenWidth * 0.04;
    final double verticalPadding = screenWidth * 0.03;
    final double iconPadding = screenWidth * 0.025;
    final double iconSize = screenWidth * 0.06;
    final double titleFontSize = screenWidth * 0.04;
    final double subtitleFontSize = screenWidth * 0.032;
    final double arrowIconSize = screenWidth * 0.04;
    final double spacing = screenWidth * 0.04;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Close the bottom sheet first
          Navigator.pop(context);

          // --- Navigation Logic ---
          Widget? targetScreen;
          if (title == "Emergency SOS") {
            targetScreen = EmergencySosScreen();
          } else if (title == "Book Appointment") {
            targetScreen = AppointmentScreen();
          } else if (title == "Quick Prescription") {
            // Assign the screen for Quick Prescription if you have one
            // targetScreen = QuickPrescriptionScreen(); // Example
          }
          // Add more else if conditions for other quick actions

          if (targetScreen != null) {
            // Similar check as in NavBar to prevent rapid double-taps opening same screen
            bool screenAlreadyOpen = ModalRoute.of(context)?.settings.name ==
                targetScreen.runtimeType.toString();
            if (!screenAlreadyOpen) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => targetScreen!,
                    settings: RouteSettings(
                        name: targetScreen.runtimeType.toString())),
              );
            }
          } else if (title != "Quick Prescription") {
            // Only show SnackBar for unhandled actions other than prescription
            // Fallback: Show a SnackBar if no specific navigation is defined (except for potentially handled ones)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title selected'),
                backgroundColor: color,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: EdgeInsets.fromLTRB(screenWidth * 0.04, 0,
                    screenWidth * 0.04, 80), // Adjust margin if needed
                duration: const Duration(milliseconds: 1200),
              ),
            );
          }
          // --- End Navigation Logic ---
        },
        borderRadius:
            BorderRadius.circular(16), // Apply radius to InkWell ripple
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: verticalPadding),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200), // Subtle border
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color:
                      color.withOpacity(0.1), // Use action color with opacity
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color, // Use action color
                  size: iconSize,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: titleFontSize,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: subtitleFontSize,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons
                    .arrow_forward_ios_rounded, // Standard iOS-style forward arrow
                color: Colors.grey.shade400,
                size: arrowIconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Helper Widgets ---

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _SearchBarDelegate(
      {required this.child, required this.minHeight, required this.maxHeight});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) {
    return child != oldDelegate.child ||
        minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight;
  }
}

class FeatureCard {
  final String title;
  final String subtitle;
  final IconData iconData;
  final Color gradientStart;
  final Color gradientEnd;
  final Color iconColor;
  final bool isGlassmorphic;
  final String? svgIcon; // Keep if using SVG, otherwise remove

  FeatureCard({
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.gradientStart,
    required this.gradientEnd,
    required this.iconColor,
    this.svgIcon,
    this.isGlassmorphic = false,
  });
}
