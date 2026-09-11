import {chromium,firefox} from 'playwright';
import {writeFile} from 'node:fs/promises';
import assert from 'node:assert/strict';
const useFirefox=process.env.QA_BROWSER==='firefox';
const browser=useFirefox?await firefox.launch({headless:false,firefoxUserPrefs:{'webgl.force-enabled':true}}):await chromium.launch({args:['--use-angle=swiftshader','--enable-unsafe-swiftshader']});
try {
  await check({width:1280,height:720},useFirefox?'firefox':'desktop',false);
  if(!useFirefox){
    await check({width:390,height:844},'portrait',true);
    await check({width:844,height:390},'landscape',true);
  }
} finally {await browser.close();}

async function check(viewport,name,touch){
  const context=await browser.newContext(useFirefox?{viewport}:{viewport,hasTouch:touch,isMobile:touch});
  const page=await context.newPage();
  const messages=[],errors=[];
  let ready=0;
  page.on('console',m=>{messages.push(m.text());if(m.text().includes('GATE5_READY'))ready++;if(m.type()==='error'||/SCRIPT ERROR:|^ERROR:/.test(m.text()))errors.push(m.text());});
  page.on('pageerror',e=>errors.push(e.message));
  page.on('response',r=>{if(r.status()>=400)errors.push(`${r.status()} ${r.url()}`);});
  const until=async(fn,label,ms=15000)=>{const deadline=Date.now()+ms;while(!fn()&&Date.now()<deadline)await page.waitForTimeout(50);assert.ok(fn(),`${name}: ${label}\n${errors.join('\n')}`);};
  const has=text=>messages.some(x=>x.includes(text));
  try {
    await page.goto('http://127.0.0.1:8000/');
    await until(()=>ready===1,'Gate 5 ready',60000);
    const canvas=page.frameLocator('iframe').locator('#canvas');
    await page.waitForTimeout(350);
    const box=await canvas.boundingBox(),scale=Math.min(box.width/640,box.height/360);
    const point=(x,y)=>({x:box.x+(box.width-640*scale)/2+x*scale,y:box.y+(box.height-360*scale)/2+y*scale});
    const cdp=touch?await context.newCDPSession(page):null;
    const pad=(x=96)=>({...point(x,236),id:1});
    const attack=()=>({...point(552,256),id:2});
    const use=async()=>{if(touch){const p=point(552,172);await page.touchscreen.tap(p.x,p.y);}else await page.keyboard.press('e');};
    const walk=async(ms)=>{
      if(touch)await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[pad(158)]});
      else await page.keyboard.down('d');
      await page.waitForTimeout(ms);
      if(touch)await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
      else await page.keyboard.up('d');
      await page.waitForTimeout(100);
    };
    if(!touch)await canvas.click({position:{x:500,y:350}});
    await page.keyboard.press('m'); await page.waitForTimeout(100);
    assert.ok(has('SOUND_MUTED=true'),'keyboard mute works');
    await page.keyboard.press('m'); await page.waitForTimeout(100);
    assert.ok(has('SOUND_MUTED=false'),'keyboard sound restores');
    await use(); await page.waitForTimeout(100);
    assert.ok(!has('SWORD_COLLECTED'),'cannot collect from outside range');
    const initialClip={...point(184,132),width:290*scale,height:130*scale};
    const initial=await page.screenshot({clip:initialClip});
    await canvas.screenshot({path:`build/validation/presentation-${name}-start.png`});
    await walk(120);
    await use();
    await until(()=>has('SWORD_COLLECTED'),'sword pickup');
    assert.equal(messages.filter(x=>x.includes('SWORD_COLLECTED')).length,1);
    // Equip, then move and attack with independent fingers on a phone.
    if(touch){
      await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[pad(158)]});
      await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[pad(158),attack()]});
    }else{await page.keyboard.down('d');await page.keyboard.down('j');}
    await page.waitForTimeout(80);
    if(touch)await cdp.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[pad(),attack()]});
    else await page.keyboard.up('d');
    await until(()=>has('ENEMY_DEFEATED'),'acquired sword defeats enemy');
    if(touch)await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
    else await page.keyboard.up('j');
    assert.ok(!has('PLAYER_DEFEATED'),'player survives route');
    const nextRoom=async(number)=>{
      if(touch)await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[pad(158)]});
      else await page.keyboard.down('d');
      await until(()=>has(`ROOM_ENTERED room=${number}`),`enter room ${number}`);
      if(touch)await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
      else await page.keyboard.up('d');
      await page.waitForTimeout(350);
    };
    await nextRoom(1);
    await walk(600);
    await use();
    await until(()=>has('PASSAGE_OPENED'),'switch opens passage');
    await canvas.screenshot({path:`build/validation/presentation-${name}-passage.png`});
    await nextRoom(2);
    await walk(1100);
    await use();
    await until(()=>has('MEMORY_COLLECTED count=1'),'memory collected and popup opened');
    await page.waitForTimeout(250);
    const popup=await canvas.screenshot({path:`build/validation/presentation-${name}-memory.png`});
    if(!touch){await page.keyboard.down('d');await page.keyboard.down('j');}
    await page.waitForTimeout(350);
    assert.ok(popup.equals(await canvas.screenshot()),'reading popup freezes displayed action');
    if(touch){const p=point(320,256);await page.touchscreen.tap(p.x,p.y);}else await page.keyboard.press('e');
    await until(()=>has('MEMORY_POPUP_CLOSED'),'Continue closes popup');
    if(!touch){await page.keyboard.up('d');await page.keyboard.up('j');}
    await use();await page.waitForTimeout(150);
    assert.equal(messages.filter(x=>x.includes('MEMORY_COLLECTED')).length,1,'memory is single-use');
    await walk(400);
    await use();
    await until(()=>has('SLICE_COMPLETED'),'endpoint completes route');
    await canvas.screenshot({path:`build/validation/presentation-${name}-complete.png`});
    const next=ready+1;
    if(touch){const p=point(552,105);await page.touchscreen.tap(p.x,p.y);}else await page.keyboard.press('r');
    await until(()=>ready===next,'restart');
    await page.waitForTimeout(300);
    assert.ok(initial.equals(await page.screenshot({clip:initialClip})),'restart restores player, sword, enemy and hidden memory');
    for(const cue of ['sword','defeat','passage','memory','finish','room'])assert.ok(has(`SOUND_CUE ${cue}`),`sound cue ${cue}`);
    assert.deepEqual(errors,[],'no browser errors');
    console.log(`PRESENTATION_WEB_PASSED: ${name} sword, combat, room transitions, switch, memory, endpoint and restart`);
  }finally{
    await writeFile(`build/validation/presentation-${name}.log`,[...messages,...errors].join('\n'));
    await page.screenshot({path:`build/validation/presentation-${name}-final.png`}).catch(()=>{});
    await context.close();
  }
}
