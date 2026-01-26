/*Widget _buildVisibilitySettings() {
    final visibilityOptions = ['Public', 'Private', 'Invitation Only'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Visibility & Capacity'),
        _buildTextField(
          label: 'Guests Number',
          hint: 'e.g., 150',
          suffixIcon: Icons.people_alt_outlined,
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Visibility',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColor.blueFont,
                ),
              ),
              const SizedBox(height: 8),
              // Reusing the Tab/Segmented Button Style
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: visibilityOptions.map((option) {
                  final isSelected = _visibility == option;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _visibility = option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColor.primary : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColor.primary
                                  : AppColor.primary.withOpacity(0.2),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColor.primary.withOpacity(0.12),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              option,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColor.blueFont,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }*/