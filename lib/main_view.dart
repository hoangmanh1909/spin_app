import 'package:flutter/material.dart';
import 'package:spin_app/lucky_wheel_screen.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    LuckyWheelScreen(),
    LuckyWheelScreen(),
    LuckyWheelScreen(),
  ];

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<BottomNavigationBarItem> _buildButtonBar() {
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home_filled),
        label: 'Trang chủ',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.folder_open_rounded),
        label: 'Thư viện',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.whatshot_rounded),
        label: 'Streak',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: _buildButtonBar(),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        backgroundColor: const Color.fromARGB(255, 244, 219, 27),
        onTap: _onItemTapped,
      ),
    );
  }
}
