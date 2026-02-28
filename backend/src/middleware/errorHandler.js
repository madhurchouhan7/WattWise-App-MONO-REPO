// src/middleware/errorHandler.js
// Centralized global error handler for the Express app

/**
 * Sends a consistent JSON error response.
 * In development mode, it includes the stack trace for easier debugging.
 */
const errorHandler = (err, _req, res, _next) => {
    const statusCode = err.statusCode || 500;
    const isProduction = process.env.NODE_ENV === 'production';

    console.error(`[ERROR] ${err.message}`, isProduction ? '' : err.stack);

    res.status(statusCode).json({
        success: false,
        message: err.message || 'Internal Server Error',
        ...(isProduction ? {} : { stack: err.stack }),
    });
};

module.exports = errorHandler;
