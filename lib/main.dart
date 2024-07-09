import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'signin_page.dart';
import 'signup_page.dart';
import 'calculator_page.dart';
import 'connectivity_service.dart';
import 'battery_service.dart';
import 'theme_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Color(0xFF1E1E1E),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: themeService.themeMode,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    SignInPage(),
    SignUpPage(),
    CalculatorPage(),
    ContactsPage(),
  ];

  late ConnectivityService _connectivityService;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  final ScrollController _scrollController =
      ScrollController(); // Initialize scroll controller

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();
    _initConnectivity();
    BatteryService(); // Initialize battery service

    _connectivityService.onConnectivityChanged
        .listen((ConnectivityResult result) {
      print('Connectivity changed: $result'); // Debug print
      setState(() {
        _connectionStatus = result;
      });
      _showConnectivityToast(result);
    });
  }

  Future<void> _initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivityService.checkConnectivity();
    } catch (e) {
      print('Error checking connectivity: $e'); // Debug print
      result = ConnectivityResult.none;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = result;
    });
    _showConnectivityToast(result); // Show initial connectivity status
  }

  void _showConnectivityToast(ConnectivityResult result) {
    String message;
    switch (result) {
      case ConnectivityResult.none:
        message = "No Internet Connection";
        break;
      case ConnectivityResult.mobile:
        message = "Connected to Mobile Network";
        break;
      case ConnectivityResult.wifi:
        message = "Connected to Wi-Fi";
        break;
      default:
        message = "Connection Status: $result";
        break;
    }
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _onItemTapped(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile Picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Select from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a Picture'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        // Use pickedFile.path to display or upload the image
        // For now, just print the path
        print('Image selected: ${pickedFile.path}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator App'),
        backgroundColor: Color(0xFF00897B),
        actions: [
          IconButton(
            icon: Icon(themeService.themeMode == ThemeMode.light
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: () {
              themeService.toggleTheme();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Ensure no padding at all
          controller: _scrollController,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.teal,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30, // Adjusted radius for a smaller avatar
                    backgroundImage: AssetImage(
                        'assetes/image/val.jpg'), // Placeholder image
                  ),
                  SizedBox(height: 5), // Adjusted spacing
                  ElevatedButton(
                    onPressed: () {
                      _showImagePickerDialog(context);
                    },
                    child: const Text('Edit Profile Picture'),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Sign In'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.app_registration),
              title: Text('Sign Up'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text('Calculator'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
            ListTile(
              leading: Icon(Icons.contacts),
              title: Text('Contacts'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(3);
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Sign In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: 'Sign Up',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    PermissionStatus permission = await Permission.contacts.request();

    if (permission.isGranted) {
      Iterable<Contact> contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts.toList();
      });
    } else {
      Fluttertoast.showToast(
        msg: "Permission to access contacts was denied",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      backgroundColor: Colors.white, // Set background color to white
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          Contact contact = _contacts[index];
          return ListTile(
            title: Text(
              contact.displayName ?? 'No Name',
              style: TextStyle(
                  color: Colors.black), // Set title text color to black
            ),
            subtitle: Text(
              contact.phones?.map((e) => e.value).join(', ') ?? 'No Phone',
              style: TextStyle(
                  color: Colors.black), // Set subtitle text color to black
            ),
          );
        },
      ),
    );
  }
}
