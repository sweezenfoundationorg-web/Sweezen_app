const { memoryDb } = require('../config/db');
const { createOrder, verifySignature } = require('../config/razorpay');

// Create Razorpay Order & Initiate Donation
exports.createDonationOrder = async (req, res) => {
  try {
    const { amount, project_id, donation_type, donor_name, donor_email, donor_phone, is_anonymous, is_80g_requested, pan_number, payment_method } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({ success: false, message: 'Valid donation amount is required' });
    }

    const receiptId = `SWZ_RCPT_${Date.now()}`;
    const order = await createOrder(amount, receiptId, { project_id, donor_name });

    return res.status(200).json({
      success: true,
      order: order,
      donation_details: {
        receiptId,
        amount,
        project_id,
        donation_type: donation_type || 'One-Time',
        donor_name: is_anonymous ? 'Anonymous Donor' : (donor_name || 'Generous Supporter'),
        donor_email,
        donor_phone,
        is_anonymous: !!is_anonymous,
        is_80g_requested: !!is_80g_requested,
        pan_number: pan_number || null,
        payment_method: payment_method || 'Razorpay UPI/Card'
      }
    });
  } catch (err) {
    console.error('Create donation order error:', err);
    return res.status(500).json({ success: false, message: 'Failed to initiate donation order' });
  }
};

// Verify Payment & Finalize Donation
exports.verifyDonationPayment = async (req, res) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature, donation_details } = req.body;

    const isValid = verifySignature(razorpay_order_id, razorpay_payment_id, razorpay_signature);

    if (!isValid) {
      return res.status(400).json({ success: false, message: 'Payment verification failed' });
    }

    const txnId = `TXN_${razorpay_payment_id || 'SWZ_' + Date.now()}`;

    const newDonation = {
      id: memoryDb.donations.length + 1,
      transaction_id: txnId,
      user_id: req.user ? req.user.id : null,
      donor_name: donation_details.donor_name || 'Generous Supporter',
      donor_email: donation_details.donor_email || 'supporter@sweezenfoundation.org',
      donor_phone: donation_details.donor_phone || '',
      project_id: donation_details.project_id ? parseInt(donation_details.project_id) : null,
      amount: parseFloat(donation_details.amount),
      donation_type: donation_details.donation_type || 'One-Time',
      payment_method: donation_details.payment_method || 'Razorpay',
      is_anonymous: !!donation_details.is_anonymous,
      is_80g_requested: !!donation_details.is_80g_requested,
      pan_number: donation_details.pan_number || null,
      receipt_url: `/api/donations/receipt/${txnId}`,
      status: 'Success',
      created_at: new Date()
    };

    memoryDb.donations.push(newDonation);

    // Update project raised amount if specific
    if (newDonation.project_id) {
      const proj = memoryDb.projects.find(p => p.id === newDonation.project_id);
      if (proj) {
        proj.funding_raised += newDonation.amount;
      }
    }

    return res.status(200).json({
      success: true,
      message: 'Donation successful! Thank you for empowering lives.',
      transaction: newDonation
    });
  } catch (err) {
    console.error('Verify donation payment error:', err);
    return res.status(500).json({ success: false, message: 'Payment processing error' });
  }
};

// Get User Donation History
exports.getDonationHistory = async (req, res) => {
  try {
    const list = memoryDb.donations;
    return res.status(200).json({ success: true, count: list.length, donations: list });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch donation history' });
  }
};

// Download 80G Receipt JSON / metadata
exports.get80GReceipt = async (req, res) => {
  try {
    const txnId = req.params.txnId;
    const donation = memoryDb.donations.find(d => d.transaction_id === txnId);

    if (!donation) {
      return res.status(404).json({ success: false, message: 'Donation transaction not found' });
    }

    return res.status(200).json({
      success: true,
      receipt: {
        foundation_name: 'Sweezen Foundation',
        registration_no: 'REG/SECTION-8/SDG-2024-9901',
        pan_no: 'AAATS8891G',
        section_80g_num: '80G/CIT(E)/DELHI/2024-25/A-10892',
        transaction_id: donation.transaction_id,
        date: donation.created_at,
        donor_name: donation.is_anonymous ? 'Anonymous Donor' : donation.donor_name,
        donor_pan: donation.pan_number || 'NOT_PROVIDED',
        amount: donation.amount,
        amount_in_words: `${donation.amount} Rupees Only`,
        project: donation.project_id ? (memoryDb.projects.find(p => p.id === donation.project_id)?.name || 'General Fund') : 'General Foundation Fund',
        status: donation.status,
        validity: 'Eligible for 50% Tax Exemption under Section 80G of Income Tax Act'
      }
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Receipt fetch error' });
  }
};
