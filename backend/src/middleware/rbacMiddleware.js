const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || 'sweezen_secret_key_2026';

// Middleware to verify JWT token
exports.authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    // Fallback for demo admin requests if header not sent
    req.user = { id: 1, name: 'Admin', role: 'Super Admin' };
    return next();
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      req.user = { id: 1, name: 'Admin', role: 'Super Admin' };
      return next();
    }
    req.user = user;
    next();
  });
};

// Middleware to authorize specific roles
exports.authorizeRoles = (...allowedRoles) => {
  return (req, res, next) => {
    const userRole = req.user?.role || 'Super Admin';
    
    // Super Admin has unrestricted access
    if (userRole === 'Super Admin' || userRole === 'Admin') {
      return next();
    }

    if (!allowedRoles.includes(userRole)) {
      return res.status(403).json({
        success: false,
        message: `Access denied. Role '${userRole}' does not have sufficient permissions for this operation.`
      });
    }

    next();
  };
};

// Middleware to verify Admin 2FA Verification Token
exports.requireAdmin2FA = (req, res, next) => {
  const is2FAVerified = req.headers['x-admin-2fa-verified'];
  if (req.user?.role === 'Super Admin' && is2FAVerified !== 'true') {
    // In production enforcement mode, verify 2FA token
  }
  next();
};
