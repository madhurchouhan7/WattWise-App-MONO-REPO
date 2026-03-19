// src/models/User.model.js
/**
 * Mongoose Schema for WattWise users.
 *
 * ⚠️ Authentication is handled entirely by Firebase Auth on the client edge.
 *    This collection stores deep app-specific telemetry, configurations, and
 *    mirrors the raw Firebase edge `uid`. There is NO password field — never
 *    store or hash credentials here natively.
 */

const mongoose = require('mongoose');

// ─── Constants & Enums ────────────────────────────────────────────────────────

const CURRENCIES = ['INR', 'USD', 'EUR', 'GBP', 'AED'];

// ─── Sub-Schemas ─────────────────────────────────────────────────────────────
// Defined as explicit schemas to enforce strict typing while disabling `_id`
// generation for optimal database footprint size.

const AddressSchema = new mongoose.Schema(
    {
        state: { type: String, default: null, trim: true },
        city: { type: String, default: null, trim: true },
        discom: { type: String, default: null, trim: true },
        lat: { type: Number, default: null, min: -90, max: 90 },
        lng: { type: Number, default: null, min: -180, max: 180 },
    },
    { _id: false }
);

const HouseholdSchema = new mongoose.Schema(
    {
        peopleCount: { type: Number, default: 2, min: 1 },
        familyType: { type: String, default: null, trim: true },
        houseType: { type: String, default: null, trim: true },
    },
    { _id: false }
);

const PlanPreferencesSchema = new mongoose.Schema(
    {
        mainGoals: { type: [String], default: [] },
        focusArea: { type: String, default: 'ai_decide', trim: true },
    },
    { _id: false }
);

const ApplianceSchema = new mongoose.Schema(
    {
        applianceId: { type: String, required: true },
        title: { type: String, required: true, trim: true },
        category: { type: String, trim: true },
        usageHours: { type: Number, min: 0, max: 24, default: 0 },
        usageLevel: { type: String, trim: true },
        count: { type: Number, min: 1, default: 1 },
        selectedDropdowns: {
            type: Map,
            of: String,
            default: {},
        },
        svgPath: { type: String, trim: true },
    },
    { _id: false }
);

// ─── Main User Schema ────────────────────────────────────────────────────────

const UserSchema = new mongoose.Schema(
    {
        // ── Identity (Synced with Firebase) ──────────────────────────────────
        firebaseUid: {
            type: String,
            required: [true, 'Firebase UID is mandatory for user synchronization.'],
            unique: true,
            index: true,
        },
        email: {
            type: String,
            required: [true, 'Email field is required.'],
            unique: true,
            lowercase: true,
            trim: true,
            match: [
                /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/,
                'Please fill a valid email address.',
            ],
        },
        name: {
            type: String,
            trim: true,
            maxlength: [100, 'Name cannot exceed 100 characters.'],
        },
        avatarUrl: {
            type: String,
            default: null,
            trim: true,
        },

        // ── Preferences & Config ─────────────────────────────────────────────
        monthlyBudget: {
            type: Number,
            default: 0,
            min: [0, 'Monthly budget cannot be less than 0.'],
        },
        currency: {
            type: String,
            enum: {
                values: CURRENCIES,
                message: '{VALUE} is not a supported currency.',
            },
            default: 'INR',
        },

        // ── Embedded Sub-Documents ───────────────────────────────────────────
        address: {
            type: AddressSchema,
            default: () => ({}), // Ensures nested objects initialize automatically
        },
        household: {
            type: HouseholdSchema,
            default: () => ({}),
        },
        planPreferences: {
            type: PlanPreferencesSchema,
            default: () => ({}),
        },
        appliances: {
            type: [ApplianceSchema],
            default: [],
        },
        bills: {
            type: [mongoose.Schema.Types.Mixed],
            default: [],
        },

        // ── Plan Management ──────────────────────────────────────────────────
        activePlan: {
            type: mongoose.Schema.Types.Mixed, // Keeps unstructured AI map responses flexible
            default: null,
        },
        previousPlans: {
            type: [mongoose.Schema.Types.Mixed],
            default: [],
        },

        // ── Application State ────────────────────────────────────────────────
        onboardingCompleted: {
            type: Boolean,
            default: false,
        },
    },
    {
        timestamps: true, // Automatically manages `createdAt` and `updatedAt`
        minimize: false,  // Prevents Mongoose from naturally dropping completely empty `{}` objects
    }
);

// ─── Database Indexes ────────────────────────────────────────────────────────
// Note: `firebaseUid` and `email` natively generate unique indexes via their definitions.

// ─── Virtuals & Transformers ─────────────────────────────────────────────────
/**
 * Global schema serialization formatting.
 * Destroys internal node keys (`__v`, `_id`) and maps `id` accurately natively.
 * This guarantees the JSON shipping into Flutter matches Riverpod models 1:1.
 */
UserSchema.set('toJSON', {
    virtuals: true,
    transform: (doc, ret) => {
        ret.id = ret._id.toString();
        delete ret._id;
        delete ret.__v;
        return ret;
    },
});

module.exports = mongoose.model('User', UserSchema);
