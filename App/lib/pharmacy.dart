// main.dart
import 'dart:async'; // For Timer in TrackOrderPage
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Used for commented-out form links
// import 'dart:convert'; // Not strictly needed for the current visible code, but kept from original
import 'dart:math'; // Needed for Random() in OrderPage

// --- Main App Widget ---
class PharmacyApp extends StatelessWidget {
  const PharmacyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediDelivery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1976D2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          secondary: const Color(0xFF03A9F4),
        ),
        fontFamily: 'Roboto',
      ),
      // Initial route is HomePage
      home: const HomePage(),
      // Named routes for navigation
      routes: {
        '/prescriptions': (context) => const PrescriptionsPage(),
        '/pharmacies': (context) => const PharmaciesPage(),
        '/order': (context) => const OrderPage(),
        '/track': (context) => const TrackOrderPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Home Page Widget ---
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediDelivery'),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.medical_services_outlined,
                  size: 70,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Welcome to MediDelivery',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your medicines delivered to your doorstep',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            // Menu items using a helper function
            _buildMenuItem(
              context,
              'My Prescriptions',
              Icons.description_outlined,
              '/prescriptions', // Navigates to PrescriptionsPage
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              context,
              'Find Nearby Pharmacies',
              Icons.local_pharmacy_outlined,
              '/pharmacies', // Navigates to PharmaciesPage
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              context,
              'Order Medicines',
              Icons.shopping_cart_outlined,
              '/order', // Navigates to OrderPage
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              context,
              'Track Order',
              Icons.delivery_dining_outlined,
              '/track', // Navigates to TrackOrderPage
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build styled menu items
  Widget _buildMenuItem(BuildContext context, String title, IconData icon,
      String route, Color color) {
    return InkWell(
      onTap: () {
        // Navigate to the specified route when tapped
        Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(), // Pushes the arrow icon to the right
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Prescriptions Page Widget ---
class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({Key? key}) : super(key: key);

  @override
  _PrescriptionsPageState createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  // Sample data - in a real app, this would come from storage or API
  final List<Map<String, dynamic>> _prescriptions = [
    {
      'id': 'RX10023',
      'doctor': 'Dr. Sarah Johnson',
      'date': '2025-04-10',
      'medicines': [
        {
          'name': 'Amoxicillin',
          'dosage': '500mg',
          'frequency': 'Twice daily',
          'duration': '7 days'
        },
        {
          'name': 'Paracetamol',
          'dosage': '650mg',
          'frequency': 'As needed',
          'duration': '3 days'
        },
      ],
      'status': 'Active',
    },
    {
      'id': 'RX10019',
      'doctor': 'Dr. Michael Chen',
      'date': '2025-04-05',
      'medicines': [
        {
          'name': 'Metformin',
          'dosage': '500mg',
          'frequency': 'Once daily',
          'duration': '30 days'
        },
        {
          'name': 'Atorvastatin',
          'dosage': '10mg',
          'frequency': 'Once daily',
          'duration': '30 days'
        },
      ],
      'status': 'Active',
    },
    {
      'id': 'RX09987',
      'doctor': 'Dr. Emily Williams',
      'date': '2025-03-22',
      'medicines': [
        {
          'name': 'Loratadine',
          'dosage': '10mg',
          'frequency': 'Once daily',
          'duration': '14 days'
        },
      ],
      'status': 'Expired',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prescriptions'),
      ),
      body: _prescriptions.isEmpty
          ? const Center(
              // Show message if no prescriptions
              child: Text(
                'No prescriptions available',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              // Display list of prescriptions
              padding: const EdgeInsets.all(16),
              itemCount: _prescriptions.length,
              itemBuilder: (context, index) {
                final prescription = _prescriptions[index];
                return Card(
                  // Each prescription in a Card
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Prescription #${prescription['id']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Status Chip (Active/Expired)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: prescription['status'] == 'Active'
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                prescription['status'],
                                style: TextStyle(
                                  color: prescription['status'] == 'Active'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          prescription['doctor'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Date: ${prescription['date']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Medicines:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // List medicines in the prescription
                        for (var medicine in prescription['medicines'])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.medication_outlined,
                                    size: 18, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        medicine['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '${medicine['dosage']} - ${medicine['frequency']} for ${medicine['duration']}',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Show "Order" button only if prescription is active
                        if (prescription['status'] == 'Active')
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to PharmaciesPage, passing the prescription data as arguments
                              Navigator.pushNamed(context, '/pharmacies',
                                  arguments: prescription);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Order Medicines From This Rx'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
      // Floating Action Button to add a new prescription (placeholder)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Placeholder: In a real app, launch a camera/upload or form
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Prescription action tapped')),
          );
          // _launchPrescriptionForm(); // Keep if you have a form URL
        },
        child: const Icon(Icons.add_a_photo_outlined), // Icon for adding Rx
        tooltip: 'Add Prescription',
      ),
    );
  }

  // --- Commented out: Example of launching an external URL for a form ---
  // Future<void> _launchPrescriptionForm() async {
  //   // Replace with your actual prescription upload form URL
  //   final Uri url = Uri.parse('https://forms.gle/YourPrescriptionFormUrl');
  //   if (!await launchUrl(url)) {
  //     // Show error if URL can't be launched
  //     if (mounted) { // Check if widget is still in the tree
  //        ScaffoldMessenger.of(context).showSnackBar(
  //          const SnackBar(content: Text('Could not open prescription form')),
  //        );
  //     }
  //   }
  // }
}

// --- Pharmacies Page Widget ---
class PharmaciesPage extends StatefulWidget {
  const PharmaciesPage({Key? key}) : super(key: key);

  @override
  _PharmaciesPageState createState() => _PharmaciesPageState();
}

class _PharmaciesPageState extends State<PharmaciesPage> {
  // Sample data for nearby pharmacies
  final List<Map<String, dynamic>> _pharmacies = [
    {
      'id': 1,
      'name': 'MediCare Pharmacy',
      'address': '123 Health Street, Medicity',
      'distance': '0.8 km',
      'rating': 4.7,
      'deliveryTime': '30-45 min',
      'isOpen': true,
    },
    {
      'id': 2,
      'name': 'LifeCare Drugs',
      'address': '456 Wellness Avenue, Medicity',
      'distance': '1.2 km',
      'rating': 4.5,
      'deliveryTime': '25-40 min',
      'isOpen': true,
    },
    {
      'id': 3,
      'name': 'QuickMeds',
      'address': '789 Recovery Road, Medicity',
      'distance': '2.0 km',
      'rating': 4.8,
      'deliveryTime': '35-50 min',
      'isOpen': true,
    },
    {
      'id': 4,
      'name': 'City Pharmacy',
      'address': '101 Central Square, Medicity',
      'distance': '2.5 km',
      'rating': 4.2,
      'deliveryTime': '40-55 min',
      'isOpen': false, // Example of a closed pharmacy
    },
  ];

  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredPharmacies =
      []; // List to hold search results

  @override
  void initState() {
    super.initState();
    // Initially, show all pharmacies
    _filteredPharmacies = _pharmacies;
    // Add listener to update filtered list on search input changes
    _searchController.addListener(_filterPharmacies);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPharmacies); // Clean up listener
    _searchController.dispose(); // Clean up controller
    super.dispose();
  }

  // Filter pharmacies based on search query (case-insensitive)
  void _filterPharmacies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPharmacies = _pharmacies; // Show all if query is empty
      } else {
        _filteredPharmacies = _pharmacies.where((pharmacy) {
          final nameLower = pharmacy['name'].toLowerCase();
          final addressLower = pharmacy['address'].toLowerCase();
          return nameLower.contains(query) || addressLower.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the prescription passed from PrescriptionsPage, if any
    final Map<String, dynamic>? prescription =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Pharmacies'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController, // Use the controller
              decoration: InputDecoration(
                hintText: 'Search pharmacies by name or address',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                // Add a clear button if text is entered
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear(); // Clear search field
                        },
                      )
                    : null,
              ),
              // No need for onChanged here as the listener handles it
            ),
          ),
          // List of Pharmacies
          Expanded(
            child: _filteredPharmacies.isEmpty
                ? const Center(
                    // Show message if no pharmacies match search
                    child: Text(
                      'No pharmacies found matching your search.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        16, 0, 16, 16), // Adjust padding
                    itemCount: _filteredPharmacies.length, // Use filtered list
                    itemBuilder: (context, index) {
                      final pharmacy = _filteredPharmacies[
                          index]; // Get pharmacy from filtered list
                      return Card(
                        // Display each pharmacy in a Card
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      pharmacy['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow
                                          .ellipsis, // Prevent overflow
                                    ),
                                  ),
                                  // Status Chip (Open/Closed)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: pharmacy['isOpen']
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      pharmacy['isOpen'] ? 'Open' : 'Closed',
                                      style: TextStyle(
                                        color: pharmacy['isOpen']
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Address Row
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      pharmacy['address'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow
                                          .ellipsis, // Prevent overflow
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Distance, Rating, Delivery Time Row
                              Row(
                                children: [
                                  const Icon(Icons.directions_walk_outlined,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    pharmacy['distance'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.star,
                                      size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${pharmacy['rating']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Spacer(), // Push time to the end
                                  const Icon(Icons.access_time,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    pharmacy['deliveryTime'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Action Buttons (View Details, Select)
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        // Placeholder: View pharmacy details action
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'View details for ${pharmacy['name']}')),
                                        );
                                        // In a real app, navigate to a PharmacyDetailsPage
                                      },
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(0, 45),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('View Details'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      // Disable button if pharmacy is closed
                                      onPressed: pharmacy['isOpen']
                                          ? () {
                                              // Navigate to OrderPage, passing pharmacy and prescription data
                                              Navigator.pushNamed(
                                                context,
                                                '/order',
                                                arguments: {
                                                  'pharmacy': pharmacy,
                                                  // Pass the prescription along if it exists
                                                  'prescription': prescription,
                                                },
                                              );
                                            }
                                          : null, // Setting onPressed to null disables the button
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(0, 45),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        // Grey out button visually when disabled
                                        backgroundColor: pharmacy['isOpen']
                                            ? Theme.of(context)
                                                .primaryColor // Use theme color when enabled
                                            : Colors.grey.shade300,
                                        foregroundColor: Colors
                                            .white, // Text color for enabled button
                                      ),
                                      child: const Text('Select'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// --- Order Page Widget ---
class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  // State variables for the order page
  final List<Map<String, dynamic>> _cart = []; // Holds items in the cart
  String _deliveryAddress =
      '123 Main Street, Apt 4B, Medicity'; // Default/Current address
  String _selectedPaymentMethod = 'Credit Card'; // Default payment method
  bool _isInitialized = false; // Flag to prevent adding Rx items multiple times

  // Random number generator for sample prices
  final Random _random = Random();
  double _getRandomPrice() {
    // Generates a price between 5.00 and 20.99 for realism
    return (_random.nextInt(16) + 5) + (_random.nextInt(100) / 100.0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize cart with prescription items only once when the page loads
    // or when dependencies change (like navigating back with arguments).
    if (!_isInitialized) {
      // Retrieve arguments passed to this page (pharmacy and prescription data)
      final Map<String, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final Map<String, dynamic>? prescription = args?['prescription'];

      // If a prescription was passed, add its medicines to the cart
      if (prescription != null && prescription['medicines'] is List) {
        for (var medicine in prescription['medicines']) {
          // Check if the medicine is already in the cart to avoid duplicates
          if (!_cart.any((item) => item['name'] == medicine['name'])) {
            _cart.add({
              'name': medicine['name'],
              'dosage':
                  medicine['dosage'] ?? '', // Handle potential null dosage
              'quantity': 1, // Default quantity
              'price': _getRandomPrice(), // Assign a random sample price
            });
          }
        }
      }
      _isInitialized = true; // Mark as initialized
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments again within the build method if needed
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final Map<String, dynamic>? pharmacy = args?['pharmacy'];
    final Map<String, dynamic>? prescription = args?['prescription'];

    return Scaffold(
      appBar: AppBar(
        // Display pharmacy name in title if available
        title: Text(pharmacy != null
            ? 'Order from ${pharmacy['name']}'
            : 'Order Medicines'),
      ),
      body: SingleChildScrollView(
        // Allows content to scroll if it exceeds screen height
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Prescription Details (if ordering from a specific Rx)
              if (prescription != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Using Prescription',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('ID: ${prescription['id']}'),
                      Text('Doctor: ${prescription['doctor']}'),
                      Text('Date: ${prescription['date']}'),
                    ],
                  ),
                ),
                // const SizedBox(height: 24), // Removed potentially redundant space
              ],

              // --- Cart Section ---
              const Text(
                'Your Cart',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_cart.isEmpty) // Show message if cart is empty
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'Your cart is empty. Select items from a pharmacy.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else // Display cart items if not empty
                ListView.builder(
                    shrinkWrap:
                        true, // Essential for ListView inside SingleChildScrollView
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable inner list scrolling
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return Card(
                        // Each cart item in a Card
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Item Icon
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.medication_outlined,
                                    color: Colors.blue),
                              ),
                              const SizedBox(width: 16),
                              // Item Name and Dosage
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      item['dosage'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity Controls (+/- buttons)
                              Row(
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        if (item['quantity'] > 1) {
                                          item[
                                              'quantity']--; // Decrease quantity
                                        } else {
                                          // Remove item if quantity becomes 0
                                          _cart.removeAt(index);
                                        }
                                      });
                                    },
                                    iconSize: 20,
                                    color: Colors.red.shade400,
                                    tooltip: 'Decrease quantity',
                                  ),
                                  Text(
                                    '${item['quantity']}', // Display current quantity
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        item['quantity']++; // Increase quantity
                                      });
                                    },
                                    iconSize: 20,
                                    color: Colors.green.shade600,
                                    tooltip: 'Increase quantity',
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              // Price (Total for this item line)
                              Text(
                                '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}', // Calculate total price for item * quantity
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              const SizedBox(height: 24),

              // --- Delivery Address Section ---
              _buildSectionTitle('Delivery Address'),
              Card(
                  margin: const EdgeInsets.only(top: 8, bottom: 24),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    // Using ListTile for cleaner layout
                    leading: const Icon(Icons.location_on_outlined,
                        color: Colors.blue),
                    title: Text(_deliveryAddress), // Display current address
                    trailing: TextButton(
                      // Button to change address
                      onPressed: _showAddressDialog,
                      child: const Text('Change'),
                    ),
                  )),

              // --- Payment Method Section ---
              _buildSectionTitle('Payment Method'),
              Card(
                margin: const EdgeInsets.only(top: 8, bottom: 24),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  // Radio buttons for payment options
                  children: [
                    RadioListTile<String>(
                      title: const Text('Credit Card'),
                      value: 'Credit Card',
                      groupValue:
                          _selectedPaymentMethod, // Currently selected value
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPaymentMethod =
                              value); // Update state on change
                        }
                      },
                      activeColor: Colors.blue,
                      secondary: const Icon(Icons.credit_card),
                    ),
                    RadioListTile<String>(
                      title: const Text('Cash on Delivery'),
                      value: 'Cash on Delivery',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPaymentMethod = value);
                        }
                      },
                      activeColor: Colors.blue,
                      secondary: const Icon(Icons.money),
                    ),
                    RadioListTile<String>(
                      title: const Text('Insurance'),
                      value: 'Insurance',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPaymentMethod = value);
                        }
                      },
                      activeColor: Colors.blue,
                      secondary: const Icon(Icons.health_and_safety_outlined),
                    ),
                  ],
                ),
              ),

              // --- Order Summary Section ---
              _buildSectionTitle('Order Summary'),
              Card(
                margin: const EdgeInsets.only(top: 8, bottom: 24),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    // Display subtotal, fees, tax, and total
                    children: [
                      _buildSummaryRow('Subtotal', _calculateSubtotal()),
                      _buildSummaryRow(
                          'Delivery Fee', 3.99), // Example fixed fee
                      _buildSummaryRow(
                          'Tax (8%)', _calculateTax()), // Indicate tax rate
                      const Divider(height: 24, thickness: 1), // Separator line
                      _buildSummaryRow('Total', _calculateTotal(),
                          isTotal: true), // Highlight total
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // --- Bottom Navigation Bar (Contains Place Order Button) ---
      bottomNavigationBar: Container(
        // Add padding to avoid overlap with system UI (like home indicator)
        padding: const EdgeInsets.all(16).copyWith(
            bottom:
                MediaQuery.of(context).padding.bottom + 16), // Handle safe area
        decoration: BoxDecoration(
          // Add shadow for visual separation
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, -3), // Shadow above the bar
            ),
          ],
        ),
        child: ElevatedButton(
          // Disable button if cart is empty
          onPressed: _cart.isEmpty
              ? null
              : () => _submitOrder(context, pharmacy,
                  prescription), // Pass context and args to submit function
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50), // Full width button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.blue, // Explicit button color
            foregroundColor: Colors.white, // Text color
            disabledBackgroundColor:
                Colors.grey.shade300, // Color when disabled
          ),
          child: const Text(
            'Place Order',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  // --- Helper Methods for Order Page ---

  // Show dialog to change the delivery address
  void _showAddressDialog() {
    final TextEditingController controller = TextEditingController(
        text: _deliveryAddress); // Pre-fill with current address
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Delivery Address'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter your full delivery address',
              border: OutlineInputBorder(),
            ),
            maxLines: 3, // Allow multi-line input
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  // Ensure address is not just whitespace
                  setState(() {
                    _deliveryAddress =
                        controller.text.trim(); // Update address state
                  });
                  Navigator.pop(context); // Close dialog
                } else {
                  // Optional: Show feedback if address is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Address cannot be empty')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Helper widget for consistent section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // Space below title
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper widget for rows in the order summary (label + amount)
  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    // Style differently if it's the total row
    final style = TextStyle(
      fontSize: isTotal ? 18 : 16,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: isTotal ? Colors.blue : Colors.black87,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: style.copyWith(
                  color: Colors.black87)), // Label always standard color
          Text('\$${amount.toStringAsFixed(2)}',
              style: style), // Format amount as currency
        ],
      ),
    );
  }

  // --- Calculation Methods ---
  double _calculateSubtotal() {
    // Sum the price * quantity for all items in the cart
    return _cart.fold(
        0.0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  double _calculateTax() {
    // Calculate tax based on subtotal (e.g., 8%)
    return _calculateSubtotal() * 0.08;
  }

  double _calculateTotal() {
    const double deliveryFee = 3.99; // Example delivery fee
    // Ensure total is non-negative, especially if cart becomes empty unexpectedly
    final subtotal = _calculateSubtotal();
    if (subtotal <= 0) return 0.0; // Return 0 if cart is empty
    // Total = Subtotal + Tax + Delivery Fee
    return subtotal + _calculateTax() + deliveryFee;
  }

  // --- Submit Order Logic (Simulated) ---
  void _submitOrder(BuildContext context, Map<String, dynamic>? pharmacy,
      Map<String, dynamic>? prescription) async {
    // Make async for Future.delayed
    // Show a loading indicator while "processing"
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing dialog by tapping outside
      builder: (context) => const Center(
        child: CircularProgressIndicator(), // Standard loading spinner
      ),
    );

    // Simulate network delay or order processing time
    await Future.delayed(const Duration(seconds: 2));

    // Close the loading dialog *before* showing SnackBar or navigating
    Navigator.pop(context); // Pops the loading dialog

    // Generate a simple unique order ID based on timestamp
    final String orderId =
        'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Show a success message using SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order #$orderId placed successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate to the tracking page, replacing the current order page
    // and potentially clearing history up to the home page.
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/track', // Route name for the tracking page
      ModalRoute.withName(
          '/'), // Remove routes until the home page ('/') is reached
      arguments: {
        // Pass order details to the tracking page
        'orderId': orderId,
        'items': List.from(_cart), // Pass a *copy* of the cart items
        'total': _calculateTotal(),
        'address': _deliveryAddress,
        'paymentMethod': _selectedPaymentMethod,
        'pharmacyName': pharmacy?['name'] ??
            'Selected Pharmacy', // Use actual name or default
      },
    );
  }
}

