import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen> {
  // Function to handle SOS button
  void _handleSOS() {
    // Dial emergency number immediately
    _makePhoneCall('100');
  }

  // Function to make phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    // Get device size for responsive layout calculations
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    // Responsive spacing values
    final double verticalSpacing = screenHeight * 0.01;
    final double horizontalPadding = screenWidth * 0.05;
    final double smallPadding = screenWidth * 0.02;

    // Responsive font and icon sizes
    final double smallFontSize = screenWidth * 0.035;
    final double mediumFontSize = screenWidth * 0.04;
    final double largeFontSize = screenWidth * 0.055;
    final double smallIconSize = screenWidth * 0.045;
    final double mediumIconSize = screenWidth * 0.06;
    final double largeIconSize = screenWidth * 0.09;

    // Button and container sizes
    final double serviceButtonSize = screenWidth * 0.17;
    final double sosButtonSize = screenWidth * 0.4;
    final double contactAvatarSize = screenWidth * 0.11;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE53935), // Brighter red at top
              Color(0xFFB71C1C), // Deeper red at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: smallPadding),
                      child: Column(
                        children: [
                          // Status bar content
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: verticalSpacing),
                            child: Row(
                              children: [
                                Text(
                                  "9:41",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: smallFontSize,
                                  ),
                                ),
                                const Spacer(),
                                // Network and wifi signals
                                Row(
                                  children: [
                                    Icon(
                                      Icons.signal_cellular_4_bar,
                                      color: Colors.white,
                                      size: smallIconSize,
                                    ),
                                    SizedBox(width: smallPadding),
                                    Icon(
                                      Icons.wifi,
                                      color: Colors.white,
                                      size: smallIconSize,
                                    ),
                                    SizedBox(width: smallPadding),
                                    Icon(
                                      Icons.battery_full,
                                      color: Colors.white,
                                      size: smallIconSize,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),

                          // App Logo
                          Container(
                            margin: EdgeInsets.only(
                                top: verticalSpacing,
                                bottom: verticalSpacing * 2),
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.health_and_safety,
                                color: const Color(0xFFB71C1C),
                                size: screenWidth * 0.07,
                              ),
                            ),
                          ),

                          // Emergency SOS header
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: verticalSpacing),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(smallPadding),
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.white,
                                    size: smallIconSize,
                                  ),
                                ),
                                SizedBox(width: smallPadding),
                                Text(
                                  "EMERGENCY SOS",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: largeFontSize,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                )
                              ],
                            ),
                          ),

                          // Help message
                          Container(
                            margin: EdgeInsets.only(
                                top: verticalSpacing,
                                bottom: verticalSpacing * 2),
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: verticalSpacing),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Tap SOS button to call for help",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: mediumFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          // SOS button
                          GestureDetector(
                            onTap: _handleSOS,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: verticalSpacing * 1.5),
                              width: sosButtonSize,
                              height: sosButtonSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [
                                    Color(0xFFFF6E6E),
                                    Color(0xFFE53935)
                                  ],
                                  center: Alignment(0.1, 0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.8),
                                    width: 3),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.white,
                                      size: largeIconSize,
                                      shadows: const [
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.black26,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: verticalSpacing),
                                    Text(
                                      "Tap for SOS",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: mediumFontSize,
                                        fontWeight: FontWeight.w600,
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: Colors.black26,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Emergency instructions
                          Container(
                            margin: EdgeInsets.all(horizontalPadding),
                            padding: EdgeInsets.all(horizontalPadding * 0.8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.white,
                                      size: smallIconSize * 0.7,
                                    ),
                                    SizedBox(width: smallPadding),
                                    Expanded(
                                      child: Text(
                                        "Emergency Instructions",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: smallFontSize,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: verticalSpacing),
                                Text(
                                  "1. Stay calm and speak clearly when calling",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: smallFontSize,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: verticalSpacing * 0.5),
                                Text(
                                  "2. Share your exact location with dispatcher",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: smallFontSize,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: verticalSpacing * 0.5),
                                Text(
                                  "3. Follow the instructions given by emergency services",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: smallFontSize,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Emergency services
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: verticalSpacing * 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildServiceButton(
                                  Icons.local_police,
                                  "Police",
                                  serviceButtonSize,
                                  smallFontSize,
                                  mediumIconSize,
                                  () => _makePhoneCall('100'),
                                ),
                                _buildServiceButton(
                                  Icons.local_hospital,
                                  "Ambulance",
                                  serviceButtonSize,
                                  smallFontSize,
                                  mediumIconSize,
                                  () => _makePhoneCall('108'),
                                ),
                                _buildServiceButton(
                                  Icons.local_fire_department,
                                  "Fire",
                                  serviceButtonSize,
                                  smallFontSize,
                                  mediumIconSize,
                                  () => _makePhoneCall('101'),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: verticalSpacing),

                          // Emergency contacts header
                          Padding(
                            padding: EdgeInsets.only(
                                left: horizontalPadding,
                                bottom: verticalSpacing),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Emergency Contacts",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: mediumFontSize,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                          // Emergency contacts
                          _buildContactCard(
                            "Palani Velan",
                            "Family",
                            Icons.person,
                            horizontalPadding,
                            verticalSpacing,
                            smallFontSize,
                            mediumFontSize,
                            smallIconSize,
                            contactAvatarSize,
                            () => _makePhoneCall('9791900001'),
                          ),

                          _buildContactCard(
                            "Piyush",
                            "Emergency Contact",
                            Icons.person,
                            horizontalPadding,
                            verticalSpacing,
                            smallFontSize,
                            mediumFontSize,
                            smallIconSize,
                            contactAvatarSize,
                            () => _makePhoneCall('8723100001'),
                          ),

                          SizedBox(height: verticalSpacing * 3),

                          // Footer instructions
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: horizontalPadding * 1.5,
                                vertical: verticalSpacing),
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding * 0.8,
                                vertical: verticalSpacing),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Stay calm and provide clear information to emergency services",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: smallFontSize * 0.9,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),

                          // Swipe instruction
                          Container(
                            margin:
                                EdgeInsets.only(bottom: verticalSpacing * 2),
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: verticalSpacing * 0.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.swipe_up_alt,
                                  color: Colors.white,
                                  size: smallIconSize * 0.8,
                                ),
                                SizedBox(width: smallPadding * 0.5),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildServiceButton(
    IconData icon,
    String label,
    double size,
    double fontSize,
    double iconSize,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    String name,
    String relation,
    IconData icon,
    double horizontalPadding,
    double verticalSpacing,
    double smallFontSize,
    double mediumFontSize,
    double iconSize,
    double avatarSize,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: verticalSpacing * 0.6),
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding * 0.8, vertical: verticalSpacing),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [Color(0xFFE57373), Color(0xFFEF5350)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: iconSize,
              ),
            ),
            SizedBox(width: horizontalPadding * 0.8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: mediumFontSize * 0.9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: verticalSpacing * 0.5),
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding * 0.4,
                        vertical: verticalSpacing * 0.2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      relation,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: smallFontSize * 0.8,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [Color(0xFF4CAF50), Color(0xFF388E3C)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.phone,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
