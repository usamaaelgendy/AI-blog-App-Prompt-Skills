import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/bookmarks/presentation/bloc/bookmark_toggle_bloc.dart';
import 'features/bookmarks/presentation/screens/bookmarks_screen.dart';
import 'features/posts/presentation/screens/posts_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  initDependencies();

  runApp(const BlogApp());
}

class BlogApp extends StatelessWidget {
  const BlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookmarkToggleBloc>(),
      child: MaterialApp(
        title: 'Blog App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    PostsListScreen(),
    BookmarksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
        ],
      ),
    );
  }
}

// 1 - Role
//    -  Your are a senior flutter developer specialied with clean arhctecture
// 2 - Context
//    - You are working on a flutter blog app using supabase as the backend.
//    - Archtecture: Clean Archtecture with 3 layers (data, domain, persentation)
// 3 - Tasks
//    - Add Search screen functionallity in PostListScreen
//    - Implement Search functionality using supabase search method
//    - Search Result must be show in the existing ListView
// 4 - Contraints
//    - Follow the same error handling
//    - Use the same theme and design system
//    - Don't Add new Packages

// <role>
// Your are a senior flutter developer specialied with clean arhctecture
// </role>
// <context>
//     You are working on a flutter blog app using supabase as the backend.
//     Archtecture: Clean Archtecture with 3 layers (data, domain, persentation)
// </context>
//
// <tasks>
//    - Add Search screen functionallity in PostListScreen
//    - Implement Search functionality using supabase search method
//    - Search Result must be show in the existing ListView
// </tasks>
//
//     <constraints>
//         - Follow the same error handling
//         - Use the same theme and design system
//         - Don't Add new Packages
//     </constraints>
//
// <error>
// null pointer exception stack overflow
// </error>
