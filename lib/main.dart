import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const BlogApp());
}

class BlogApp extends StatelessWidget {
  const BlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(child: Text('Blog App')),
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