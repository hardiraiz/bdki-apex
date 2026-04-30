// ─── CONFIG ───────────────────────────────────────────────────────────────────
const CLIENT_ID     = pm.collectionVariables.get("CHANNEL_KEY");
const CHANNEL_SECRET = pm.collectionVariables.get("CHANNEL_SECRET");

// ─── 1. X-TIMESTAMP ───────────────────────────────────────────────────────────
const now = new Date();
const pad = (n, len = 2) => String(n).padStart(len, '0');

const yyyy = now.getFullYear();
const MM   = pad(now.getMonth() + 1);
const dd   = pad(now.getDate());
const HH   = pad(now.getHours());
const mm   = pad(now.getMinutes());
const ss   = pad(now.getSeconds());
const SSS  = pad(now.getMilliseconds(), 3);

const offsetMin = -now.getTimezoneOffset();
const tzSign    = offsetMin >= 0 ? '+' : '-';
const tzHH      = pad(Math.floor(Math.abs(offsetMin) / 60));
const tzMM      = pad(Math.abs(offsetMin) % 60);
const TZD       = `${tzSign}${tzHH}:${tzMM}`;

const X_TIMESTAMP = `${yyyy}-${MM}-${dd}T${HH}:${mm}:${ss}.${SSS}${TZD}`;
console.log('X-TIMESTAMP  :', X_TIMESTAMP);

// ─── 2. X-CHANNEL-KEY ─────────────────────────────────────────────────────────
const X_CHANNEL_KEY = CLIENT_ID;
console.log('X-CHANNEL-KEY:', X_CHANNEL_KEY);

// ─── 3. X-SIGNATURE (RSA SHA-256 via jsrsasign) ───────────────────────────────
const stringToSign = `${CLIENT_ID}|${X_TIMESTAMP}`;
console.log('stringToSign :', stringToSign);

// jsrsasign tersedia sebagai global "rs" di Postman Sandbox
const PRIVATE_KEY_PEM = `-----BEGIN PRIVATE KEY-----\n${CHANNEL_SECRET}\n-----END PRIVATE KEY-----`;

const sig = new rs.KJUR.crypto.Signature({ alg: 'SHA256withRSA' });
sig.init(PRIVATE_KEY_PEM);
sig.updateString(stringToSign);
const signatureHex = sig.sign();
const X_SIGNATURE  = rs.hextob64(signatureHex);
console.log('X-SIGNATURE  :', X_SIGNATURE);

// ─── 4. X-RAY-ID ──────────────────────────────────────────────────────────────
const ALPHANUM = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
const X_RAY_ID = Array.from({ length: 16 }, () =>
  ALPHANUM[Math.floor(Math.random() * ALPHANUM.length)]
).join('');
console.log('X-RAY-ID     :', X_RAY_ID);

// ─── SET COLLECTION VARIABLES ─────────────────────────────────────────────────
pm.collectionVariables.set("TIMESTAMP", X_TIMESTAMP);
pm.collectionVariables.set("SIGNATURE_TOKEN", X_SIGNATURE);
pm.collectionVariables.set("RAY_ID", X_RAY_ID);

console.log('\nSemua variable berhasil di-set ke collectionVariables.');