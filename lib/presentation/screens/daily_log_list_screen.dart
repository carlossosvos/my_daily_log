import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:my_daily_log/core/router/app_route.dart';
import 'package:my_daily_log/presentation/bloc/auth/auth_bloc.dart';
import 'package:my_daily_log/presentation/bloc/auth/auth_event.dart';
import 'package:my_daily_log/presentation/bloc/auth/auth_state.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_bloc.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_event.dart';
import 'package:my_daily_log/presentation/bloc/daily_log/daily_log_state.dart';
import 'package:my_daily_log/presentation/widgets/bottom_sheets/add_log_bottom_sheet.dart';
import 'package:my_daily_log/presentation/widgets/organisms/daily_log_card.dart';

class DailyLogListScreen extends StatelessWidget {
  const DailyLogListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Daily Log'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          // Check authentication first
          if (authState is! AuthAuthenticated) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), SizedBox(height: 16)],
              ),
            );
          }

          // User is authenticated, now show the logs
          return BlocBuilder<DailyLogBloc, DailyLogState>(
            builder: (context, state) {
              if (state is DailyLogLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is DailyLogError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.read<DailyLogBloc>().add(
                            const LoadDailyLogs(),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is DailyLogLoaded) {
                if (state.logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No logs yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap the + button to create your first log',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SlidableAutoCloseBehavior(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<DailyLogBloc>().add(const SyncDailyLogs());
                      // Wait a bit for the bloc to process
                      await Future<void>.delayed(
                        const Duration(milliseconds: 700),
                      );
                    },
                    child: ListView.builder(
                      itemCount: state.logs.length,
                      itemBuilder: (context, index) {
                        final log = state.logs[index];
                        return DailyLogCard(
                          log: log,

                          onTap: () {
                            context.push(AppRoutes.logDetailWithId(log.id));
                          },
                        );
                      },
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AddLogBottomSheet(),
            );
          },
          tooltip: 'Add Log',
          backgroundColor: Colors.black87,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
