import { chromium } from 'playwright';
import { readFile, writeFile } from 'node:fs/promises';
import assert from 'node:assert/strict';

const manifest = JSON.parse(await readFile('history/gates.json', 'utf8'));
const browser = await chromium.launch({args:['--use-angle=swiftshader','--enable-unsafe-swiftshader']});
const page = await browser.newPage({viewport:{width:1000,height:700}});
const errors=[], messages=[];
page.on('console', m=>{messages.push(m.text());if(m.type()==='error')errors.push(m.text());});
page.on('pageerror', e=>errors.push(e.message));
page.on('response', r=>{if(r.status()>=400)errors.push(`${r.status()} ${r.url()}`);});
try {
  await page.goto('http://127.0.0.1:8000/');
  await page.getByRole('link',{name:'Test history',exact:true}).click();
  await page.getByRole('heading',{name:'Test history',exact:true}).waitFor();
  await page.screenshot({path:'build/validation/test-history.png'});
  for(const gate of manifest.gates){
    messages.length=0;
    await page.getByRole('link',{name:`Play ${gate.title}`,exact:true}).click();
    const deadline=Date.now()+60000;
    while(!messages.some(x=>x.includes(gate.ready_marker))&&Date.now()<deadline)await page.waitForTimeout(100);
    assert.ok(messages.some(x=>x.includes(gate.ready_marker)),`${gate.id} boots its original scene`);
    const canvas=page.frameLocator('iframe').locator('#canvas');
    await canvas.click({position:{x:400,y:220}});
    await page.waitForTimeout(500);
    const start=await canvas.screenshot();
    await page.keyboard.down('a');
    await page.waitForTimeout(200);
    await page.keyboard.up('a');
    await page.waitForTimeout(500);
    assert.ok(!start.equals(await canvas.screenshot()),`${gate.id} remains playable`);
    await page.screenshot({path:`build/validation/history-${gate.id}.png`});
    const response=await page.request.get(`http://127.0.0.1:8000/history/${gate.id}/provenance.json`);
    const record=await response.json();
    assert.equal(record.commit,gate.commit,'archive uses the pinned commit');
    assert.equal(record.godot_version,gate.godot_version,'archive uses the pinned engine');
    await page.getByRole('link',{name:'Test history',exact:true}).click();
    await page.getByRole('heading',{name:'Test history',exact:true}).waitFor();
    console.log(`HISTORY_WEB_PASSED: ${gate.id} navigation, original scene and movement`);
  }
  await page.getByRole('link',{name:'Latest test',exact:true}).click();
  await page.getByRole('link',{name:'Test history',exact:true}).waitFor();
  assert.deepEqual(errors,[],'history must load without missing assets or script errors');
} finally {
  await writeFile('build/validation/history-browser.log',[...messages,...errors].join('\n'));
  await browser.close();
}
