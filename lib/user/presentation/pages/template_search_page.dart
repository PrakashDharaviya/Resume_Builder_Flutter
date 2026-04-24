import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resumebuilder/core/constants/app_colors.dart';
import 'package:resumebuilder/core/constants/app_routes.dart';
import 'package:resumebuilder/core/services/template_search_service.dart';
import 'package:resumebuilder/core/utils/app_preferences.dart';
import 'package:resumebuilder/features/admin/domain/entities/resume_template.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:resumebuilder/features/auth/presentation/bloc/auth_state.dart';
import 'package:resumebuilder/features/resume/domain/entities/resume.dart';
import 'package:resumebuilder/injection_container.dart' as di;
import 'package:resumebuilder/user/presentation/widgets/template_card.dart';

class TemplateSearchPage extends StatefulWidget {
  const TemplateSearchPage({super.key});

  @override
  State<TemplateSearchPage> createState() => _TemplateSearchPageState();
}

class _TemplateSearchPageState extends State<TemplateSearchPage> {
  final _searchController = TextEditingController();
  final _searchService = di.sl<TemplateSearchService>();

  List<ResumeTemplate> _searchResults = [];
  SearchRecommendation? _aiRecommendation;
  bool _isSearching = false;
  bool _isLoadingAI = false;
  bool _hasSearched = false;
  Timer? _debounce;