// --- Track Order Page Widget ---
class TrackOrderPage extends StatefulWidget {
  const TrackOrderPage({Key? key}) : super(key: key);

  @override
  _TrackOrderPageState createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  String _currentStatus = 'Order Received'; // Initial status display
  // Predefined status steps for the timeline
  final List<Map<String, dynamic>> _statusUpdates = [
    {
      'status': 'Order Received',
      'time': '', // Time will be updated dynamically
      'description': 'Your order details have been received by the pharmacy.',
      'completed': false, // Initially not completed
    },
    {
      'status': 'Preparing',
      'time': '',
      'description':
          'The pharmacy is gathering and preparing your medications.',
      'completed': false,
    },
    {
      'status': 'Ready for Delivery',
      'time': '',
      'description':
          'Your order is packed and waiting for the delivery partner.',
      'completed': false,
    },
    {
      'status': 'Out for Delivery',
      'time': '',
      'description': 'Your order is on its way to your address!',
      'completed': false,
    },
    {
      'status': 'Delivered',
      'time': '',
      'description': 'Your order has arrived. Thank you!',
      'completed': false,
    },
  ];

  Timer? _timer; // Timer for simulating status updates
  int _currentStatusIndex =
      -1; // Track the index of the current status (-1 before start)

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure ModalRoute is available after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startStatusSimulation();
    });
  }

  // Starts the simulation of order status updates
  void _startStatusSimulation() {
    if (!mounted) return; // Ensure widget is still mounted

    // Mark the first status as completed immediately
    _updateStatus(0);

    // Start a periodic timer to advance the status every few seconds
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (!mounted) {
        // Check if mounted within timer callback
        timer.cancel();
        return;
      }
      if (_currentStatusIndex < _statusUpdates.length - 1) {
        _currentStatusIndex++; // Move to the next status index
        _updateStatus(_currentStatusIndex); // Update the UI
      } else {
        _timer
            ?.cancel(); // Stop the timer when the last status ('Delivered') is reached
      }
    });
  }

  // Updates the state for a specific status index
  void _updateStatus(int index) {
    if (index < 0 || index >= _statusUpdates.length) return; // Bounds check

    final now = DateTime.now();
    // Format time as HH:MM AM/PM
    final formattedTime =
        "${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    setState(() {
      _statusUpdates[index]['time'] = formattedTime; // Set the completion time
      _statusUpdates[index]['completed'] = true; // Mark as completed
      _currentStatus = _statusUpdates[index]
          ['status']; // Update the overall current status display
      _currentStatusIndex = index; // Update the tracked index
    });
  }

  @override
  void dispose() {
    _timer
        ?.cancel(); // IMPORTANT: Always cancel timers in dispose to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments passed from OrderPage (or provide defaults)
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Safely access arguments with null checks and default values
    final String orderId = args?['orderId'] ?? 'N/A';
    final List<dynamic> items = args?['items'] ?? [];
    final double total = args?['total'] ?? 0.0;
    final String address = args?['address'] ?? 'Address not available';
    final String paymentMethod = args?['paymentMethod'] ?? 'N/A';
    final String pharmacyName = args?['pharmacyName'] ?? 'Pharmacy';
    // Determine expected delivery time (show actual time if delivered, otherwise estimate)
    final String expectedDeliveryTime = _statusUpdates.last['completed']
        ? _statusUpdates.last['time'] // Use the recorded delivery time
        : 'Estimating...'; // Placeholder while in progress

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order #$orderId'), // Show Order ID in title
      ),
      body: SingleChildScrollView(
        // Allow scrolling
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Order Status Card ---
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Pharmacy Name
                          Expanded(
                            // Allow pharmacy name to wrap if long
                            child: Text(
                              'Status from $pharmacyName',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Current Status Chip
                          Chip(
                            label: Text(_currentStatus),
                            backgroundColor: _currentStatus == 'Delivered'
                                ? Colors.green.shade100 // Green when delivered
                                : Colors.blue.shade100, // Blue otherwise
                            labelStyle: TextStyle(
                              color: _currentStatus == 'Delivered'
                                  ? Colors.green.shade800
                                  : Colors.blue.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Expected Delivery Time
                      Text(
                        'Delivery time: Today, $expectedDeliveryTime',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // --- Delivery Timeline ---
                      // Build the timeline using the helper function
                      for (int i = 0; i < _statusUpdates.length; i++)
                        _buildTimelineItem(
                          _statusUpdates[i],
                          isFirst: i == 0, // Mark the first item
                          isLast: i ==
                              _statusUpdates.length - 1, // Mark the last item
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Order Details Section ---
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                // Order details in a card
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Items List ---
                      const Text(
                        'Items:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      if (items.isEmpty) // Message if item data is missing
                        const Text('No items information available.')
                      else // Display list of items from the order
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index]
                                  as Map<String, dynamic>; // Cast item
                              // Safely access item details with defaults
                              final itemName = item['name'] ?? 'Unknown Item';
                              final itemDosage = item['dosage'] ?? '';
                              final itemQuantity = item['quantity'] ?? 0;
                              final itemPrice = item['price'] ?? 0.0;
                              final itemTotalPrice =
                                  (itemPrice * itemQuantity).toStringAsFixed(2);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Item details (Quantity x Name (Dosage))
                                    Expanded(
                                      child: Text(
                                        '$itemQuantity x $itemName ${itemDosage.isNotEmpty ? '($itemDosage)' : ''}',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    // Item total price
                                    Text(
                                      '\$$itemTotalPrice',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      const Divider(height: 24), // Separator

                      // --- Total Amount ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Paid',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}', // Format total as currency
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue, // Highlight total
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // --- Delivery Address ---
                      _buildDetailRow(
                          Icons.location_on_outlined,
                          'Delivery Address',
                          address), // Use helper for consistent layout
                      const SizedBox(height: 16),

                      // --- Payment Method ---
                      _buildDetailRow(
                        // Choose icon based on payment method
                        paymentMethod == 'Credit Card'
                            ? Icons.credit_card
                            : paymentMethod == 'Cash on Delivery'
                                ? Icons.money_outlined
                                : Icons
                                    .health_and_safety_outlined, // Icon for Insurance/Other
                        'Payment Method',
                        paymentMethod,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Help Button ---
              SizedBox(
                width: double.infinity, // Full width button
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Placeholder for help/support action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Contacting support... (Not implemented)'),
                      ),
                    );
                    // Could launch a chat, phone call, or help page URL
                  },
                  icon: const Icon(Icons.headset_mic_outlined),
                  label: const Text('Need Help?'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                        color: Theme.of(context).primaryColor), // Border color
                    foregroundColor:
                        Theme.of(context).primaryColor, // Text/Icon color
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Submit Review Button (Only show if order is Delivered) ---
              if (_currentStatus == 'Delivered')
                SizedBox(
                  width: double.infinity, // Full width button
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Placeholder for review action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Opening review form... (Not implemented)')),
                      );
                      // _launchReviewForm(); // Could launch a review form URL
                    },
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('Leave a Review'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor:
                          Colors.green, // Use green for positive action
                      foregroundColor: Colors.white, // White text/icon
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Methods for Track Order Page ---

  // Builds a styled row for displaying details like address or payment method
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title (e.g., "Delivery Address")
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black54, // Slightly muted title color
          ),
        ),
        const SizedBox(height: 6),
        // Value row with icon
        Row(
          children: [
            Icon(icon,
                size: 18, color: Colors.grey.shade600), // Icon for the detail
            const SizedBox(width: 8),
            Expanded(
              // Allow value text to wrap
              child: Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Builds each item (status update) in the vertical timeline
  Widget _buildTimelineItem(Map<String, dynamic> item,
      {required bool isFirst, required bool isLast}) {
    final bool isCompleted =
        item['completed'] ?? false; // Check if this status step is completed
    // Define colors based on completion status
    final Color activeColor = Colors.blue;
    final Color inactiveColor = Colors.grey.shade300;
    final Color lineColor = isCompleted ? activeColor : inactiveColor;
    final Color pointColor = isCompleted ? activeColor : inactiveColor;
    final Color textColor = isCompleted ? Colors.black87 : Colors.grey;
    final FontWeight fontWeight = isCompleted
        ? FontWeight.bold
        : FontWeight.normal; // Bolder text for completed steps

    return IntrinsicHeight(
      // Ensures the Row stretches vertically to contain the tallest element (the line)
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Make children stretch vertically
        children: [
          // --- Timeline Line and Point Column ---
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Top connector line (invisible for the first item)
              Container(
                width: 2,
                height: 10, // Space above the circle point
                color: isFirst
                    ? Colors.transparent
                    : lineColor, // Use calculated line color
              ),
              // Status point (circle)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    color: isCompleted
                        ? pointColor
                        : Colors
                            .white, // Fill color for completed, white otherwise
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: pointColor,
                        width: 2) // Border color reflects status
                    ),
                child: isCompleted // Show checkmark inside if completed
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              // Bottom connector line (invisible for the last item)
              Expanded(
                // Make the line fill the remaining vertical space
                child: Container(
                  width: 2,
                  color: isLast
                      ? Colors.transparent
                      : lineColor, // Use calculated line color
                ),
              ),
            ],
          ),
          const SizedBox(width: 16), // Space between line and text

          // --- Status Text Column ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 16), // Vertical padding around text
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment
                    .start, // Align text to the top near the point
                children: [
                  // Status Title (e.g., "Out for Delivery")
                  Text(
                    item['status'] ?? 'Unknown Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: fontWeight, // Use calculated font weight
                      color: textColor, // Use calculated text color
                    ),
                  ),
                  // Time (if available and completed)
                  if (item['time'] != null &&
                      item['time'].isNotEmpty &&
                      isCompleted) ...[
                    const SizedBox(height: 4),
                    Text(
                      item['time'],
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                  ],
                  // Description (if available)
                  if (item['description'] != null &&
                      item['description'].isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                      maxLines: 2, // Limit description lines
                      overflow: TextOverflow
                          .ellipsis, // Add ellipsis if text overflows
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Commented out: Example of launching an external URL for a review form ---
  // Future<void> _launchReviewForm() async {
  //   // Replace with your actual review form URL
  //   final Uri url = Uri.parse('https://forms.gle/YourReviewFormUrl');
  //   if (!await launchUrl(url)) {
  //      if (mounted) { // Check if widget is still mounted
  //        ScaffoldMessenger.of(context).showSnackBar(
  //          const SnackBar(content: Text('Could not open review form')),
  //        );
  //      }
  //   }
  // }
}

// --- Main function ---
// Entry point of the Flutter application
void main() {
  runApp(const PharmacyApp()); // Runs the main PharmacyApp widget
}
