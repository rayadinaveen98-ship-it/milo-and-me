"""Reproducible original starter content. Authors normally edit the resulting JSON."""
from pathlib import Path
import json, math
ROOT = Path(__file__).resolve().parents[1]
def line(say, points): return {'say':say,'points':points}
def circle(cx,cy,r,n=32): return [[round(cx+math.cos(i*math.tau/n)*r,4),round(cy+math.sin(i*math.tau/n)*r,4)] for i in range(n+1)]
def lesson(id,title,topic,steps): return {'id':id,'title':title,'topic':topic,'subtitle':'Watch · Draw together · Create','steps':steps}
drawings=[
 lesson('flower','A little flower','flower',[
 line('Start with a round centre.',circle(.5,.36,.08)),
 line('Loop gentle petals around it.',[[.5+(.17+.05*math.cos(6*t))*math.cos(t),.36+(.17+.05*math.cos(6*t))*math.sin(t)] for t in [i*math.tau/96 for i in range(97)]]),
 line('A stem reaches down to the ground.',[[.5,.55],[.49,.69],[.5,.88]]),
 line('Add two leaves. What colour will yours be?',[[.5,.75],[.32,.61],[.34,.76],[.5,.79],[.68,.66],[.63,.83],[.5,.84]])]),
 lesson('rocket','A friendly rocket','rocket',[
 line('A tall shape with a pointy nose.',[[.36,.7],[.36,.33],[.5,.12],[.64,.33],[.64,.7],[.36,.7]]),
 line('A round window to see the stars.',circle(.5,.4,.085)),
 line('Two fins help our rocket look ready.',[[.36,.55],[.2,.75],[.36,.71],[.64,.71],[.8,.75],[.64,.55]]),
 line('A zigzag flame. This rocket lives in our imagination.',[[.42,.72],[.4,.9],[.5,.81],[.58,.9],[.58,.72]])]),
 lesson('butterfly','A garden butterfly','butterfly',[
 line('A little oval makes the body.',[[.5+.04*math.cos(t),.51+.2*math.sin(t)] for t in [i*math.tau/32 for i in range(33)]]),
 line('A big looping wing on the left.',[[.46,.43],[.31,.21],[.16,.27],[.13,.43],[.25,.56],[.15,.7],[.25,.8],[.42,.72],[.46,.57]]),
 line('Another looping wing on the right.',[[.54,.43],[.69,.21],[.84,.27],[.87,.43],[.75,.56],[.85,.7],[.75,.8],[.58,.72],[.54,.57]]),
 line('Two antennae curl toward the sky.',[[.48,.32],[.41,.2],[.35,.2]]),line('One more antenna. Add your own patterns!',[[.52,.32],[.59,.2],[.65,.2]])]),
 lesson('house','Our cosy home','cosy home',[
 line('A square is the start of our home.',[[.23,.45],[.23,.82],[.77,.82],[.77,.45]]),
 line('A triangle roof keeps it cosy.',[[.15,.45],[.5,.16],[.85,.45],[.15,.45]]),
 line('Draw a door to welcome a friend.',[[.42,.82],[.42,.6],[.58,.6],[.58,.82]]),
 line('A little window for the sunshine.',[[.29,.54],[.38,.54],[.38,.66],[.29,.66],[.29,.54]])]),
 lesson('fish','A curious fish','fish',[
 line('A soft oval for a swimming friend.',[[.47+.26*math.cos(t),.5+.17*math.sin(t)] for t in [i*math.tau/40 for i in range(41)]]),
 line('A triangle tail waves hello.',[[.72,.5],[.9,.31],[.9,.69],[.72,.5]]),
 line('Give your fish a curious eye.',circle(.34,.46,.035)),line('A fin helps it turn.',[[.49,.49],[.58,.58],[.51,.58],[.49,.49]]),line('Add a bubble.',circle(.15,.28,.04))]),
 lesson('tree','A giving tree','tree',[
 line('Two lines make a sturdy trunk.',[[.43,.82],[.45,.5],[.55,.5],[.57,.82],[.43,.82]]),
 line('Round shapes make a leafy crown.',[[.22,.48],[.15,.38],[.19,.25],[.32,.22],[.4,.12],[.56,.14],[.66,.23],[.79,.27],[.84,.39],[.74,.5],[.6,.55],[.38,.55],[.22,.48]]),
 line('A little branch reaches out.',[[.5,.69],[.35,.57]]),line('Another branch on the other side.',[[.51,.62],[.66,.52]])]),
 lesson('snail','A slow little snail','snail',[
 line('A gentle curve makes a shell.',circle(.46,.45,.23)),
 line('Curl around toward the middle.',[[.46+(.16-i*.0013)*math.cos(i*.18),.45+(.16-i*.0013)*math.sin(i*.18)] for i in range(95)]),
 line('A long body slides along.',[[.22,.65],[.13,.75],[.76,.75],[.87,.68],[.85,.58],[.76,.57],[.68,.66],[.22,.65]]),
 line('A tall feeler looks around.',[[.8,.59],[.77,.43]]),line('A second feeler waves hello.',[[.84,.59],[.9,.46]])]),
 lesson('kite','A windy-day kite','kite',[
 line('Join four corners for a diamond.',[[.5,.13],[.75,.4],[.5,.66],[.25,.4],[.5,.13]]),
 line('Draw a line across the middle.',[[.25,.4],[.75,.4]]),line('Draw a line from top to bottom.',[[.5,.13],[.5,.66]]),
 line('Let a ribbon wiggle below.',[[.5,.66],[.4,.73],[.58,.79],[.49,.9]])]),
]
def puzzle(id,title,engine,prompt,options,answer,display='',hint='Look closely. We can try as many times as we like.',topic=None):
 return dict(id=id,title=title,topic=topic or title.lower(),engine=engine,prompt=prompt,options=options,answer=answer,display=display,hint=hint,subtitle={'match':'Find a friend','sort':'Put things in order','sequence':'What comes next?','spatial':'Build together','logic':'A little mystery'}[engine])
