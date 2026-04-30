const CryptoJS = require('crypto-js');
const moment   = require('moment');

// ─── CONFIG ───────────────────────────────────────────────────────────────────
let dtNow       = moment();
let X_TIMESTAMP = dtNow.format("YYYY-MM-DDTHH:mm:ss.SSSSSSSSS[+07:00]");
const CLIENT_ID = pm.collectionVariables.get("CHANNEL_KEY");

// ─── STEP 1: Compose stringToSign ─────────────────────────────────────────────
const stringToSign = `${CLIENT_ID}|${X_TIMESTAMP}`;
console.log('stringToSign :', stringToSign);

// ─── STEP 2: SHA-256 → Base64 ─────────────────────────────────────────────────
const hashHex     = CryptoJS.SHA256(stringToSign);
const X_SIGNATURE = CryptoJS.enc.Base64.stringify(hashHex);

// ─── STEP 3: Generate RAY_ID ──────────────────────────────────────────────────
const ALPHANUM = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
const X_RAY_ID = Array.from({ length: 16 }, () =>
    ALPHANUM[Math.floor(Math.random() * ALPHANUM.length)]
).join('');

// ─── SET COLLECTION VARIABLES ─────────────────────────────────────────────────
pm.collectionVariables.set("TIMESTAMP", X_TIMESTAMP);
pm.collectionVariables.set("SIGNATURE_TOKEN", X_SIGNATURE);
pm.collectionVariables.set("RAY-ID", X_RAY_ID);

console.log('X-TIMESTAMP  :', X_TIMESTAMP);
console.log('X-SIGNATURE  :', X_SIGNATURE);
console.log('X-RAY-ID     :', X_RAY_ID);