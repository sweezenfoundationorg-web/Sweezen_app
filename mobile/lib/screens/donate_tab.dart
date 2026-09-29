import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_gold_button.dart';
import '../widgets/receipt_dialog.dart';

class DonateTab extends StatefulWidget {
  const DonateTab({Key? key}) : super(key: key);

  @override
  State<DonateTab> createState() => _DonateTabState();
}

class _DonateTabState extends State<DonateTab> {
  final TextEditingController _amountController = TextEditingController(text: '1000');
  final TextEditingController _nameController = TextEditingController(text: 'Aarav Sharma');
  final TextEditingController _emailController = TextEditingController(text: 'aarav@sweezenfoundation.org');
  final TextEditingController _panController = TextEditingController(text: 'ABCDE1234F');
  final ScrollController _scrollController = ScrollController();

  String _donationType = 'One-Time'; // One-Time, Recurring
  int? _selectedProjectId; // null = General Fund
  String _paymentMethod = 'UPI'; // UPI, Card, NetBanking, Razorpay
  bool _isAnonymous = false;
  bool _is80GRequested = true;
  bool _isProcessing = false;

  final List<int> _presetAmounts = [500, 1000, 2500, 5000, 10000];

  void _scrollToForm() {
    _scrollController.animateTo(
      550,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _selectProgram(ProjectModel project) {
    setState(() {
      _selectedProjectId = project.id;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected Program: ${project.name}'),
        backgroundColor: AppTheme.amberGold,
        duration: const Duration(seconds: 2),
      ),
    );
    _scrollToForm();
  }

  void _handleInitiateDonation() async {
    final amtText = _amountController.text.trim();
    final amount = double.tryParse(amtText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid donation amount')));
      return;
    }

    setState(() => _isProcessing = true);

    // 1. Create Razorpay order via API
    final orderRes = await ApiService.createDonationOrder(
      amount,
      projectId: _selectedProjectId,
      donorName: _nameController.text.trim(),
      donorEmail: _emailController.text.trim(),
      isAnonymous: _isAnonymous,
      is80g: _is80GRequested,
      panNumber: _panController.text.trim(),
    );

    // 2. Verify payment simulation
    final verifyPayload = {
      'razorpay_order_id': orderRes['order']?['id'] ?? 'order_sim_123',
      'razorpay_payment_id': 'pay_sim_${DateTime.now().millisecondsSinceEpoch}',
      'razorpay_signature': 'simulated_signature',
      'donation_details': orderRes['donation_details']
    };

    final result = await ApiService.verifyDonationPayment(verifyPayload);

    setState(() => _isProcessing = false);

    if (result['success'] == true) {
      // Show Instant 80G Receipt Modal!
      showDialog(
        context: context,
        builder: (_) => ReceiptDialog(
          donationDetails: {
            'receiptId': orderRes['donation_details']?['receiptId'] ?? 'SWZ-RCPT-8891',
            'txnId': result['transaction']?['transaction_id'] ?? 'TXN_SWZ_98231',
            'amount': amount,
            'donor_name': _isAnonymous ? 'Anonymous Donor' : _nameController.text,
            'pan_number': _panController.text,
            'project_name': _selectedProjectId != null ? 'Selected Foundation Program' : 'General Foundation Fund',
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card in Dark Navy Theme
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.amberGold.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.volunteer_activism, color: AppTheme.amberGold, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'SWEEZEN DONATION HUB',
                          style: TextStyle(
                            color: AppTheme.amberGold,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '100% Tax Exempted under 80G. Direct transparent funding for rural India.',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FEATURED PROGRAMS SECTION WITH IMAGES AND "DONATE TO THIS PROGRAM" BUTTON
            const Text(
              'DONATE TO THIS PROGRAM:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.8),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select a specific campaign to directly transform lives with real-time impact tracking.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 14),

            // Program Cards Horizontal Scroll in Dark Navy Theme
            SizedBox(
              height: 335,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.projects.length,
                itemBuilder: (ctx, i) {
                  final p = state.projects[i];
                  final isSelected = _selectedProjectId == p.id;
                  final percentageStr = (p.progressPercentage * 100).toStringAsFixed(0);

                  final cat = p.category.toLowerCase();
                  String assetFallback = 'assets/images/onboarding_healthcare.png';
                  if (cat.contains('edu')) {
                    assetFallback = 'assets/images/onboarding_education.png';
                  } else if (cat.contains('envir') || cat.contains('green')) {
                    assetFallback = 'assets/images/onboarding_environment.png';
                  }

                  return Container(
                    width: 275,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardNavy,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? AppTheme.amberGold : AppTheme.goldAccent.withValues(alpha: 0.3),
                        width: isSelected ? 2.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campaign Image Header with Category Badge & Asset Fallback
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                              child: Image.network(
                                p.imageUrl,
                                height: 125,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) {
                                  return Image.asset(
                                    assetFallback,
                                    height: 125,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.amberGold,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  p.category.toUpperCase(),
                                  style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Card Body
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 12, color: AppTheme.goldAccent),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      p.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Progress Bar
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Raised: ₹${(p.fundingRaised / 1000).toStringAsFixed(0)}K', style: const TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 11)),
                                  Text('$percentageStr%', style: const TextStyle(color: AppTheme.lightGold, fontWeight: FontWeight.bold, fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: p.progressPercentage,
                                  minHeight: 6,
                                  backgroundColor: Colors.white10,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.amberGold),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Donate to this Program Button
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected ? AppTheme.amberGold : AppTheme.primaryNavy,
                                    foregroundColor: isSelected ? Colors.black : AppTheme.amberGold,
                                    side: BorderSide(color: AppTheme.amberGold, width: isSelected ? 2 : 1),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: Icon(isSelected ? Icons.check_circle : Icons.favorite, size: 16),
                                  label: Text(
                                    isSelected ? 'SELECTED PROGRAM' : 'DONATE TO THIS PROGRAM',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () => _selectProgram(p),
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
            ),
            const SizedBox(height: 28),

            // 1. Donation Type Toggle
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('One-Time Donation')),
                    selected: _donationType == 'One-Time',
                    selectedColor: AppTheme.amberGold,
                    backgroundColor: AppTheme.cardNavy,
                    labelStyle: TextStyle(color: _donationType == 'One-Time' ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                    onSelected: (selected) {
                      if (selected) setState(() => _donationType = 'One-Time');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Monthly Recurring')),
                    selected: _donationType == 'Recurring',
                    selectedColor: AppTheme.amberGold,
                    backgroundColor: AppTheme.cardNavy,
                    labelStyle: TextStyle(color: _donationType == 'Recurring' ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                    onSelected: (selected) {
                      if (selected) setState(() => _donationType = 'Recurring');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Amount Input & Preset Chips
            const Text('SELECT DONATION AMOUNT (INR ₹):', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),

            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _presetAmounts.length,
                itemBuilder: (ctx, i) {
                  final amt = _presetAmounts[i];
                  final isSelected = _amountController.text == amt.toString();
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: isSelected ? AppTheme.amberGold : AppTheme.cardNavy,
                      side: BorderSide(color: AppTheme.goldAccent.withValues(alpha: 0.4)),
                      label: Text('₹$amt', style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        setState(() => _amountController.text = amt.toString());
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _amountController,
              style: const TextStyle(color: AppTheme.amberGold, fontSize: 20, fontWeight: FontWeight.bold),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Custom Amount (₹)',
                prefixIcon: Icon(Icons.currency_rupee, color: AppTheme.amberGold),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Project Allocation Dropdown
            DropdownButtonFormField<int?>(
              value: _selectedProjectId,
              dropdownColor: AppTheme.cardNavy,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Allocate Donation To Program',
                prefixIcon: Icon(Icons.account_tree, color: AppTheme.goldAccent),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('General Foundation Fund (Where most needed)')),
                ...state.projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
              ],
              onChanged: (val) => setState(() => _selectedProjectId = val),
            ),
            const SizedBox(height: 20),

            // 4. Payment Method Options
            const Text('PAYMENT METHOD (RAZORPAY GATEWAY):', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),

            Row(
              children: [
                _buildPaymentOption('UPI', Icons.qr_code, 'UPI (GPay/PhonePe)'),
                const SizedBox(width: 8),
                _buildPaymentOption('Card', Icons.credit_card, 'Cards'),
                const SizedBox(width: 8),
                _buildPaymentOption('NetBanking', Icons.account_balance, 'Net Banking'),
              ],
            ),
            const SizedBox(height: 20),

            // 5. 80G Tax Benefit Box in Dark Navy Theme
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppTheme.amberGold,
                    title: const Text('Request 80G Tax Exemption Certificate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Claim 50% tax deduction under Sec 80G of Income Tax Act', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    value: _is80GRequested,
                    onChanged: (val) => setState(() => _is80GRequested = val),
                  ),
                  if (_is80GRequested) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _panController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Donor PAN Number (Required for 80G)',
                        prefixIcon: Icon(Icons.badge, color: AppTheme.goldAccent),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Anonymous Option
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppTheme.amberGold,
              title: const Text('Keep My Name Anonymous on Public Donor Wall', style: TextStyle(color: Colors.white, fontSize: 12)),
              value: _isAnonymous,
              onChanged: (val) => setState(() => _isAnonymous = val ?? false),
            ),
            const SizedBox(height: 24),

            // CTA Button
            SizedBox(
              width: double.infinity,
              child: CustomGoldButton(
                text: _isProcessing ? 'PROCESSING RAZORPAY...' : 'PROCEED TO PAY ₹${_amountController.text}',
                icon: Icons.lock,
                onPressed: _handleInitiateDonation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon, String label) {
    final selected = _paymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.cardNavy : AppTheme.primaryNavy,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? AppTheme.amberGold : Colors.white12, width: selected ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppTheme.amberGold : AppTheme.textMuted, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: selected ? AppTheme.lightGold : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
