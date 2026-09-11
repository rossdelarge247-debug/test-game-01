import {chromium} from 'playwright';
import {writeFile} from 'node:fs/promises';
import assert from 'node:assert/strict';
const browser=await chromium.launch({args:['--use-angle=swiftshader','--enable-unsafe-swiftshader']});
const context=await browser.newContext({viewport:{width:390,height:844},hasTouch:true,isMobile:true});
const page=await context.newPage();
const messages=[],errors=[];
page.on('console',m=>{messages.push(m.text());if(m.type()==='error'||/SCRIPT ERROR:|^ERROR:/.test(m.text()))errors.push(m.text());});
page.on('pageerror',e=>errors.push(e.message));
page.on('response',r=>{if(r.status()>=400)errors.push(`${r.status()} ${r.url()}`);});
const until=async(fn,label,ms=20000)=>{const end=Date.now()+ms;while(!fn()&&Date.now()<end)await page.waitForTimeout(50);assert.ok(fn(),`${label}\n${errors.join('\n')}`);};
const has=s=>messages.some(m=>m.includes(s));
try{
  await page.goto('http://127.0.0.1:8000/');
  await until(()=>has('GATE5_READY'),'ready',60000);
  const canvas=page.frameLocator('iframe').locator('#canvas');
  const point=async(x,y)=>{const b=await canvas.boundingBox(),s=Math.min(b.width/640,b.height/360);return {x:b.x+(b.width-640*s)/2+x*s,y:b.y+(b.height-360*s)/2+y*s};};
  const tap=async(x,y)=>{const p=await point(x,y);await page.touchscreen.tap(p.x,p.y);await page.waitForTimeout(100);};
  const cdp=await context.newCDPSession(page);
  // Rotate while a movement finger is captured, then leave that finger down.
  await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{...await point(34,236),id:1}]});
  await page.waitForTimeout(100);
  await page.setViewportSize({width:844,height:390});
  await page.waitForTimeout(350);
  const rotated=await canvas.screenshot();
  await page.waitForTimeout(350);
  assert.ok(rotated.equals(await canvas.screenshot()),'rotation clears held movement');
  await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
  await tap(552,105);
  await page.waitForTimeout(350);
  const original=await canvas.screenshot();
  // A fresh gesture must work after rotation and restart.
  await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{...await point(158,236),id:1}]});
  await page.waitForTimeout(200);
  await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
  await page.waitForTimeout(150);
  assert.ok(!original.equals(await canvas.screenshot()),'touch works after rotation');
  // Leave the player unarmed and let the actual enemy defeat them.
  await until(()=>has('PLAYER_DEFEATED'),'enemy can kill player',35000);
  await canvas.screenshot({path:'build/validation/qa-mobile-death.png'});
  await tap(552,172);
  assert.ok(!has('SWORD_COLLECTED'),'dead player cannot pick up sword');
  const readyBefore=messages.filter(m=>m.includes('GATE5_READY')).length;
  await tap(552,105);
  await until(()=>messages.filter(m=>m.includes('GATE5_READY')).length>readyBefore,'restart after death');
  await page.waitForTimeout(350);
  assert.ok(original.equals(await canvas.screenshot()),'death restart restores full initial view');
  // Actual Sound button, not just keyboard shortcut.
  await tap(256,22);
  assert.ok(has('SOUND_MUTED=true'),'touch sound button mutes');
  await tap(256,22);
  assert.ok(has('SOUND_MUTED=false'),'touch sound button restores');
  // Portrait return and navigation away/back must still load the current gate.
  await page.setViewportSize({width:390,height:844});
  await page.waitForTimeout(250);
  await page.getByRole('link',{name:'Test history',exact:true}).click();
  await page.getByRole('link',{name:'Play Gate 5 · Presentation',exact:true}).waitFor();
  await page.getByRole('link',{name:'Latest test',exact:true}).click();
  const deadline=Date.now()+60000;
  while(!(await page.frameLocator('iframe').locator('#canvas').isVisible())&&Date.now()<deadline)await page.waitForTimeout(100);
  assert.ok(await page.frameLocator('iframe').locator('#canvas').isVisible(),'latest game remains reachable');
  assert.deepEqual(errors,[],'no errors during edge-case route');
  console.log('QA_WEB_PASSED: rotation, fresh touch, death, restart, sound and history navigation');
}finally{
  await writeFile('build/validation/qa-mobile.log',[...messages,...errors].join('\n'));
  await page.screenshot({path:'build/validation/qa-mobile-final.png'}).catch(()=>{});
  await browser.close();
}
