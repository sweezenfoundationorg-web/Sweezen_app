const { getCollection, memoryDb } = require('../config/db');
const { createOrder, verifySignature } = require('../config/razorpay');

// 1. Create Razorpay Order & Initiate Donation
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

// 2. Verify Payment & Finalize Donation
exports.verifyDonationPayment = async (req, res) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature, donation_details } = req.body;

    // Verify razorpay signature if provided
    const isValid = verifySignature(razorpay_order_id, razorpay_payment_id, razorpay_signature);

    if (!isValid) {
      return res.status(400).json({ success: false, message: 'Payment verification failed' });
    }

    const txnId = `TXN_${razorpay_payment_id || 'SWZ_' + Date.now()}`;
    const details = donation_details || {};

    const newDonation = {
      id: `SWZ-DON-${Date.now()}`,
      transaction_id: txnId,
      razorpay_order_id: razorpay_order_id || null,
      razorpay_payment_id: razorpay_payment_id || null,
      user_id: req.user ? req.user.id : null,
      donor_name: details.donor_name || 'Generous Supporter',
      donor_email: details.donor_email || 'supporter@sweezenfoundation.org',
      donor_phone: details.donor_phone || '',
      project_id: details.project_id || null,
      amount: parseFloat(details.amount || 1000),
      donation_type: details.donation_type || 'One-Time',
      payment_method: details.payment_method || 'Razorpay',
      is_anonymous: !!details.is_anonymous,
      is_80g_requested: !!details.is_80g_requested,
      pan_number: details.pan_number || null,
      receipt_url: `/api/donations/receipt/${txnId}`,
      status: 'Success',
      created_at: new Date()
    };

    // Save to MongoDB donations collection
    const donCol = getCollection('donations');
    if (donCol) {
      await donCol.insertOne(newDonation);
    }
    memoryDb.donations.push(newDonation);

    // Update project raised funds in MongoDB
    if (newDonation.project_id) {
      const projCol = getCollection('projects');
      if (projCol) {
        await projCol.updateOne(
          { $or: [{ id: newDonation.project_id }, { id: parseInt(newDonation.project_id) || -1 }] },
          { $inc: { raised: newDonation.amount, funding_raised: newDonation.amount } }
        );
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

// 3. Get User Donation History
exports.getDonationHistory = async (req, res) => {
  try {
    const donCol = getCollection('donations');
    let list = [];

    if (donCol) {
      list = await donCol.find({}).sort({ created_at: -1 }).toArray();
    }
    if (!list || list.length === 0) {
      list = memoryDb.donations;
    }

    return res.status(200).json({ success: true, count: list.length, donations: list });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to fetch donation history' });
  }
};

// 4. Download 80G Receipt JSON / metadata
exports.get80GReceipt = async (req, res) => {
  try {
    const txnId = req.params.txnId;
    const donCol = getCollection('donations');
    let donation = null;

    if (donCol) {
      donation = await donCol.findOne({ transaction_id: txnId });
    }
    if (!donation) {
      donation = memoryDb.donations.find(d => d.transaction_id === txnId);
    }

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
        project: donation.project_id || 'General Foundation Fund',
        status: donation.status,
        validity: 'Eligible for 50% Tax Exemption under Section 80G of Income Tax Act'
      }
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Receipt fetch error' });
  }
};
