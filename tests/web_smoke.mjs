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
  await checkTouch({ width: 390, height: 844 }, 'portrait');
  await checkTouch({ width: 844, height: 390 }, 'landscape');
} finally {
  await page.screenshot({ path: 'build/validation/gate1-browser.png' }).catch(() => {});
  await writeFile('build/validation/browser.log', [...messages, ...errors].join('\n'));
  await browser.close();
}

async function checkTouch(viewport, orientation) {
  const context = await browser.newContext({ viewport, hasTouch: true, isMobile: true });
  const mobile = await context.newPage();
  const mobileErrors = [];
  let sceneReady = 0;
  let touchReady = false;
  mobile.on('console', (message) => {
    if (message.text().includes('GATE1_READY')) sceneReady += 1;
    if (message.text().includes('TOUCH_CONTROLS_READY')) touchReady = true;
    if (message.type() === 'error' || /SCRIPT ERROR:|^ERROR:/.test(message.text())) mobileErrors.push(message.text());
  });
  mobile.on('pageerror', (error) => mobileErrors.push(error.message));
  try {
    await mobile.goto('http://127.0.0.1:8000', { waitUntil: 'load' });
    const deadline = Date.now() + 60_000;
    while ((!sceneReady || !touchReady) && Date.now() < deadline) await mobile.waitForTimeout(100);
    assert.ok(touchReady && sceneReady, 'Touch controls must be detected and shown');
    await mobile.waitForTimeout(700);
    const canvas = mobile.locator('#canvas');
    const box = await canvas.boundingBox();
    const scale = Math.min(box.width / 640, box.height / 360);
    const point = (x, y) => ({
      x: box.x + (box.width - 640 * scale) / 2 + x * scale,
      y: box.y + (box.height - 360 * scale) / 2 + y * scale,
    });
    const initial = await canvas.screenshot({ path: `build/validation/touch-${orientation}-start.png` });
    const cdp = await context.newCDPSession(mobile);
    await cdp.send('Input.dispatchTouchEvent', {
      type: 'touchStart', touchPoints: [{ ...point(96, 236), id: 1 }],
    });
    await cdp.send('Input.dispatchTouchEvent', {
      type: 'touchMove', touchPoints: [{ ...point(158, 236), id: 1 }],
    });
    await mobile.waitForTimeout(600);
    await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
    await mobile.waitForTimeout(1000);
    const moved = await canvas.screenshot({ path: `build/validation/touch-${orientation}-moved.png` });
    assert.ok(!initial.equals(moved), 'Dragging the pad must move the rendered player');
    const nextReady = sceneReady + 1;
    const restart = point(552, 276);
    await mobile.touchscreen.tap(restart.x, restart.y);
    const restartDeadline = Date.now() + 10_000;
    while (sceneReady < nextReady && Date.now() < restartDeadline) await mobile.waitForTimeout(100);
    assert.equal(sceneReady, nextReady, 'Touch restart must reload the scene');
    await mobile.waitForTimeout(700);
    assert.ok(initial.equals(await canvas.screenshot()), 'Touch restart restores the initial rendered scene');
    assert.deepEqual(mobileErrors, [], 'Mobile browser must have no runtime errors');
    console.log(`TOUCH_WEB_PASSED: ${orientation} movement and restart without a keyboard`);
  } finally {
    await mobile.screenshot({ path: `build/validation/touch-${orientation}-browser.png` }).catch(() => {});
    await writeFile(`build/validation/touch-${orientation}.log`, mobileErrors.join('\n'));
    await context.close();
  }
}
