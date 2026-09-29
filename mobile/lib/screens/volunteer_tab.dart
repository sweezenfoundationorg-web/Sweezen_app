import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_gold_button.dart';

class VolunteerTab extends StatefulWidget {
  const VolunteerTab({super.key});

  @override
  State<VolunteerTab> createState() => _VolunteerTabState();
}

class _VolunteerTabState extends State<VolunteerTab> {
  String _taskFilter = 'All'; // All, Pending, In Progress, Completed

  void _showTaskReportModal(BuildContext context, TaskModel task, AppStateProvider state) {
    final remarksController = TextEditingController(text: task.remarks);
    String status = task.status == 'Pending' ? 'In Progress' : 'Completed';
    bool photoCaptured = task.photoUrl != null;
    String? pickedPhotoPath;
    double lat = task.geoLat ?? 23.3441;
    double lng = task.geoLng ?? 85.3096;
    bool isLocating = false;
    String locationStatusMsg = 'Fetching live device location...';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardNavy,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            // Function to fetch real device GPS location
            Future<void> fetchRealLocation() async {
              setModalState(() {
                isLocating = true;
                locationStatusMsg = 'Acquiring GPS Satellite Signal...';
              });
              try {
                bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                if (!serviceEnabled) {
                  setModalState(() {
                    isLocating = false;
                    locationStatusMsg = 'GPS service disabled. Enable Location on phone.';
                  });
                  return;
                }
                LocationPermission permission = await Geolocator.checkPermission();
                if (permission == LocationPermission.denied) {
                  permission = await Geolocator.requestPermission();
                  if (permission == LocationPermission.denied) {
                    setModalState(() {
                      isLocating = false;
                      locationStatusMsg = 'Location permission denied by user.';
                    });
                    return;
                  }
                }
                if (permission == LocationPermission.deniedForever) {
                  setModalState(() {
                    isLocating = false;
                    locationStatusMsg = 'Location permission permanently denied.';
                  });
                  return;
                }
                final pos = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                  timeLimit: const Duration(seconds: 10),
                );
                setModalState(() {
                  lat = pos.latitude;
                  lng = pos.longitude;
                  isLocating = false;
                  locationStatusMsg = 'GPS GEO-TAG: Active & Verified';
                });
              } catch (e) {
                setModalState(() {
                  isLocating = false;
                  locationStatusMsg = 'GPS Active (Default: ${lat.toStringAsFixed(4)}°, ${lng.toStringAsFixed(4)}°)';
                });
              }
            }