puzzles=[
 puzzle('shape-friend','A shape for our window','match','Our window needs a circle. Can you find one?',['●','▲','■'],['●'],'○',hint='A circle is round all the way around.'),
 puzzle('leaf-twin','The twin leaf','match','Find the leaf that looks just like this one.',['leaf','shell','star'],['leaf'],'leaf'),
 puzzle('star-match','A star for the sky','match','Which shape matches our little star?',['★','●','■'],['★'],'☆'),
 puzzle('count-up','Picnic steps','sort','Let’s set our picnic places from one to four.',['3','1','4','2'],['1','2','3','4'],hint='Start with the smallest number, then add one.'),
 puzzle('size-order','Cosy boxes','sort','Pack the small box first, then medium, then large.',['large','small','medium'],['small','medium','large']),
 puzzle('day-order','A lovely day','sort','What happens first, next and last in our day?',['night','morning','afternoon'],['morning','afternoon','night']),
 puzzle('pattern-ab','A ribbon pattern','sequence','What comes next on our ribbon?',['●','▲','■'],['●'],'● ▲ ● ▲ ?',hint='Circle, triangle. Circle, triangle. What follows?'),
 puzzle('pattern-aab','Garden footsteps','sequence','Which shape finishes the footsteps?',['■','▲','●'],['■'],'■ ■ ▲ ■ ?',hint='Two squares, then one triangle.'),
 puzzle('count-next','One more berry','sequence','We add one berry each time. What comes next?',['3','4','6'],['4'],'1  2  3  ?'),
 puzzle('bridge','Build a little bridge','spatial','Copy this bridge from left to right.',['■','▲','●'],['■','▲','■'],'■ ▲ ■',hint='A square at each end, and a triangle in the middle.'),
 puzzle('garden-path','A garden path','spatial','Copy the stepping stones so we can cross.',['●','■','▲'],['●','■','●','■'],'● ■ ● ■'),
 puzzle('tower','Our little tower','spatial','Copy the tower blocks in this order.',['■','▲','●'],['■','■','▲'],'■ ■ ▲'),
 puzzle('rain','A rainy picnic','logic','Rain is falling. What can help keep our picnic dry?',['umbrella','spoon','ball'],['umbrella'],hint='Which one makes a little roof?'),
 puzzle('plant','Our thirsty plant','logic','Our plant has sunlight and soil. What else does it need?',['water','a hat','a toy'],['water']),
 puzzle('kindness','A turn for everyone','logic','We both want the same toy. What could we try?',['take turns','hide it','grab it'],['take turns'],hint='How can both friends have a chance to play?'),
]
def scene(text,choices,background='meadow',symbol='✦',emotion='happy'):
 return dict(text=text,choices=[dict(label=a,next=b) for a,b in choices],background=background,symbol=symbol,emotion=emotion)
