import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? _name;
  String? _email;
  String? _phone;
  DateTime? _appointmentDate;
  TimeOfDay? _appointmentTime;
  String? _symptoms;
  String _gender = 'Male';
  String _doctorSpeciality = 'General Physician';

  // Dropdown options
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _specialityOptions = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Orthopedic',
    'Pediatrician',
    'Neurologist',
    'Psychiatrist',
    'Ophthalmologist'
  ];

  // Google Form URL - Replace with your actual form URL
  final String _googleFormUrl =
      "https://docs.google.com/forms/d/e/YOUR_FORM_ID/formResponse";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _appointmentDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _appointmentDate) {
      setState(() {
        _appointmentDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _appointmentTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _appointmentTime) {
      setState(() {
        _appointmentTime = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Format date and time for Google Form
      String formattedDate = _appointmentDate != null
          ? DateFormat('yyyy-MM-dd').format(_appointmentDate!)
          : '';

      String formattedTime = _appointmentTime != null
          ? '${_appointmentTime!.hour}:${_appointmentTime!.minute.toString().padLeft(2, '0')}'
          : '';

      // Construct form submission URL with query parameters
      // The 'entry.XXXXXXX' parts need to be replaced with your actual Google Form entry IDs
      final Uri url = Uri.parse('$_googleFormUrl?'
          'entry.111111=${Uri.encodeComponent(_name ?? '')}'
          '&entry.222222=${Uri.encodeComponent(_email ?? '')}'
          '&entry.333333=${Uri.encodeComponent(_phone ?? '')}'
          '&entry.444444=${Uri.encodeComponent(_gender)}'
          '&entry.555555=${Uri.encodeComponent(formattedDate)}'
          '&entry.666666=${Uri.encodeComponent(formattedTime)}'
          '&entry.777777=${Uri.encodeComponent(_doctorSpeciality)}'
          '&entry.888888=${Uri.encodeComponent(_symptoms ?? '')}');

      // Open URL in browser to submit form
      if (await canLaunchUrl(url)) {
        await launchUrl(url);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment booked successfully!')),
          );
          // Reset form
          _formKey.currentState!.reset();
          setState(() {
            _appointmentDate = null;
            _appointmentTime = null;
            _gender = 'Male';
            _doctorSpeciality = 'General Physician';
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to submit form. Please try again.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Doctor Appointment'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Information Section
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Name field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value,
                ),
                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Basic email validation
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value,
                ),
                const SizedBox(height: 16),

                // Phone field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                  onSaved: (value) => _phone = value,
                ),
                const SizedBox(height: 16),

                // Gender dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  value: _gender,
                  items: _genderOptions.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _gender = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Appointment Details Section
                const Text(
                  'Appointment Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Date picker
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Appointment Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _appointmentDate != null
                          ? DateFormat('yyyy-MM-dd').format(_appointmentDate!)
                          : 'Select Date',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time picker
                InkWell(
                  onTap: () => _selectTime(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Appointment Time',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    child: Text(
                      _appointmentTime != null
                          ? '${_appointmentTime!.hour}:${_appointmentTime!.minute.toString().padLeft(2, '0')}'
                          : 'Select Time',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Doctor speciality dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Doctor Speciality',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.medical_services),
                  ),
                  value: _doctorSpeciality,
                  items: _specialityOptions.map((String speciality) {
                    return DropdownMenuItem<String>(
                      value: speciality,
                      child: Text(speciality),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _doctorSpeciality = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Symptoms field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Symptoms/Reason for Visit',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note_alt),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  onSaved: (value) => _symptoms = value,
                ),
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'BOOK APPOINTMENT',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
