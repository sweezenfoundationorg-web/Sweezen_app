import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  String _donationType = 'One-Time'; // One-Time, Recurring
  int? _selectedProjectId; // null = General Fund
  String _paymentMethod = 'UPI'; // UPI, Card, NetBanking, Razorpay
  bool _isAnonymous = false;
  bool _is80GRequested = true;
  bool _isProcessing = false;

  final List<int> _presetAmounts = [500, 1000, 2500, 5000, 10000];

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
            'project_name': _selectedProjectId != null ? 'Healthcare Mobile Unit Drive' : 'General Foundation Fund',
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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.goldAccent.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.volunteer_activism, color: AppTheme.amberGold, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('BE THE REASON SOMEONE SMILES', style: TextStyle(color: AppTheme.amberGold, fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: 2),
                        Text('100% of your contribution directly powers healthcare, digital pods & river protection.', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

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
                      side: BorderSide(color: AppTheme.goldAccent.withOpacity(0.4)),
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

            // 5. 80G Tax Benefit & PAN
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppTheme.amberGold,
              title: const Text('Request 80G Tax Exemption Certificate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Claim 50% tax deduction under Sec 80G of Income Tax Act', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              value: _is80GRequested,
              onChanged: (val) => setState(() => _is80GRequested = val),
            ),

            if (_is80GRequested) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _panController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Donor PAN Number (Required for 80G)',
                  prefixIcon: Icon(Icons.badge, color: AppTheme.goldAccent),
                ),
              ),
            ],
            const SizedBox(height: 12),

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
