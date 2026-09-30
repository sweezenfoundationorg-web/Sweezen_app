import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';

  // 41 Official Cloudinary Gallery Images from sweezenfoundation.org/gallery
  final List<Map<String, String>> _galleryImages = [
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1776157346/gallery/nogldjagtheozvdfip30.jpg', 'title': 'Foundation Inauguration', 'category': 'Inauguration'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1776157358/gallery/hm8eo27sjgspzwgjw6mx.jpg', 'title': 'Leadership Keynote', 'category': 'Inauguration'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1776172935/gallery/r3jvwwad1razt5jnw9bn.jpg', 'title': 'Community Launch Conclave', 'category': 'Inauguration'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1787939951/gallery/swpsfsx46w9vbohcwbxp.jpg', 'title': 'HealthCare Checkup Camp', 'category': 'Healthcare'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1788111421/gallery/u3zpjanxdr0if1fvbpgn.jpg', 'title': 'Environment Cleaning Drive', 'category': 'Environment'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1787939468/gallery/fmemuuposbesry3azn9u.jpg', 'title': 'Medical Examination Unit', 'category': 'Healthcare'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1787939522/gallery/adhdljngja6bt5ruiivs.jpg', 'title': 'Free Medicine Distribution', 'category': 'Healthcare'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1787939696/gallery/rhcsnmqys5kpwpktlycg.jpg', 'title': 'Elderly Care & Screening', 'category': 'Healthcare'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1788110935/gallery/axrjmohqquqbyzfjlvwl.jpg', 'title': 'Riverbank Cleanliness Drive', 'category': 'Environment'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1788111098/gallery/q5rpwglrxf6oiihdddck.jpg', 'title': 'Waste Segregation Awareness', 'category': 'Environment'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1788111181/gallery/tpiuj5ic8bwifwqfvhbn.jpg', 'title': 'Public Space Sanitation', 'category': 'Environment'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1788111237/gallery/heqfakupamys3momwcda.jpg', 'title': 'Eco Sapling Planting', 'category': 'Environment'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1788111274/gallery/fkkg0ksl4kwoghkjhtzw.jpg', 'title': 'Green India Campaign', 'category': 'Environment'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1788111391/gallery/xhlxsaomcrc6ze4ndl0r.jpg', 'title': 'Haridwar Volunteer Mobilization', 'category': 'Environment'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1776172995/gallery/fjtwn5f5ns0wfscbppkk.jpg', 'title': 'Distinguished Guests Honor', 'category': 'Inauguration'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1776173031/gallery/ilhea9mltrvztrvlfdfc.jpg', 'title': 'SDG Action Pledge', 'category': 'Inauguration'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1776173129/gallery/pbebiaqxcn6yudwbkexy.jpg', 'title': 'Community Partner Meet', 'category': 'Inauguration'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1776173388/gallery/ghs2h58sf9ujquthbghh.jpg', 'title': 'Volunteer Alignment Session', 'category': 'Inauguration'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1790193833/gallery/xya5is7p7kfis9zhucij.jpg', 'title': 'Field Coordination Drive', 'category': 'Healthcare'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1790193932/gallery/dwm3nfkmjuf2qagoru5b.jpg', 'title': 'Rural Outreach Station', 'category': 'Healthcare'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1790193974/gallery/vauht3nvqmfxbku1iffa.jpg', 'title': 'Diagnostic Screening Unit', 'category': 'Healthcare'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1790194013/gallery/shyzn4rf2iff7lkaqbym.jpg', 'title': 'Mother & Child Care Drive', 'category': 'Healthcare'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1790194065/gallery/jkakpz9ngdcgvvvwc9pb.jpg', 'title': 'Health Literacy Workshop', 'category': 'Healthcare'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1790194099/gallery/p7j1opkau8p5apf4hv1x.jpg', 'title': 'Doctor Consultation Station', 'category': 'Healthcare'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1790194200/gallery/ih0flghym4nqgmgfdvqn.jpg', 'title': 'Hygiene Kit Distribution', 'category': 'Healthcare'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1790194262/gallery/vetfkfxkr0he35zbdbqg.jpg', 'title': 'Clean Water Pod Launch', 'category': 'Environment'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1790194342/gallery/a75xazfdbzyqltcwvnnt.jpg', 'title': 'Haridwar Sanitation Drive', 'category': 'Environment'},
    {'url': 'https://res.cloudinary.com/dbaqhwxka/image/upload/v1790194424/gallery/v9alqmzgxrrjagva9als.jpg', 'title': 'Youth Volunteer Corps', 'category': 'Inauguration'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openImagePreview(BuildContext context, Map<String, String> img) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  img['url']!,
                  fit: BoxFit.contain,
                  loadingBuilder: (c, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator(color: AppTheme.amberGold)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardNavy,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.amberGold.withOpacity(0.4)),
                ),
                child: Text(
                  img['title']!,
                  style: const TextStyle(color: AppTheme.lightGold, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    final filteredGallery = _selectedCategory == 'All'
        ? _galleryImages
        : _galleryImages.where((i) => i['category']!.toLowerCase() == _selectedCategory.toLowerCase()).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sweezen Foundation Gallery & Events'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.amberGold,
          labelColor: AppTheme.amberGold,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.photo_library), text: 'OFFICIAL GALLERY'),
            Tab(icon: Icon(Icons.event), text: 'EVENTS & CONCLAVES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. OFFICIAL GALLERY TAB (40+ Cloudinary Photos)
          Column(
            children: [
              // Category Filter Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                color: AppTheme.cardNavy,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Inauguration', 'Healthcare', 'Environment'].map((cat) {
                      final selected = _selectedCategory == cat;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: selected,
                          label: Text(cat),
                          selectedColor: AppTheme.amberGold,
                          backgroundColor: AppTheme.primaryNavy,
                          labelStyle: TextStyle(
                            color: selected ? Colors.black : Colors.white,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Gallery Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filteredGallery.length,
                  itemBuilder: (ctx, i) {
                    final item = filteredGallery[i];
                    return GestureDetector(
                      onTap: () => _openImagePreview(context, item),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardNavy,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                child: Image.network(
                                  item['url']!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (c, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color: AppTheme.primaryNavy,
                                      child: const Center(child: CircularProgressIndicator(color: AppTheme.amberGold, strokeWidth: 2)),
                                    );
                                  },
                                  errorBuilder: (c, e, s) => Container(
                                    color: AppTheme.primaryNavy,
                                    child: const Center(child: Icon(Icons.image_not_supported, color: AppTheme.goldAccent)),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['category']!.toUpperCase(),
                                    style: const TextStyle(color: AppTheme.amberGold, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['title']!,
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // 2. UPCOMING EVENTS TAB
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.events.length,
            itemBuilder: (ctx, i) {
              final e = state.events[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: AppTheme.cardNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      e.bannerUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, err, s) => Container(height: 150, color: AppTheme.primaryNavy),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.category.toUpperCase(), style: const TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 10)),
                          const SizedBox(height: 4),
                          Text(e.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                          const SizedBox(height: 6),
                          Text(e.description, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppTheme.goldAccent, size: 16),
                              const SizedBox(width: 4),
                              Expanded(child: Text(e.location, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                            ],
                          ),
                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amberGold, foregroundColor: Colors.black),
                              icon: const Icon(Icons.event_available),
                              label: const Text('REGISTER & GET PARTICIPATION CERTIFICATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              onPressed: () {
                                state.registerForEvent(e.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Registered successfully! Digital certificate saved in your profile.'), backgroundColor: AppTheme.successGreen),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
