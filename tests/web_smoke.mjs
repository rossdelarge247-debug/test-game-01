import { chromium } from 'playwright';
import { mkdir, writeFile } from 'node:fs/promises';
import assert from 'node:assert/strict';

await mkdir('build/validation', { recursive: true });
const browser = await chromium.launch({
  args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
});
const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
const errors = [];
const messages = [];
let readyCount = 0;
page.on('console', (message) => {
  const text = message.text();
  messages.push(text);
  if (text.includes('GATE1_READY')) readyCount += 1;
  if (message.type() === 'error' || /SCRIPT ERROR:|^ERROR:/.test(text)) errors.push(text);
});
page.on('pageerror', (error) => errors.push(error.message));
page.on('response', (response) => {
  if (response.status() >= 400) errors.push(`${response.status()} ${response.url()}`);
});

async function waitForReady(count) {
  const deadline = Date.now() + 60_000;
  while (readyCount < count && Date.now() < deadline) await page.waitForTimeout(100);
  assert.ok(readyCount >= count, `Expected scene ready ${count} times. ${errors.join('\n')}`);
  await page.waitForTimeout(500);
}

try {
  await page.goto('http://127.0.0.1:8000', { waitUntil: 'load' });
  await waitForReady(1);
  const canvas = page.locator('#canvas');
  await canvas.click({ position: { x: 300, y: 350 } });
  const initial = await canvas.screenshot({ path: 'build/validation/gate1-start.png' });
  assert.ok(initial.length > 5000, 'Canvas should contain a rendered course');

  for (const key of ['d', 'ArrowRight']) {
    await page.keyboard.down(key);
    await page.waitForTimeout(600);
    await page.keyboard.up(key);
    await page.waitForTimeout(500);
    const moved = await canvas.screenshot({ path: `build/validation/gate1-${key}.png` });
    assert.ok(!initial.equals(moved), `${key} must move the rendered player`);
    const nextReady = readyCount + 1;
    await page.keyboard.press('r');
    await waitForReady(nextReady);
    const restarted = await canvas.screenshot();
    assert.ok(initial.equals(restarted), 'Restart must restore the initial rendered scene');
  }
  assert.deepEqual(errors, [], 'Browser must load/export without errors');
  console.log('WEB_SMOKE_PASSED: WebGL rendering, WASD, arrows and restart');
} finally {
  await page.screenshot({ path: 'build/validation/gate1-browser.png' }).catch(() => {});
  await writeFile('build/validation/browser.log', [...messages, ...errors].join('\n'));
  await browser.close();
}
