import { chromium } from 'playwright';
import { mkdir, writeFile } from 'node:fs/promises';
import assert from 'node:assert/strict';

await mkdir('build/validation', { recursive: true });
const browser = await chromium.launch({args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader']});
try {
  await checkGame({width:1280,height:720}, 'desktop', false);
  await checkGame({width:390,height:844}, 'portrait', true);
  await checkGame({width:844,height:390}, 'landscape', true);
} finally { await browser.close(); }

async function checkGame(viewport, name, touch) {
  const context = await browser.newContext({viewport, hasTouch:touch, isMobile:touch});
  const page = await context.newPage();
  const messages = [], errors = [];
  let ready = 0;
  page.on('console', message => {
    const text = message.text(); messages.push(text);
    if (text.includes('GATE2_READY')) ready++;
    if (message.type() === 'error' || /SCRIPT ERROR:|^ERROR:/.test(text)) errors.push(text);
  });
  page.on('pageerror', e => errors.push(e.message));
  page.on('response', r => {if(r.status() >= 400) errors.push(`${r.status()} ${r.url()}`);});
  const until = async (condition, label, ms=15000) => {
    const deadline = Date.now()+ms;
    while(!condition() && Date.now()<deadline) await page.waitForTimeout(50);
    assert.ok(condition(), `${name}: ${label}\n${errors.join('\n')}`);
  };
  try {
    await page.goto('http://127.0.0.1:8000', {waitUntil:'load'});
    await until(()=>ready===1, 'game ready', 60000);
    await page.waitForTimeout(300);
    const canvas = page.locator('#canvas');
    const box = await canvas.boundingBox();
    const scale = Math.min(box.width/640,box.height/360);
    const point=(x,y)=>({x:box.x+(box.width-640*scale)/2+x*scale,y:box.y+(box.height-360*scale)/2+y*scale});
    const clip={...point(184,132),width:290*scale,height:130*scale};
    const initial=await page.screenshot({clip});
    // Rendering is checked through visible movement/reset comparisons below;
    // compressed PNG byte size varies with viewport and is not a pixel test.
    await canvas.screenshot({path:`build/validation/combat-${name}-start.png`});
    let cdp;
    const pad=(x=96)=>({...point(x,236),id:1});
    const attack=()=>({...point(552,256),id:2});
    if(touch) {
      assert.ok(messages.some(x=>x.includes('TOUCH_CONTROLS_READY')), 'touch controls visible');
      cdp=await context.newCDPSession(page);
      await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[pad(34)]});
    } else {await canvas.click({position:{x:600,y:350}}); await page.keyboard.down('a');}
    await page.waitForTimeout(180);
    if(touch) await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
    else await page.keyboard.up('a');
    await page.waitForTimeout(200);
    assert.ok(!initial.equals(await page.screenshot({clip})), 'movement changes player position');
    const moved=await page.screenshot({clip});
    await page.waitForTimeout(150);
    assert.ok(moved.equals(await page.screenshot({clip})), 'release stops movement');
    const restart=async()=>{
      const next=ready+1;
      if(touch){const p=point(552,105);await page.touchscreen.tap(p.x,p.y);}
      else await page.keyboard.press('r');
      await until(()=>ready===next,'restart');
      await page.waitForTimeout(250);
      assert.ok(initial.equals(await page.screenshot({clip})), 'restart restores player and enemy');
    };
    await restart();
    // Walk toward the enemy while attacking with an independent second finger.
    if(touch){
      await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[pad(158)]});
      await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[pad(158),attack()]});
    } else {await page.keyboard.down('d');await page.keyboard.down('j');}
    await page.waitForTimeout(200);
    if(touch) await cdp.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[pad(),attack()]});
    else await page.keyboard.up('d');
    await until(()=>messages.some(x=>x.includes('SWORD_SWING')),'attack input reaches game');
    await until(()=>messages.some(x=>x.includes('ENEMY_HIT')),'sword hits pursuing enemy');
    await canvas.screenshot({path:`build/validation/combat-${name}-fight.png`});
    await until(()=>messages.some(x=>x.includes('ENEMY_DEFEATED')),'enemy can be defeated');
    if(touch) await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
    else await page.keyboard.up('j');
    assert.equal(messages.filter(x=>x.includes('ENEMY_HIT')).length,3,'exactly three damage events defeat enemy');
    assert.ok(!messages.some(x=>x.includes('PLAYER_DEFEATED')),'player survives successful combat');
    await canvas.screenshot({path:`build/validation/combat-${name}-victory.png`});
    await restart();
    assert.deepEqual(errors, [], 'no export or browser errors');
    console.log(`COMBAT_WEB_PASSED: ${name} movement, release, attack, enemy defeat and restart`);
  } finally {
    await writeFile(`build/validation/combat-${name}.log`,[...messages,...errors].join('\n'));
    await page.screenshot({path:`build/validation/combat-${name}-final.png`}).catch(()=>{});
    await context.close();
  }
}
