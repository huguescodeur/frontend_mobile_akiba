import 'package:akiba/views/auth/login/login_view.dart';
import 'package:akiba/views/auth/register/create_pin_view.dart';
import 'package:akiba/views/auth/register/register_view.dart';
import 'package:akiba/views/auth/register/verify_number_view.dart';
import 'package:akiba/views/budget/budget_view.dart';
import 'package:akiba/views/challenge/challenge_details_view.dart';
import 'package:akiba/views/challenge/create_challenge_view.dart';
import 'package:akiba/views/challenge/public_challenges_view.dart';
import 'package:akiba/views/community/create_group_view.dart';
import 'package:akiba/views/epargne/reports_view.dart';
import 'package:akiba/views/goals/create_goals_view.dart';
import 'package:akiba/views/goals/group_goals_view.dart';
import 'package:akiba/views/goals/personal_goals_view.dart';
import 'package:akiba/views/home/accueil_view.dart';
import 'package:akiba/views/home/community_view.dart';
import 'package:akiba/views/home/goals_view.dart';
import 'package:akiba/views/home/home_view.dart';
import 'package:akiba/views/home/main_view.dart';
import 'package:akiba/views/home/onboarding_view.dart';
import 'package:akiba/views/home/profile_view.dart';
import 'package:akiba/views/home/splash_view.dart';
import 'package:akiba/views/home/statistics_view.dart';
import 'package:akiba/views/home/verify_pin_view.dart';
import 'package:akiba/views/home/wallet_screen.dart';
import 'package:akiba/views/notifications/notification_settings_view.dart';
import 'package:akiba/views/notifications/notifications_view.dart';
import 'package:akiba/views/profile/edit_profile_view.dart';
import 'package:akiba/views/settings/about_view.dart';
import 'package:akiba/views/settings/security_view.dart';
import 'package:akiba/views/settings/settings_view.dart';
import 'package:akiba/views/solifonds/solifonds_view.dart';
import 'package:akiba/views/transactions/deposit_view.dart';
import 'package:akiba/views/transactions/transactions_view.dart';
import 'package:akiba/views/transactions/transfer_view.dart';
import 'package:akiba/views/transactions/withdraw_view.dart';
import 'package:akiba/views/vault/vault_view.dart';
import 'package:flutter/material.dart';

Map<String, Widget Function(BuildContext)> routes = {
  // ? Auth
  SplashView.idView: (context) => const SplashView(),
  OnboardingView.idView: (context) => OnboardingView(),
  LoginView.idView: (context) => LoginView(),
  RegisterView.idView: (context) => RegisterView(),
  VerifyNumberView.idView: (context) => VerifyNumberView(),
  CreatePinView.idView: (context) => CreatePinView(),
  VerifyPinView.idView: (context) => VerifyPinView(),

  // ? View Principale
  AccueilView.idView: (context) => AccueilView(),
  // HomeView.idView: (context) => HomeView(),
  MainView.idView: (context) => MainView(),
  DepositView.idView: (context) => DepositView(),
  WithdrawView.idView: (context) => WithdrawView(),
  StatisticsView.idView: (context) => StatisticsView(),
  CommunityView.idView: (context) => CommunityView(),
  GoalsView.idView: (context) => GoalsView(),
  ProfileView.idView: (context) => ProfileView(),
  TransferView.idView: (context) => TransferView(),
  VaultView.idView: (context) => VaultView(),
  NotificationsView.idView: (context) => NotificationsView(),

  // ? Détails View
  ChallengeDetailsView.idView: (context) => ChallengeDetailsView(),
  TransactionsView.idView: (context) => TransactionsView(),
  AboutView.idView: (context) => AboutView(),
  NotificationSettingsView.idView: (context) => NotificationSettingsView(),
  ReportsView.idView: (context) => ReportsView(),
  SecurityView.idView: (context) => SecurityView(),
  EditProfileView.idView: (context) => EditProfileView(),
  CreateChallengeView.idView: (context) => CreateChallengeView(),
  CreateGoalsView.idView: (context) => CreateGoalsView(),
  BudgetView.idView: (context) => BudgetView(),
  GroupGoalsView.idView: (context) => GroupGoalsView(),
  PersonalGoalsView.idView: (context) => PersonalGoalsView(),
  SolifondsView.idView: (context) => SolifondsView(),
  CreateGroupView.idView: (context) => CreateGroupView(),
  PublicChallengesView.idView: (context) => PublicChallengesView(),
  SettingsView.idView: (context) => SettingsView(),

  WalletTestScreen.idView: (context) => WalletTestScreen(),
};
