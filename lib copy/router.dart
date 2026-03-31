import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_shell.dart';
import 'screens/home/home_screen.dart';
import 'screens/listings/listings_screen.dart';
import 'screens/listings/listing_detail_screen.dart';
import 'screens/listings/create_listing_screen.dart';
import 'screens/messages/messages_screen.dart';
import 'screens/messages/chat_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/notifications/notifications_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/listings',
          builder: (context, state) => const ListingsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => ListingDetailScreen(
                listingId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/create-listing',
          builder: (context, state) => const CreateListingScreen(),
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) => const MessagesScreen(),
          routes: [
            GoRoute(
              path: ':chatId',
              builder: (context, state) => ChatScreen(
                chatId: state.pathParameters['chatId']!,
                recipientName: state.extra as String? ?? 'User',
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => const EditProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
    ),
  ],
);
