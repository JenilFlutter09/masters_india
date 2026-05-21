import 'package:flutter/material.dart';

class SearchableOption<T> {
  const SearchableOption({required this.value, required this.label});

  final T value;
  final String label;
}

class SearchableFormField<T> extends StatelessWidget {
  const SearchableFormField({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.validator,
    this.hintText,
    this.emptyText,
    super.key,
  });

  final String label;
  final List<SearchableOption<T>> options;
  final T? value;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final String? hintText;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FormField<T>(
        key: ValueKey('$label-$value-${options.length}'),
        initialValue: value,
        validator: validator,
        builder: (field) {
          final selectedOption = options
              .cast<SearchableOption<T>?>()
              .firstWhere(
                (option) => option?.value == field.value,
                orElse: () => null,
              );

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () async {
              final result = await _showSearchableOptionsSheet<T>(
                context: context,
                title: label,
                options: options,
                selectedValue: field.value,
                hintText: hintText,
                emptyText: emptyText,
              );

              if (result == null) {
                return;
              }

              field.didChange(result.value);
              onChanged(result.value);
            },
            child: InputDecorator(
              isEmpty: selectedOption == null,
              decoration: InputDecoration(
                labelText: label,
              //  hintText: hintText,
                errorText: field.errorText,
                suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
              ),
              child: Text(
                selectedOption?.label ?? '',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selectedOption == null
                      ? Theme.of(context).hintColor
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchSheetResult<T> {
  const _SearchSheetResult(this.value);

  final T? value;
}

Future<_SearchSheetResult<T>?> _showSearchableOptionsSheet<T>({
  required BuildContext context,
  required String title,
  required List<SearchableOption<T>> options,
  required T? selectedValue,
  String? hintText,
  String? emptyText,
}) {
  final theme = Theme.of(context);
  return showModalBottomSheet<_SearchSheetResult<T>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      var query = '';
      return FractionallySizedBox(
        heightFactor: 0.78,
        child: StatefulBuilder(
          builder: (context, setState) {
            final filteredOptions = options
                .where(
                  (option) =>
                      option.label.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();

            return Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Select $title',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: hintText ?? 'Search $title',
                        prefixIcon: const Icon(Icons.search_rounded),
                      ),
                      onChanged: (value) => setState(() => query = value),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: filteredOptions.isEmpty
                          ? Center(
                              child: Text(
                                emptyText ?? 'No matching options found.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredOptions.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final option = filteredOptions[index];
                                final isSelected =
                                    option.value == selectedValue;
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () => Navigator.of(
                                      context,
                                    ).pop(_SearchSheetResult<T>(option.value)),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.colorScheme.primaryContainer
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: theme.dividerColor,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              option.label,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: isSelected
                                                        ? FontWeight.w700
                                                        : FontWeight.w500,
                                                  ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: theme.colorScheme.primary,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => Navigator.of(
                          context,
                        ).pop(_SearchSheetResult<T>(null)),
                        icon: const Icon(Icons.clear_rounded),
                        label: const Text('Clear Selection'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
