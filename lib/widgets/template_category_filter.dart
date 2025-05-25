import 'package:flutter/material.dart';
import '../models/resume_template.dart';

class TemplateCategoryFilter extends StatefulWidget {
  final Function(List<ResumeTemplate>) onFilterChanged;
  final String selectedCategory;

  const TemplateCategoryFilter({
    super.key,
    required this.onFilterChanged,
    this.selectedCategory = 'all',
  });

  @override
  State<TemplateCategoryFilter> createState() => _TemplateCategoryFilterState();
}

class _TemplateCategoryFilterState extends State<TemplateCategoryFilter> {
  String _selectedCategory = 'all';

  final Map<String, String> _categories = {
    'all': 'Semua Template',
    'business': 'Business & Corporate',
    'creative': 'Creative & Design',
    'tech': 'Technology & IT',
    'healthcare': 'Healthcare & Medical',
    'finance': 'Finance & Banking',
    'legal': 'Legal & Law',
    'academic': 'Academic & Research',
  };

  final Map<String, List<String>> _categoryTemplates = {
    'business': ['professional', 'executive', 'consulting', 'luxury'],
    'creative': ['creative', 'designer', 'marketing', 'modern'],
    'tech': ['technical', 'tech_startup', 'minimal'],
    'healthcare': ['healthcare', 'academic'],
    'finance': ['finance', 'professional'],
    'legal': ['legal', 'professional'],
    'academic': ['academic', 'minimal'],
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories.keys.elementAt(index);
          final label = _categories[category]!;
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
                _filterTemplates(category);
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _filterTemplates(String category) {
    List<ResumeTemplate> filteredTemplates;

    if (category == 'all') {
      filteredTemplates = ResumeTemplates.all;
    } else {
      final templateIds = _categoryTemplates[category] ?? [];
      filteredTemplates = ResumeTemplates.all
          .where((template) => templateIds.contains(template.id))
          .toList();
    }

    widget.onFilterChanged(filteredTemplates);
  }
}
