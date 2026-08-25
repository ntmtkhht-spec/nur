import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import { readFileSync } from 'node:fs';
import {
  doc, setDoc, getDoc, deleteDoc, serverTimestamp,
} from 'firebase/firestore';

const env = await initializeTestEnvironment({
  projectId: 'munir-rules-test',
  firestore: { rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8'), host: '127.0.0.1', port: 8080 },
});

const alice = env.authenticatedContext('alice').firestore();
const mallory = env.authenticatedContext('mallory').firestore();
const anon = env.unauthenticatedContext().firestore();

const aliceDoc = doc(alice, 'users/alice');

let pass = 0, fail = 0;
async function check(name, fn) {
  try { await fn(); console.log('  PASS  ' + name); pass++; }
  catch (e) { console.log('  FAIL  ' + name + '  -> ' + (e.message || e)); fail++; }
}

// ---- what SyncService actually writes -----------------------------------
const realPayload = {
  tracker: { prayer_tracker_2026_8_25_Fajr: true },
  preferences: { language: 'de', name: 'Mouhmad', updatedAt: serverTimestamp() },
  tasbihLifetime: 412,
  quranProgress: {
    version: 1,
    lastPosition: { surahNumber: 2, ayahNumber: 30, updatedAtMs: 1756150000000 },
    readAyahIds: ['1:1', '2:30'],
  },
};

console.log('\nAllowed — the app\'s own traffic:');
await check('owner writes the real sync payload (merge)', () =>
  assertSucceeds(setDoc(aliceDoc, realPayload, { merge: true })));
await check('owner reads own document', () =>
  assertSucceeds(getDoc(aliceDoc)));
await check('owner writes a partial merge (tracker only)', () =>
  assertSucceeds(setDoc(aliceDoc, { tracker: { prayer_tracker_2026_8_25_Asr: true } }, { merge: true })));
await check('owner writes a subcollection entry', () =>
  assertSucceeds(setDoc(doc(alice, 'users/alice/notes/n1'), { any: 'thing' })));
await check('every supported language code is accepted', async () => {
  for (const language of ['de', 'en', 'tr', 'ar', 'fr']) {
    await assertSucceeds(setDoc(aliceDoc, { preferences: { language } }, { merge: true }));
  }
});
await check('owner DELETES own document (account deletion)', () =>
  assertSucceeds(deleteDoc(aliceDoc)));

console.log('\nDenied — other people:');
await check('stranger cannot read', () =>
  assertFails(getDoc(doc(mallory, 'users/alice'))));
await check('stranger cannot write', () =>
  assertFails(setDoc(doc(mallory, 'users/alice'), realPayload, { merge: true })));
await check('stranger cannot delete', () =>
  assertFails(deleteDoc(doc(mallory, 'users/alice'))));
await check('signed-out cannot read', () =>
  assertFails(getDoc(doc(anon, 'users/alice'))));
await check('nothing outside /users is writable', () =>
  assertFails(setDoc(doc(alice, 'whatever/x'), { a: 1 })));

console.log('\nDenied — the document used as free storage:');
await check('unknown top-level field rejected', () =>
  assertFails(setDoc(aliceDoc, { blob: 'x'.repeat(1000) }, { merge: true })));
await check('unknown preferences key rejected', () =>
  assertFails(setDoc(aliceDoc, { preferences: { payload: 'x'.repeat(1000) } }, { merge: true })));
await check('over-long name rejected', () =>
  assertFails(setDoc(aliceDoc, { preferences: { name: 'x'.repeat(201) } }, { merge: true })));
await check('unsupported language rejected', () =>
  assertFails(setDoc(aliceDoc, { preferences: { language: 'zz' } }, { merge: true })));
await check('negative tasbih total rejected', () =>
  assertFails(setDoc(aliceDoc, { tasbihLifetime: -5 }, { merge: true })));
await check('non-int tasbih total rejected', () =>
  assertFails(setDoc(aliceDoc, { tasbihLifetime: 'many' }, { merge: true })));

console.log('\nBoundary:');
await check('a 200-character name is still fine', () =>
  assertSucceeds(setDoc(aliceDoc, { preferences: { name: 'x'.repeat(200) } }, { merge: true })));

await env.cleanup();
console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail === 0 ? 0 : 1);
