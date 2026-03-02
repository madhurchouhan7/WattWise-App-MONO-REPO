// src/controllers/bbps.controller.js
const axios = require('axios');

/**
 * @desc    Fetch Electricity Bill via Setu
 * @route   POST /api/v1/bbps/fetch-bill
 * @access  Private
 */
exports.fetchBill = async (req, res) => {
    const { billerId, consumerNumber } = req.body;

    if (!billerId || !consumerNumber) {
        return res.status(400).json({
            success: false,
            message: 'Please provide both billerId and consumerNumber.'
        });
    }

    // MOCK RESPONSE FOR TESTING UI (Since sandbox.setu.co is unreachable / offline)
    if (billerId === 'TEST_BILLER_ID') {
        return res.status(200).json({
            success: true,
            data: {
                billerName: "Mock Electricity Board",
                amountExact: 1250.50,
                billNumber: "INV-2026-00" + Math.floor(Math.random() * 100),
                dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
                consumerNumber: consumerNumber,
                status: "UNPAID"
            }
        });
    }

    try {
        // 1. Call the Setu Sandbox API
        const setuResponse = await axios.post('https://sandbox.setu.co/api/v1/utilities/bills/fetch', {
            billerId: billerId,
            customerIdentifiers: [
                {
                    // The attribute name depends on the biller, but usually it's "Consumer Number"
                    attributeName: "Consumer Number",
                    attributeValue: consumerNumber
                }
            ]
        }, {
            headers: {
                'X-Client-Id': process.env.SETU_CLIENT_ID,
                'X-Client-Secret': process.env.SETU_CLIENT_SECRET,
                'Content-Type': 'application/json'
            }
        });

        // 2. Send the fetched bill data back securely to the Flutter App
        res.status(200).json({
            success: true,
            data: setuResponse.data
        });

    } catch (error) {
        console.error("Setu API Error:", error.response?.data || error.message);
        res.status(500).json({
            success: false,
            message: "Failed to fetch bill from BBPS"
        });
    }
};