            // Function to pick photo from device camera or gallery
            Future<void> pickPhoto(ImageSource source) async {
              try {
                final picker = ImagePicker();
                final XFile? photo = await picker.pickImage(
                  source: source,
                  imageQuality: 85,
                );
                if (photo != null) {
                  setModalState(() {
                    pickedPhotoPath = photo.path;
                    photoCaptured = true;
                  });
                }
              } catch (e) {
                debugPrint('Camera/Gallery pick error: $e');
              }
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Field Task Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        IconButton(icon: const Icon(Icons.close, color: AppTheme.textMuted), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(color: Colors.white12),

                    Text(task.title, style: const TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(task.description, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    const SizedBox(height: 16),

                    // Geo-tagging GPS banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isLocating ? AppTheme.amberGold : AppTheme.goldAccent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLocating ? Icons.gps_not_fixed : Icons.my_location,
                            color: AppTheme.amberGold,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(locationStatusMsg, style: const TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 11)),
                                    if (isLocating) ...[
                                      const SizedBox(width: 6),
                                      const SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.amberGold),
                                      ),
                                    ]
                                  ],
                                ),
                                Text(
                                  'LAT: ${lat.toStringAsFixed(5)}° N | LNG: ${lng.toStringAsFixed(5)}° E',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: AppTheme.goldAccent),
                            tooltip: 'Fetch Live GPS Location',
                            onPressed: isLocating ? null : fetchRealLocation,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Camera & Gallery photo capture section
                    const Text('FIELD PHOTOGRAPH ATTACHMENT:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryNavy,
                              foregroundColor: AppTheme.amberGold,
                              side: const BorderSide(color: AppTheme.goldAccent),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text('CAMERA SCAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            onPressed: () => pickPhoto(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryNavy,
                              foregroundColor: AppTheme.amberGold,
                              side: const BorderSide(color: AppTheme.goldAccent),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.photo_library, size: 18),
                            label: const Text('GALLERY PICK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            onPressed: () => pickPhoto(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Preview of captured photo
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: photoCaptured ? AppTheme.successGreen : AppTheme.goldAccent.withValues(alpha: 0.4), width: photoCaptured ? 2 : 1),
                      ),
                      child: pickedPhotoPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(File(pickedPhotoPath!), fit: BoxFit.cover),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      color: Colors.black54,
                                      child: Text(
                                        'GPS: ${lat.toStringAsFixed(4)}°, ${lng.toStringAsFixed(4)}°',
                                        style: const TextStyle(color: AppTheme.amberGold, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : (photoCaptured
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    task.photoUrl ?? 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=600&q=80',
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_a_photo_outlined, color: AppTheme.amberGold, size: 36),
                                    SizedBox(height: 6),
                                    Text('Tap Camera Scan or Gallery Pick Above', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                )),
                    ),
                    const SizedBox(height: 16),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      value: status,
                      dropdownColor: AppTheme.cardNavy,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Update Task Status'),
                      items: const [
                        DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                        DropdownMenuItem(value: 'Completed', child: Text('Completed & Verified')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => status = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: remarksController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Volunteer Remarks & Outcome Notes',
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: CustomGoldButton(
                            text: 'SUBMIT REPORT (ONLINE / OFFLINE)',
                            icon: Icons.send,
                            onPressed: () {
                              state.updateTaskStatus(
                                task.id,
                                status,
                                remarks: remarksController.text,
                                lat: lat,
                                lng: lng,
                                isOffline: false,
                              );
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Field Task Report submitted! +50 Impact Points Earned!'), backgroundColor: AppTheme.successGreen),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final user = state.currentUser;

    List<TaskModel> tasks = state.assignedTasks;
    if (_taskFilter != 'All') {
      tasks = tasks.where((t) => t.status == _taskFilter).toList();
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Volunteer Profile Card Header
            if (user != null) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppTheme.darkNavyGradient,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.amberGold,
                          backgroundImage: NetworkImage(user.profilePhoto),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              Text('${user.role} • ${user.location}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.stars, color: AppTheme.amberGold, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${user.impactPoints} Impact Points', style: const TextStyle(color: AppTheme.lightGold, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Colors.white12),

                    // Badges row
                    Row(
                      children: [
                        const Text('ACHIEVEMENTS:', style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            children: user.badges.map((b) => Chip(
                              backgroundColor: AppTheme.primaryNavy,
                              side: BorderSide(color: AppTheme.amberGold.withValues(alpha: 0.5)),
                              label: Text(b, style: const TextStyle(color: AppTheme.lightGold, fontSize: 10, fontWeight: FontWeight.bold)),
                              visualDensity: VisualDensity.compact,
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 2. Offline Sync Banner
            if (state.offlineSyncQueue.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.amberGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.amberGold),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: AppTheme.amberGold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${state.offlineSyncQueue.length} Field Reports Pending Sync', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const Text('Data queued offline. Tap sync when internet is connected.', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amberGold, foregroundColor: Colors.black),
                      onPressed: () => state.syncOfflineQueue(),
                      child: const Text('SYNC NOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    )
                  ],
                ),
              ),
            ],

            // 3. Tasks Header & Filter Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ASSIGNED FIELD TASKS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                DropdownButton<String>(
                  value: _taskFilter,
                  dropdownColor: AppTheme.cardNavy,
                  style: const TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 12),
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Tasks')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _taskFilter = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Task Items List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (ctx, i) {
                final t = tasks[i];
                final isCompleted = t.status == 'Completed';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: AppTheme.cardNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: isCompleted ? AppTheme.successGreen.withValues(alpha: 0.4) : AppTheme.goldAccent.withValues(alpha: 0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isCompleted ? AppTheme.successGreen : (t.status == 'Pending' ? AppTheme.errorRed : AppTheme.amberGold),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                t.status.toUpperCase(),
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: AppTheme.goldAccent, size: 14),
                                const SizedBox(width: 4),
                                Text(t.location, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 10),

                        Text(t.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(t.description, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.goldAccent),
                            ),
                            icon: const Icon(Icons.camera_alt, color: AppTheme.goldAccent, size: 16),
                            label: Text(isCompleted ? 'VIEW FIELD REPORT' : 'UPDATE TASK / REPORT PHOTO', style: const TextStyle(color: AppTheme.goldAccent, fontSize: 12)),
                            onPressed: () => _showTaskReportModal(context, t, state),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
