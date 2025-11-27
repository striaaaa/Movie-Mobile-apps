import 'package:flutter/material.dart';
import 'package:movie_browser_app/screens/favorite_screen.dart';
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Movie Browser',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode:
                themeProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
            home: const MainNavigation(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final Color primaryColor = const Color(0xFF199EF3);

    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor.withOpacity(0.8),
      ),
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge:
            TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        displayMedium:
            TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        displaySmall:
            TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        headlineMedium:
            TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        headlineSmall:
            TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        titleLarge:
            TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        titleMedium:
            TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
        titleSmall:
            TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
        bodyLarge:
            TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400),
        bodyMedium:
            TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400),
        bodySmall:
            TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final Color primaryColor = const Color(0xFF199EF3);

    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF199EF3),
        secondary: Color(0xFF199EF3),
        surface: Color(0xFF121212),
        background: Color(0xFF121212),
      ),
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Colors.white),
        displayMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white),
        displaySmall: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white),
        headlineMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white),
        headlineSmall: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white),
        titleLarge: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white),
        titleMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Colors.white),
        titleSmall: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Colors.white),
        bodyLarge: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Colors.white),
        bodyMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Colors.white70),
        bodySmall: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Colors.white60),
      ),
    );
  }
}

// MainNavigation
class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThemeProvider>().loadThemePreference();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF199EF3);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins'),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