stories=[dict(id='little-star',title='The little star’s way home',topic='little star',subtitle='Space · Kindness · 5 minutes',start='start',scenes={
 'start':scene('{pet} finds a tiny paper star beside the window. “I wonder where you belong?” A silver trail leads into an imaginary night sky.', [('Follow the silver trail','trail'),('Ask the moon for help','moon')],'space','☾'),
 'trail':scene('The trail ends at a cloud. The star is quiet. {pet} sits beside it. “We can work this out together.”',[('Make a sky map','map'),('Sing a gentle star song','song')],'space','✦'),
 'moon':scene('The moon glows softly. “Some stars belong in the sky. Some belong in a home full of stories.” {pet} looks at the little paper star.',[('Make a home on our wall','home'),('Ask the star what it likes','ask')],'space','☾'),
 'map':scene('You draw a map full of dots. The little star points to a window. It looks just like yours!',[('Follow the window light','home')],'space','✧'),
 'song':scene('Your quiet song sounds like home. The star twinkles toward the window. “Perhaps home is where we feel welcome,” says {pet}.',[('Welcome the star home','home')],'space','♪'),
 'ask':scene('The star gives a tiny rustle. It wants to be near your pictures. {pet} smiles. “We remembered to listen.”',[('Find a place on our wall','home')],'space','✦'),
 'home':scene('You hang the star near your art. It was a pretend journey, but the kindness was real. “Welcome home,” whispers {pet}.',[],'sunset','★')
}),dict(id='quiet-shell',title='The quiet shell',topic='ocean shell',subtitle='Ocean · Listening · 4 minutes',start='start',scenes={
 'start':scene('On an imaginary beach, {pet} spots a beautiful shell. A tiny crab is resting beside it. “Shall we look closer?”',[('Watch quietly','watch'),('Say a gentle hello','hello')],'ocean','≈'),
 'watch':scene('You notice the crab slowly moving toward the shell. Maybe this is its home. {pet} waits with you.',[('Give the crab space','space'),('Draw what we see','draw')],'ocean','≈'),
 'hello':scene('“Hello, little neighbour,” says {pet}. The crab pauses. You leave plenty of room so it can choose where to go.',[('Wait patiently','space'),('Make a picture of the beach','draw')],'ocean','≈'),
 'space':scene('The crab settles beside the shell. You sit a little further away and listen to the pretend waves. Sometimes helping means giving space.',[('Remember our quiet discovery','end')],'ocean','≈'),
 'draw':scene('You make a shell shape in the sand. “We can keep a picture and leave the beach as we found it,” says {pet}.',[('Keep the memory','end')],'ocean','◌'),
 'end':scene('The shell stays on the beach. You take a lovely memory home. {pet} remembers how carefully you watched and listened.',[],'ocean','♡')
}),dict(id='small-seed',title='The seed that took its time',topic='patient little seed',subtitle='Nature · Patience · 4 minutes',start='start',scenes={
 'start':scene('{pet} finds a little seed in our story garden. “What could this become?” You tuck it gently into soil.',[('Give it a little water','water'),('Find it a sunny place','sun')],'meadow','✿'),
 'water':scene('The soil is gently damp. Now our seed needs sunlight and time. Nothing changes straight away, and that is okay.',[('Make a picture while we wait','wait'),('Tell the seed a gentle story','story')],'meadow','◌'),
 'sun':scene('A warm patch of light reaches the pot. You add a little water. “Growing takes its own time,” says {pet}.',[('Make a picture while we wait','wait'),('Tell the seed a gentle story','story')],'meadow','☀'),
 'wait':scene('In our story, several days pass. You draw what you imagine the plant might look like. Then one morning, a tiny green shoot appears.',[('Look closely together','end')],'meadow','✿'),
 'story':scene('You tell a story about a giant garden. Several story-days pass. The plant grows slowly, with soil, light, water and time.',[('Look for the little shoot','end')],'meadow','✿'),
 'end':scene('The shoot is small and wonderful. {pet} smiles. “Small beginnings count.” You keep a memory of the seed that grew in its own time.',[],'meadow','✿')
})]
pack=dict(schema=1,id='meadow',version=1,title='Meadow friends',drawings=drawings,puzzles=puzzles,stories=stories)
(ROOT/'assets/content/meadow.json').write_text(json.dumps(pack,ensure_ascii=False,indent=2)+'\n')
print(f'Wrote {len(drawings)} drawings, {len(puzzles)} puzzles, {len(stories)} stories')