  static const List<String> _popularSearches = [
    'BCA',
    'MCA',
    'BCom',
    'MBA',
    'BTech',
    'BSc',
    'BA',
    'BBA',
    'Software Developer',
    'Accountant',
    'Teacher',
    'Designer',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _aiRecommendation = null;
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    // Search templates by tags (fast)
    final results = await _searchService.searchTemplates(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }

    // Get AI recommendation (async, may take a moment)
    setState(() => _isLoadingAI = true);
    final recommendation = await _searchService.getAIRecommendation(query);
    if (mounted) {
      setState(() {
        _aiRecommendation = recommendation;
        _isLoadingAI = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Search Templates',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, themeMode, _) {
              final isDarkMode =
                  themeMode == ThemeMode.dark ||
                  (themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);
              return IconButton(
                icon: Icon(
                  isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
                onPressed: () {
                  themeNotifier.value =
                      isDarkMode ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111827) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText:
                        'Search by degree or profession (e.g. BCA, MBA, Developer...)',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF10B981),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1F2937)
                        : const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF10B981),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                // Popular search chips
                if (!_hasSearched) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _popularSearches.length,
                      separatorBuilder: (_, _a) => const SizedBox(width: 6),
                      itemBuilder: (_, index) {
                        final tag = _popularSearches[index];
                        return ActionChip(
                          label: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFFD1D5DB)
                                  : const Color(0xFF374151),
                            ),
                          ),
                          backgroundColor: isDark
                              ? const Color(0xFF1F2937)
                              : const Color(0xFFF3F4F6),
                          side: BorderSide(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.25),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            _searchController.text = tag;
                            _searchController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(offset: tag.length),
                                );
                            _performSearch(tag);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Results
          Expanded(
            child: _buildBody(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF10B981)),
            SizedBox(height: 16),
            Text('Searching templates...'),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return _buildEmptyState(isDark);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // AI Recommendation Card
        if (_isLoadingAI)
          _buildAILoadingCard(isDark)
        else if (_aiRecommendation != null)
          _buildAIRecommendationCard(context, isDark),

        // Search Results Header
        if (_hasSearched) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                _searchResults.isEmpty
                    ? 'No matching templates found'
                    : '${_searchResults.length} template${_searchResults.length == 1 ? '' : 's'} found',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const Spacer(),
              if (_searchResults.isNotEmpty)
                Text(
                  'for "${_searchController.text}"',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Template Grid
        if (_searchResults.isNotEmpty)
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final isPremiumUser =
                  authState is AuthAuthenticated
                      ? authState.user.isPremium
                      : false;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount =
                      constraints.maxWidth > 900
                          ? 4
                          : constraints.maxWidth > 600
                          ? 3
                          : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final template = _searchResults[index];
                      final locked = template.isPremium && !isPremiumUser;

                      return TemplateCard(
                        template: template,
                        locked: locked,
                        onTap: () {
                          if (locked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Premium template. Upgrade required.',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.resumeEditor,
                            arguments: {
                              'templateType': template.templateType,
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),

        // Show all templates button when no results
        if (_searchResults.isEmpty && _hasSearched) ...[
          const SizedBox(height: 20),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.templateSelection);
              },
              icon: const Icon(Icons.style_rounded),
              label: const Text('Browse All Templates'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
                side: const BorderSide(color: Color(0xFF10B981)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              size: 48,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Search by Degree or Profession',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type BCA, MCA, MBA, Software Developer, etc.\nto find matching resume templates',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color:
                  isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: isDark
                    ? const Color(0xFF34D399)
                    : const Color(0xFF10B981),
              ),
              const SizedBox(width: 6),
              Text(
                'Powered by Gemini AI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF34D399)
                      : const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAILoadingCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF064E3B), const Color(0xFF065F46)]
              : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI is analyzing your search...',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark ? Colors.white : const Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Getting skill suggestions & professional summary',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xFF6EE7B7)
                        : const Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendationCard(BuildContext context, bool isDark) {
    final rec = _aiRecommendation!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF064E3B), const Color(0xFF065F46)]
              : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Recommendation',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color:
                            isDark ? Colors.white : const Color(0xFF065F46),
                      ),
                    ),
                    if (rec.fieldDescription.isNotEmpty)
                      Text(
                        rec.fieldDescription,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFF6EE7B7)
                              : const Color(0xFF047857),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Recommended template type
          Row(
            children: [
              Icon(
                Icons.style_rounded,
                size: 14,
                color: isDark
                    ? const Color(0xFF6EE7B7)
                    : const Color(0xFF047857),
              ),
              const SizedBox(width: 6),
              Text(
                'Best template: ',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF6EE7B7)
                      : const Color(0xFF047857),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ResumeTemplate.templateTypeLabel(
                    rec.recommendedTemplateType,
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF34D399)
                        : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),

          // Suggested Skills
          if (rec.suggestedSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Suggested Skills for Resume',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF065F46),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: rec.suggestedSkills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1F2937)
                        : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          const Color(0xFF10B981).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFD1D5DB)
                          : const Color(0xFF374151),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Suggested Summary
          if (rec.suggestedSummary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Suggested Professional Summary',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF065F46),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1F2937)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                rec.suggestedSummary,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? const Color(0xFFD1D5DB)
                      : const Color(0xFF374151),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Build with AI Suggestions Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                final userId = authState is AuthAuthenticated ? authState.user.uid : 'guest';

                String firstName = '';
                String lastName = '';
                String email = '';

                if (authState is AuthAuthenticated) {
                  final nameParts = authState.user.displayName.trim().split(' ');
                  firstName = nameParts.isNotEmpty ? nameParts.first : '';
                  if (nameParts.length > 1) {
                    lastName = nameParts.sublist(1).join(' ');
                  }
                  email = authState.user.email;
                }

                final newResume = Resume(
                  id: 'resume_${DateTime.now().millisecondsSinceEpoch}',
                  userId: userId,
                  title: '${_searchController.text.trim()} Resume',
                  personalInfo: PersonalInfo(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    summary: rec.suggestedSummary,
                  ),
                  skills: rec.suggestedSkills.map((s) => Skill(
                    id: 'skill_${DateTime.now().microsecondsSinceEpoch}_${s.hashCode}',
                    name: s,
                    proficiency: 'Intermediate',
                  )).toList(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  templateType: rec.recommendedTemplateType,
                );

                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.resumeEditor,
                  arguments: {
                    'resume': newResume,
                    'templateType': rec.recommendedTemplateType,
                  },
                );
              },
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text(
                'Start Resume with these AI Suggestions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
