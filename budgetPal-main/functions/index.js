const functions = require('firebase-functions');
const fetch = require('node-fetch');

// Mono API keys
// VITE_MONO_PUBLIC_KEY="test_pk_ix235rf6qosg2hpvl7nn" (public, for frontend use)
// INTEGRATION_MONO_SECRET_KEY="test_sk_gbfpe3oaqw1ipplleezk" (secret, for backend use)
// Set secret key in Firebase config: firebase functions:config:set mono.secret="test_sk_gbfpe3oaqw1ipplleezk"
const MONO_SECRET_KEY = functions.config().mono.secret; // Securely loaded from Firebase config
const MONO_BASE_URL = 'https://api.withmono.com';

// Exchanges a Mono authorization code for an access token
exports.exchangeCodeForToken = functions.https.onCall(async (data, context) => {
  const code = data.code;
  const response = await fetch(`${MONO_BASE_URL}/account/auth`, {
    method: 'POST',
    headers: {
      'mono-sec-key': MONO_SECRET_KEY,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ code })
  });
  return await response.json();
});

// Fetches all accounts linked to the Mono user using the access token
exports.getAccounts = functions.https.onCall(async (data, context) => {
  const accessToken = data.accessToken;
  const response = await fetch(`${MONO_BASE_URL}/accounts`, {
    method: 'GET',
    headers: {
      'mono-sec-key': MONO_SECRET_KEY,
      'Authorization': `Bearer ${accessToken}`
    }
  });
  return await response.json();
});

// Fetches transactions for a specific Mono account using the access token
exports.getTransactions = functions.https.onCall(async (data, context) => {
  const { accountId, accessToken } = data;
  const response = await fetch(`${MONO_BASE_URL}/accounts/${accountId}/transactions`, {
    method: 'GET',
    headers: {
      'mono-sec-key': MONO_SECRET_KEY,
      'Authorization': `Bearer ${accessToken}`
    }
  });
  return await response.json();
});
