import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import 'package:wattwise_app/feature/auth/widgets/cta_button.dart';
import 'package:wattwise_app/feature/on_boarding/model/appliance_model.dart';
import 'package:wattwise_app/feature/on_boarding/model/on_boarding_state.dart';
import 'package:wattwise_app/feature/on_boarding/provider/on_boarding_page_5_notifier.dart';
import 'package:wattwise_app/feature/on_boarding/provider/selected_appliance_notifier.dart';
import 'package:wattwise_app/feature/profile/provider/manage_appliances_provider.dart';
import 'package:wattwise_app/feature/profile/screens/add_appliance_screen.dart';

class ManageAppliancesScreen extends ConsumerStatefulWidget {
  const ManageAppliancesScreen({super.key});

  @override
  ConsumerState<ManageAppliancesScreen> createState() =>
      _ManageAppliancesScreenState();
}

class _ManageAppliancesScreenState
    extends ConsumerState<ManageAppliancesScreen> {
  bool _isSaving = false;

  Widget _buildLevelButton(
    WidgetRef ref,
    ApplianceModel app,
    LevelOption option,
    ApplianceLocalState state,
  ) {
    final isSelected = state.usageLevel == option.label;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: () => ref
            .read(onBoardingPage5Provider.notifier)
            .updateUsageLevel(app, option.label),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                option.label,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                option.duration,
                style: GoogleFonts.poppins(
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncInit = ref.watch(manageAppliancesInitProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Manage Appliances',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddApplianceScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF5568FE),
            ),
            tooltip: 'Add Appliance',
          ),
        ],
      ),
      body: SafeArea(
        child: asyncInit.when(
          data: (_) {
            final selectedAppliances = ref.watch(selectedAppliancesProvider);
            ref.watch(onBoardingPage5Provider); // Watch local states
            final notifier = ref.read(onBoardingPage5Provider.notifier);
            final width = MediaQuery.sizeOf(context).width;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.05,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Appliances',
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Edit usage, quantities and adjust appliance details below.',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (selectedAppliances.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.devices_other,
                                    size: 64,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No appliances in your profile.\nClick the + icon to add some!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...selectedAppliances.map((app) {
                            final state = notifier.getOrInitState(app);
                            final options = notifier.getUsageOptions(app);
                            final dropdownConfigs = notifier.getDropdownConfigs(
                              app,
                            );
                            const primaryColor = Color(0xFF5568FE);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[40],
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.015),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF0FF),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: SvgPicture.asset(
                                          app.svgPath,
                                          colorFilter: const ColorFilter.mode(
                                            primaryColor,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          app.title,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () {
                                          ref
                                              .read(
                                                selectedAppliancesProvider
                                                    .notifier,
                                              )
                                              .toggleAppliance(app);
                                        },
                                        tooltip: 'Remove',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: options
                                        .map(
                                          (opt) => _buildLevelButton(
                                            ref,
                                            app,
                                            opt,
                                            state,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  const SizedBox(height: 20),
                                  Divider(
                                    color: Colors.grey.shade200,
                                    height: 1,
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => notifier.toggleExpanded(app),
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'More details',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Icon(
                                          state.isExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: Colors.grey.shade500,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (state.isExpanded) ...[
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Number of ${app.title}s'.replaceAll(
                                            'ss',
                                            's',
                                          ),
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              InkWell(
                                                onTap: () =>
                                                    notifier.updateCount(
                                                      app,
                                                      state.count - 1,
                                                    ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 16,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                                child: Text(
                                                  '${state.count}',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () =>
                                                    notifier.updateCount(
                                                      app,
                                                      state.count + 1,
                                                    ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: const BoxDecoration(
                                                    color: primaryColor,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                7,
                                                              ),
                                                          bottomRight:
                                                              Radius.circular(
                                                                7,
                                                              ),
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    size: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (dropdownConfigs.isNotEmpty) ...[
                                      const SizedBox(height: 20),
                                      Row(
                                        children: dropdownConfigs.map((config) {
                                          final isLast =
                                              config == dropdownConfigs.last;
                                          return Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                right: isLast ? 0 : 12,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    config.label,
                                                    style: GoogleFonts.poppins(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 10,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey
                                                            .shade200,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      color: Colors.white,
                                                    ),
                                                    child: DropdownButtonHideUnderline(
                                                      child: DropdownButton<String>(
                                                        isExpanded: true,
                                                        value:
                                                            state
                                                                .selectedDropdowns[config
                                                                .label] ??
                                                            config
                                                                .options
                                                                .first,
                                                        icon: Icon(
                                                          Icons.unfold_more,
                                                          size: 16,
                                                          color: Colors
                                                              .grey
                                                              .shade500,
                                                        ),
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 14,
                                                            ),
                                                        onChanged: (val) {
                                                          if (val != null) {
                                                            notifier
                                                                .updateDropdown(
                                                                  app,
                                                                  config.label,
                                                                  val,
                                                                );
                                                          }
                                                        },
                                                        items: config.options.map((
                                                          opt,
                                                        ) {
                                                          return DropdownMenuItem<
                                                            String
                                                          >(
                                                            value: opt,
                                                            child: Text(opt),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: _isSaving
                        ? Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: Colors.white60,
                                child: Text(
                                  'Saving...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isSaving = true;
                              });
                              try {
                                await notifier.finishSetup(selectedAppliances);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Appliances updated successfully!',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(context); // back to profile
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error saving: $e',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isSaving = false;
                                  });
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Save Changes',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
          loading: () => ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          ),
          error: (e, st) => Center(
            child: Text(
              'Failed to load appliances:\n$e',
              style: GoogleFonts.poppins(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
