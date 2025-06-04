import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Sample user data - normally would come from a database or API
  final Map<String, dynamic> userData = {
    'name': 'Suresh PK',
    'email': 'suresh.pk@example.com',
    'phone': '+91 98765 43210',
    'dob': '15 May 1985',
    'bloodType': 'O+',
    'height': '175 cm',
    'weight': '72 kg',
    'allergies': ['Penicillin', 'Dust'],
    'medications': ['Metformin 500mg', 'Vitamin D3'],
    'emergencyContact': 'Priya K (Wife) - +91 98765 12345',
    'address': '123 Park Avenue, Koramangala, Bangalore - 560034',
    'lastCheckup': '23 Feb 2025',
    'memberSince': 'July 2023',
    'insuranceID': 'ABCPOL123456789',
    'doctor': 'Dr. Meera Shah',
  };

  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // Save logic would go here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Profile updated successfully!')),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildProfileDetails(),
            _buildMedicalDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Text(
              'SP',
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userData['name'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Member since ${userData['memberSince']}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickInfoCard(
                  'Blood', userData['bloodType'], Icons.bloodtype),
              _buildQuickInfoCard('Height', userData['height'], Icons.height),
              _buildQuickInfoCard(
                  'Weight', userData['weight'], Icons.monitor_weight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Personal Information'),
          _detailTile('Email', userData['email'], Icons.email, _isEditing),
          _detailTile('Phone', userData['phone'], Icons.phone, _isEditing),
          _detailTile(
              'Date of Birth', userData['dob'], Icons.calendar_today, false),
          _detailTile('Address', userData['address'], Icons.home, _isEditing),
          _detailTile('Emergency Contact', userData['emergencyContact'],
              Icons.emergency, _isEditing),
        ],
      ),
    );
  }

  Widget _buildMedicalDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Medical Information'),
          _detailTile(
              'Doctor', userData['doctor'], Icons.medical_services, false),
          _detailTile(
              'Last Checkup', userData['lastCheckup'], Icons.event, false),
          _detailTile('Insurance ID', userData['insuranceID'],
              Icons.health_and_safety, false),
          const SizedBox(height: 16),
          const Text(
            'Allergies',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          _buildChipList(userData['allergies']),
          const SizedBox(height: 16),
          const Text(
            'Current Medications',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          _buildChipList(userData['medications']),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to medical records
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('View Complete Medical Records'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Log out logic
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Log Out'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Expanded(
            child: Divider(
              indent: 16,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(String label, String value, IconData icon, bool editable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                editable
                    ? TextField(
                        controller: TextEditingController(text: value),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        enabled: _isEditing,
                      )
                    : Text(
                        value,
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipList(List<String> items) {
    return Wrap(
      spacing: 8,
      children: [
        // Spread the chips created from the items list.
        ...items.map((item) {
          return Chip(
            label: Text(item),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            deleteIcon: _isEditing ? const Icon(Icons.close, size: 16) : null,
            onDeleted: _isEditing
                ? () {
                    // Handle deletion logic
                  }
                : null,
          );
        }).toList(),
        // Add the ActionChip if in editing mode.
        if (_isEditing)
          ActionChip(
            avatar: const Icon(Icons.add, size: 16),
            label: const Text('Add'),
            onPressed: () {
              // Show dialog to add new item
            },
          ),
      ],
    );
  }

// This is how you would include it in the main.dart with a navigation bar
/*
class MedicalApp extends StatefulWidget {
  const MedicalApp({Key? key}) : super(key: key);

  @override
  _MedicalAppState createState() => _MedicalAppState();
}

class _MedicalAppState extends State<MedicalApp> {
  int _selectedIndex = 3; // Profile is selected by default
  
  final List<Widget> _pages = [
    const HomePage(),
    const AppointmentsPage(),
    const RecordsPage(),
    const ProfilePage(), // Our profile page
  ];
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Appointments'),
            NavigationDestination(icon: Icon(Icons.fact_check), label: 'Records'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
*/
}
