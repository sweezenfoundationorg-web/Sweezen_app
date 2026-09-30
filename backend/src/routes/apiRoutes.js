const express = require('express');
const router = express.Router();

const authController = require('../controllers/authController');
const projectController = require('../controllers/projectController');
const donationController = require('../controllers/donationController');
const volunteerController = require('../controllers/volunteerController');
const eventController = require('../controllers/eventController');
const humanityCardController = require('../controllers/humanityCardController');
const communicationController = require('../controllers/communicationController');
const chatbotController = require('../controllers/chatbotController');
const adminController = require('../controllers/adminController');

const healthCampController = require('../controllers/healthCampController');
const documentController = require('../controllers/documentController');
const { authenticateToken, authorizeRoles } = require('../middleware/rbacMiddleware');

// 1. Auth Routes (Supports both App & Web Auth API conventions)
router.post('/auth/request-otp', authController.requestOtp);
router.post('/auth/email-otp/send', authController.requestOtp);

router.post('/auth/verify-otp', authController.verifyOtp);
router.post('/auth/email-otp/verify', authController.verifyOtp);
router.post('/auth/firebase/email-otp-verify', authController.verifyOtp);

router.post('/auth/register', authController.registerMultiStep);
router.post('/auth/login', authController.login);
router.post('/auth/admin-login', authController.adminLogin);

router.get('/auth/profile', authController.getProfile);
router.get('/auth/me', authController.getProfile);
router.put('/auth/profile', authController.updateProfile);

// 2. Project Routes
router.get('/projects', projectController.getProjects);
router.get('/projects/:id', projectController.getProjectById);
router.post('/projects', projectController.createProject);

// 3. Donation Routes & Razorpay Payment Gateway
router.post('/donations/create-order', donationController.createDonationOrder);
router.post('/donations/verify-payment', donationController.verifyDonationPayment);
router.post('/donations/verify', donationController.verifyDonationPayment);
router.get('/donations/history', donationController.getDonationHistory);
router.get('/donations', donationController.getDonationHistory);
router.get('/donations/my', donationController.getDonationHistory);
router.get('/donations/receipt/:txnId', donationController.get80GReceipt);

// 4. Volunteer & Task Routes
router.get('/volunteer/tasks', volunteerController.getAssignedTasks);
router.post('/volunteer/submit-report', volunteerController.submitFieldReport);
router.post('/volunteer/sync-offline', volunteerController.syncOfflineReports);

// 5. Events & Gallery Routes
router.get('/events', eventController.getEvents);
router.get('/gallery/events', eventController.getEvents);
router.post('/events/register', eventController.registerForEvent);
router.post('/events/cancel', eventController.cancelRegistration);
router.get('/events/certificates', eventController.getUserCertificates);

// 6. Nearby Health Camps Module
router.get('/health-camps', healthCampController.getHealthCamps);
router.post('/health-camps/book', healthCampController.bookCampSlot);
router.post('/health-camps/checkin', healthCampController.verifyCampQRCheckin);

// 7. Digital Document Centre Module
router.get('/documents', documentController.getUserDocuments);

// 8. Humanity Card & Smart ID Routes
router.post('/humanity-card/lookup', humanityCardController.lookupCard);
router.post('/humanity-card/log-service', humanityCardController.logServicePointScan);

// 9. Communication & Announcements Routes
router.get('/communication/announcements', communicationController.getAnnouncements);
router.get('/communication/group-chat/:projectId', communicationController.getGroupMessages);
router.post('/communication/group-chat/:projectId', communicationController.sendGroupMessage);
router.get('/communication/whatsapp-link', communicationController.getWhatsAppLink);

// 10. AI Chatbot ("Ask Sweezen")
router.post('/chatbot/ask', chatbotController.askSweezen);

// 11. Admin Control & Super Admin Control Centre Routes
router.get('/admin/stats', adminController.getAdminDashboardStats);
router.get('/stats', adminController.getAdminDashboardStats);

// User Management & Approvals
router.get('/admin/users', adminController.getAllUsers);
router.put('/admin/users/:userId', adminController.updateUserStatus);

// Projects / Financial Approvals
router.post('/admin/projects', adminController.createProject);
router.put('/admin/projects/:id', adminController.updateProject);
router.post('/admin/projects/:projectId/approve-financials', adminController.approveProjectFinancials);
router.delete('/admin/projects/:id', adminController.deleteProject);

// Events Management
router.post('/admin/events', adminController.createEvent);
router.put('/admin/events/:id', adminController.updateEvent);
router.delete('/admin/events/:id', adminController.deleteEvent);

// Donations Management
router.get('/admin/donations', adminController.getAllDonations);
router.delete('/admin/donations/:id', adminController.deleteDonation);

// Volunteer & Tasks Management
router.get('/admin/tasks', adminController.getAllTasks);
router.post('/admin/assign-task', adminController.assignTaskToVolunteer);
router.delete('/admin/tasks/:id', adminController.deleteTask);

// Audit Trail & Logs
router.get('/admin/audit-logs', adminController.getAuditLogs);

// Push Notifications
router.post('/admin/send-push', adminController.sendPushNotification);

module.exports = router;

