// src/models/User.model.js
// Mongoose schema for WattWise users.
//
// ⚠️  Authentication is handled entirely by Firebase Auth on the client.
//     This collection stores app-specific data and mirrors Firebase's uid.
//     There is NO password field — never store or hash passwords here.

const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema(
    {
        // ── Identity (from Firebase) ─────────────────────────────────────────────
        firebaseUid: {
            type: String,
            required: true,
            unique: true,
            index: true,
        },
        email: {
            type: String,
            required: true,
            unique: true,
            lowercase: true,
            trim: true,
        },
        name: {
            type: String,
            trim: true,
        },
        avatarUrl: {
            type: String,
            default: null,
        },

        // ── WattWise-specific app data ───────────────────────────────────────────
        monthlyBudget: {
            type: Number,
            default: 0,
        },
        currency: {
            type: String,
            default: 'INR',
            enum: ['INR', 'USD', 'EUR', 'GBP', 'AED'],
        },
        // Address specific data
        address: {
            state: { type: String, default: null },
            city: { type: String, default: null },
            discom: { type: String, default: null },
            lat: { type: Number, default: null },
            lng: { type: Number, default: null },
        },
        // Household specific data
        household: {
            peopleCount: { type: Number, default: 2 },
            familyType: { type: String, default: null },
            houseType: { type: String, default: null },
        },
        // AI Energy Plan Preferences
        planPreferences: {
            mainGoals: { type: [String], default: [] },
            focusArea: { type: String, default: 'ai_decide' }
        },
        // Generated Energy Plan
        activePlan: {
            type: Object,
            default: null,
        },
        previousPlans: {
            type: Array,
            default: []
        },
        // Track which onboarding steps the user has completed
        onboardingCompleted: {
            type: Boolean,
            default: false,
        },
        // User's configured appliances
        appliances: {
            type: [{
                applianceId: String,
                title: String,
                category: String,
                usageHours: Number,
                usageLevel: String,
                count: Number,
                selectedDropdowns: {
                    type: Map,
                    of: String
                },
                svgPath: String
            }],
            default: []
        },
    },
    {
        timestamps: true, // createdAt + updatedAt
    }
);

// ── Virtual: expose _id as 'id' (matches Flutter model convention) ────────────
UserSchema.set('toJSON', {
    virtuals: true,
    transform: (_doc, ret) => {
        ret.id = ret._id;
        delete ret._id;
        delete ret.__v;
        return ret;
    },
});

module.exports = mongoose.model('User', UserSchema);
