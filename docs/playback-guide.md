# Playback guide for Ross

## Purpose and current status

Capture the child's response before choosing the next development work. Gate 6 was accepted by Ross; the child has not yet played this version in a recorded session. Preparing this handoff does not count as child approval or completed playback.

This is a short working route with provisional visuals, not the finished 5–10 minute story slice. Acaciana's final appearance, the sword and enemy identities, the memory wording and relationship to Fred remain unresolved. Do not present the placeholder assets or switch sequence as the child's canon.

## Set up

Allow about 15–20 minutes for playing and talking, with no obligation to finish. Open https://test-game-01.vercel.app after deploying Gate 7. The expected site heading is Gate 7 · Playback. For a stable baseline, use Test history → Gate 6 · QA after that deployment, or https://test-game-01.vercel.app/history/gate-6/. That archive is not available until Gate 7 is deployed.

Pinned baseline: c21d48217ec9954cc5c4eb3d74a1093fe4cd9051, Godot 4.7.2-stable, accepted deployment 34638253829. Record the actual build URL, device/browser, input method and date in the observation sheet. Test sound at a comfortable level. Click or tap once if the browser needs a gesture. On a phone, begin in landscape.

Read the short introduction in playback-introduction.md. Offer the controls when needed. Keep the walkthrough below for yourself until the child needs help.

## Run the session

1. First attempt, about 3–5 minutes: let the child explore. Record where they hesitate, what they try and their exact words. Avoid explaining the route in advance.
2. If stuck or frustrated, ask “What are you trying to do?” Then offer the smallest useful hint. Record whether a hint or direct instruction was needed. Let them stop or skip.
3. Optional retry, about 3–5 minutes: try again with the controls understood. Do not treat a successful second attempt as an unassisted first attempt.
4. Feedback, about 5–10 minutes: use the pointed questions in playback-feedback.md. Ask about the played experience before story choices. Use only the questions that are useful; leave the rest blank.
5. Close by playing back one thing to keep and one proposed change. Ask whether you understood correctly. Do not promise a larger feature list yet.

## Walkthrough if help is needed

Move slightly right to the sword; USE equips it. Face and attack the red enemy. Once it is defeated, follow the east arrow to the passage. Approach the switch and USE it; cross the opening and continue east. Approach the green memory and USE it. Close the popup, then approach the ring and USE it to finish. West arrows allow backtracking. Restart restores health, enemy, items and the switch.

Possible hints, from smallest to largest: “What does the message at the bottom say?” → “Try moving closer to that object.” → “Press E or tap USE.” Record the hint instead of counting that step as independent discovery.

## Record and decide

Keep observations separate from interpretation: “pressed ATTACK three times before collecting the sword” is an observation; “needs clearer equipment feedback” is a hypothesis. A suggested story change remains proposed until the child confirms the interpretation.

Use playback-observations.md or the editable pack. Keep completed child feedback outside this public repository. Bring back the relevant answers or a summary for review; the repository contains blank templates only.

Before planning expansion, review blocking problems, one thing to preserve, one candidate change and any canon decisions the child actually confirmed. Do not invent answers, infer enjoyment from completion alone or automatically start another build.

Known coverage limits remain: Safari/iOS, specific physical controllers and real-device audio are not fully verified. Ross's acceptance did not identify the tested device/browser. A device failure should be recorded as such, not treated as feedback about the story.
