"""Idempotent v0.3 authored expansion; retain all original v0.1 identities."""
import json,math
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'assets/content/meadow.json';pack=json.loads(p.read_text())
def ellipse(x,y,rx,ry):return [[round(x+rx*math.cos(t*math.tau/40),4),round(y+ry*math.sin(t*math.tau/40),4)] for t in range(41)]
def stroke(say,points):return {'say':say,'points':points}
def lesson(id,title,theme,steps):return {'id':id,'title':title,'topic':title.lower(),'theme':theme,'subtitle':theme+' · Draw together','steps':[stroke(*s) for s in steps]}
new=[
lesson('longneck','A gentle longneck','Dinosaurs',[
 ('A wide oval begins the body.',ellipse(.48,.62,.25,.16)),('A long neck curves up to a little head.',[[.65,.55],[.68,.3],[.72,.2],[.84,.2],[.88,.26],[.85,.32],[.78,.32],[.78,.64]]),('Two sturdy legs reach the ground.',[[.33,.72],[.33,.9],[.42,.9],[.42,.76]]),('The other leg follows.',[[.56,.76],[.56,.9],[.65,.9],[.65,.73]]),('A tail waves behind.',[[.25,.58],[.1,.47],[.18,.66],[.25,.69]]),('Add a friendly eye.',ellipse(.81,.255,.012,.016))]),
lesson('dino-print','Dinosaur footprints','Dinosaurs',[
 ('Three toes make one imagined footprint.',[[.22,.44],[.17,.23],[.27,.34],[.31,.13],[.35,.34],[.47,.24],[.41,.46],[.32,.57],[.22,.44]]),('Another footprint goes further along.',[[.55,.74],[.5,.53],[.6,.64],[.64,.43],[.68,.64],[.8,.54],[.74,.76],[.65,.87],[.55,.74]]),('A curving trail joins our story.',[[.23,.7],[.3,.76],[.38,.73],[.45,.7]])]),
lesson('dino-egg','A speckled egg','Dinosaurs',[
 ('An egg is wider near its base.',[[.5,.14],[.35,.26],[.26,.48],[.27,.7],[.36,.82],[.6,.84],[.73,.7],[.73,.48],[.64,.26],[.5,.14]]),('Draw a round spot.',ellipse(.4,.4,.055,.07)),('A different spot can be an oval.',ellipse(.6,.59,.06,.04)),('One little spot near the bottom.',ellipse(.41,.73,.03,.025))]),
lesson('moon','A smiling crescent','Space',[
 ('Sweep around the outside of the moon.',[[.62,.15],[.42,.16],[.26,.28],[.19,.47],[.23,.67],[.38,.81],[.61,.85],[.76,.72]]),('A smaller curve completes the crescent.',[[.76,.72],[.55,.71],[.41,.59],[.38,.42],[.45,.27],[.62,.15]]),('Give the moon a sleepy eye.',[[.29,.43],[.31,.45],[.34,.43]]),('A little smile.',[[.28,.54],[.3,.57],[.34,.56]])]),
lesson('ring-planet','A ringed planet','Space',[
 ('A circle for a faraway planet.',ellipse(.5,.49,.22,.22)),('A wide oval becomes its pretend ring.',ellipse(.5,.51,.39,.09)),('Add a small neighbouring star.',[[.15,.14],[.17,.2],[.23,.2],[.18,.24],[.2,.3],[.15,.26],[.1,.3],[.12,.24],[.07,.2],[.13,.2],[.15,.14]]),('A tiny distant moon.',ellipse(.82,.8,.04,.04))]),
lesson('satellite','Our space messenger','Space',[
 ('Make a small square body.',[[.4,.36],[.6,.36],[.6,.62],[.4,.62],[.4,.36]]),('One solar panel reaches left.',[[.4,.43],[.12,.43],[.12,.59],[.4,.59]]),('One reaches right.',[[.6,.43],[.88,.43],[.88,.59],[.6,.59]]),('An antenna points upward.',[[.5,.36],[.5,.22],[.64,.15]]),('A panel line on each side.',[[.26,.43],[.26,.59]]),('Another panel line.',[[.74,.43],[.74,.59]])]),
lesson('turtle','A sea turtle','Ocean',[
 ('A wide shell.',ellipse(.49,.51,.23,.25)),('A small head peeks out.',ellipse(.49,.19,.075,.08)),('A left flipper.',[[.29,.37],[.12,.31],[.16,.5],[.26,.53]]),('A right flipper.',[[.69,.37],[.87,.31],[.82,.5],[.72,.53]]),('Two little back flippers.',[[.34,.7],[.26,.84],[.4,.77],[.58,.77],[.73,.84],[.64,.7]]),('A pattern on the shell.',[[.49,.3],[.35,.44],[.37,.63],[.49,.71],[.61,.63],[.64,.44],[.49,.3]])]),
lesson('crab','A sideways crab','Ocean',[
 ('An oval makes our crab.',ellipse(.5,.57,.22,.14)),('A claw opens on the left.',[[.3,.55],[.19,.39],[.12,.23],[.22,.31],[.28,.21],[.3,.37],[.19,.39]]),('A claw opens on the right.',[[.7,.55],[.81,.39],[.88,.23],[.78,.31],[.72,.21],[.7,.37],[.81,.39]]),('Left legs bend sideways.',[[.29,.59],[.16,.63],[.13,.74],[.22,.68],[.31,.68]]),('Right legs bend too.',[[.71,.59],[.84,.63],[.87,.74],[.78,.68],[.69,.68]]),('Two eyes.',ellipse(.42,.49,.025,.04)),('Another eye.',ellipse(.58,.49,.025,.04))]),
lesson('whale','A waving whale','Ocean',[
 ('A long curve for a whale.',[[.77,.63],[.7,.39],[.47,.31],[.24,.38],[.15,.55],[.22,.72],[.48,.77],[.68,.7],[.77,.63]]),('A tail lifts out of the water.',[[.77,.63],[.86,.46],[.95,.43],[.9,.61],[.78,.7]]),('A friendly eye.',ellipse(.3,.49,.02,.025)),('A little flipper.',[[.43,.61],[.56,.66],[.47,.74],[.43,.61]]),('A pretend spray curves up.',[[.43,.31],[.42,.18],[.33,.12]]),('And another spray.',[[.43,.31],[.46,.15],[.56,.11]])]),
lesson('octopus','Eight wiggly arms','Ocean',[
 ('A round head comes first.',[[.25,.48],[.23,.32],[.31,.18],[.5,.13],[.69,.18],[.77,.32],[.75,.48]]),('Four arms wiggle to the left.',[[.25,.48],[.1,.56],[.1,.64],[.26,.59],[.17,.75],[.22,.81],[.35,.64],[.31,.87],[.38,.88],[.44,.65],[.44,.91],[.5,.91]]),('Four arms wiggle to the right.',[[.5,.91],[.56,.91],[.56,.65],[.62,.88],[.69,.87],[.65,.64],[.78,.81],[.83,.75],[.74,.59],[.9,.64],[.9,.56],[.75,.48]]),('One curious eye.',ellipse(.4,.34,.03,.04)),('And another.',ellipse(.6,.34,.03,.04))]),
lesson('bird','A singing bird','Animals',[
 ('A round body.',ellipse(.47,.53,.23,.22)),('A little round head.',ellipse(.61,.29,.13,.13)),('A triangle beak.',[[.74,.26],[.87,.31],[.74,.35]]),('A wing folds in.',[[.36,.45],[.53,.53],[.36,.62],[.36,.45]]),('A tail fans out.',[[.25,.48],[.1,.38],[.12,.6],[.27,.62]]),('Two legs for perching.',[[.41,.75],[.4,.87],[.33,.87],[.52,.87],[.51,.75]])]),
lesson('cat','A cosy cat','Animals',[
 ('A head with two pointy ears.',[[.26,.56],[.23,.19],[.4,.32],[.6,.32],[.77,.19],[.74,.56],[.65,.7],[.35,.7],[.26,.56]]),('A little nose.',[[.46,.51],[.54,.51],[.5,.56],[.46,.51]]),('A left eye.',ellipse(.37,.44,.025,.035)),('A right eye.',ellipse(.63,.44,.025,.035)),('Whiskers stretch left.',[[.37,.57],[.13,.52],[.36,.62],[.14,.67]]),('Whiskers stretch right.',[[.63,.57],[.87,.52],[.64,.62],[.86,.67]])]),
lesson('apple','An apple for our picnic','Nature',[
 ('Two round shoulders make an apple.',[[.5,.28],[.35,.22],[.2,.33],[.17,.52],[.28,.78],[.43,.84],[.5,.8],[.59,.84],[.74,.76],[.83,.52],[.79,.33],[.64,.22],[.5,.28]]),('A short stem.',[[.5,.28],[.52,.13]]),('A leaf beside the stem.',[[.52,.18],[.69,.1],[.72,.18],[.52,.23]]),('A curved shine.',[[.3,.38],[.26,.48],[.28,.58]])]),
lesson('cloud','A rain cloud','Nature',[
 ('Round bumps join into a cloud.',[[.18,.48],[.1,.4],[.15,.28],[.29,.25],[.37,.13],[.53,.12],[.65,.25],[.79,.24],[.89,.37],[.83,.48],[.18,.48]]),('A raindrop points up.',[[.25,.59],[.2,.74],[.24,.81],[.3,.75],[.25,.59]]),('Another drop.',[[.5,.65],[.45,.8],[.49,.87],[.55,.81],[.5,.65]]),('One more.',[[.75,.55],[.7,.7],[.74,.77],[.8,.71],[.75,.55]])]),
lesson('mushroom','A woodland mushroom','Nature',[
 ('A wide cap like an umbrella.',[[.14,.48],[.26,.27],[.43,.16],[.6,.17],[.77,.3],[.86,.48],[.14,.48]]),('A sturdy stalk.',[[.42,.48],[.37,.82],[.62,.82],[.58,.48]]),('One spot.',ellipse(.36,.34,.05,.04)),('Another spot.',ellipse(.58,.29,.05,.05)),('A little grass nearby.',[[.15,.85],[.18,.73],[.23,.84],[.27,.72],[.3,.85]])]),
lesson('rainbow','A rainbow arch','Nature',[
 ('A large arch joins two sides.',[[.5+.39*math.cos(t*math.pi/40),.78-.59*math.sin(t*math.pi/40)] for t in range(41)]),('A smaller arch follows the same curve.',[[.5+.31*math.cos(t*math.pi/40),.78-.48*math.sin(t*math.pi/40)] for t in range(41)]),('Another arch inside.',[[.5+.23*math.cos(t*math.pi/40),.78-.37*math.sin(t*math.pi/40)] for t in range(41)]),('One last arch. Choose your own colours.',[[.5+.15*math.cos(t*math.pi/40),.78-.26*math.sin(t*math.pi/40)] for t in range(41)])]),
]
for item in new:
 pack['drawings']=[x for x in pack['drawings'] if x['id']!=item['id']]+[item]
themes=['Dinosaurs','Space','Ocean','Animals','Nature']
# Each row is a distinct authored problem, using the same five engines.
rows={
'match':[
 ('A moon-shaped cushion','Find the crescent cushion for Milo.',['☾','★','●'],['☾'],'☾'),
 ('A square window','Find a square for our rocket window.',['▲','■','●'],['■'],'□'),
 ('A triangle flag','Which flag matches our tent?',['■','▲','●'],['▲'],'△'),
 ('A heart keepsake','Find a heart for our friendship shelf.',['♥','★','●'],['♥'],'♡'),
 ('Two ocean bubbles','Find the card with two bubbles.',['●','● ●','● ● ●'],['● ●'],'○ ○'),
 ('Three dinosaur eggs','Find three eggs for our pretend nest.',['○ ○','○ ○ ○','○'],['○ ○ ○'],'● ● ●'),
 ('Striped pebbles','Copy the two shapes on our pebble card.',['■ ●','● ■','▲ ■'],['■ ●'],'□ ○'),
 ('Starry curtains','Which curtain pattern matches?',['★ ● ★','● ★ ●','★ ★ ●'],['★ ● ★'],'☆ ○ ☆')],
'sort':[
 ('Tiny to tall','Milo packs towers from shortest to tallest.',['▮▮▮','▮','▮▮'],['▮','▮▮','▮▮▮'],''),
 ('Count our shells','Arrange the shell baskets from one to three.',['3','1','2'],['1','2','3'],''),
 ('Growing a flower','What happens first, next and last?',['flower','seed','sprout'],['seed','sprout','flower'],''),
 ('Painting together','Put our art-making steps in order.',['display','draw','choose paper'],['choose paper','draw','display'],''),
 ('A pretend hatchling','Put our dinosaur story in order.',['grown dinosaur','egg','hatchling'],['egg','hatchling','grown dinosaur'],''),
 ('A space trip','Arrange our imaginary adventure.',['return home','land on moon','launch'],['launch','land on moon','return home'],''),
 ('Our story night','What do we do in order?',['close book','choose book','read together'],['choose book','read together','close book'],''),
 ('A picnic plan','Put the picnic moments in order.',['tidy up','pack basket','share picnic'],['pack basket','share picnic','tidy up'],'')],
'sequence':[
 ('Dinosaur steps','Which shape comes next?',['▲','■','●'],['▲'],'▲ ■ ▲ ■ ?'),
 ('Moon and star','Continue the sky pattern.',['★','☾','●'],['★'],'☾ ★ ☾ ?'),
 ('Ocean pairs','Finish our bubble pattern.',['■','●','▲'],['●'],'● ● ■ ● ?'),
 ('Garden fence','What comes next on our fence?',['▲','●','■'],['■'],'▲ ▲ ■ ▲ ▲ ?'),
 ('Four to five','Milo adds one shell. What comes next?',['3','5','7'],['5'],'2 3 4 ?'),
 ('Count by twos','Each basket gets two berries.',['5','6','8'],['6'],'2 4 ?'),
 ('A colour-free pattern','Finish the shape pattern.',['★','♥','■'],['♥'],'★ ♥ ♥ ★ ♥ ?'),
 ('One fewer cloud','One cloud drifts away each time.',['1','3','5'],['1'],'4 3 2 ?')],
'spatial':[
 ('Rocket tiles','Copy the rocket tiles, row by row.',['▲','■','●'],['▲','■','■','●'],'▲ ■ ■ ●'),
 ('Dinosaur stepping stones','Copy the stepping stones.',['●','■','▲'],['●','●','▲','■'],'● ● ▲ ■'),
 ('Ocean mosaic','Place the mosaic tiles in order.',['■','●','▲'],['■','●','●','■'],'■ ● ● ■'),
 ('Birdhouse roof','Copy the roof pattern.',['▲','■','●'],['▲','▲','■','■'],'▲ ▲ ■ ■'),
 ('Garden stepping squares','Follow the stone pattern.',['■','●','▲'],['■','●','▲','●','■'],'■ ● ▲ ● ■'),
 ('Space window frame','Rebuild our six-tile window.',['■','★','●'],['■','★','■','■','●','■'],'■ ★ ■ ■ ● ■'),
 ('A cosy rug','Copy the six rug patches.',['♥','■','●'],['♥','■','♥','■','♥','■'],'♥ ■ ♥ ■ ♥ ■'),
 ('Dino nest border','Place the border pieces in order.',['▲','○','■'],['▲','○','○','▲'],'▲ ○ ○ ▲')],
'logic':[
 ('A gentle welcome','A shy pretend dinosaur joins us. What could Milo do?',['offer space','shout loudly','chase it'],['offer space'],''),
 ('A missing colour','We want green paint in our pretend palette. Which pair can help?',['blue + yellow','red + blue','black + white'],['blue + yellow'],''),
 ('A quiet friend','Our friend wants a quiet game. What could we choose?',['look at a book','bang a drum','shout a song'],['look at a book'],''),
 ('A shell stays home','A crab lives in this shell. What should we do?',['leave it there','take it away','shake it'],['leave it there'],''),
 ('A fallen drawing','Our drawing fell from the pretend wall. What helps?',['put it back','throw it away','hide it'],['put it back'],''),
 ('A shared crayon','Milo and a friend need blue. What could help?',['take turns','grab it','hide it'],['take turns'],''),
 ('A dark pretend cave','Which prop helps our imaginary explorer see?',['torch','spoon','pillow'],['torch'],''),
 ('A windy day','Which toy uses the wind?',['kite','book','puzzle'],['kite'],'')]
}
for engine,problems in rows.items():
 for i,(title,prompt,options,answer,display) in enumerate(problems):
  id=f'core-{engine}-{i+1}'
  item=dict(id=id,title=title,topic=title.lower(),theme=themes[i%5],engine=engine,prompt=prompt,options=options,answer=answer,display=display,subtitle=engine.title()+' with Milo',hint='Look at the clues again. We can take our time.')
  pack['puzzles']=[x for x in pack['puzzles'] if x['id']!=id]+[item]
# Original branching mini-stories; each choice receives its own consequence.
stories=[
 ('dino-shadow','The enormous little shadow','Dinosaurs','sunset','▲',
  'A huge dinosaur shadow stretches across the pretend garden. {pet} pauses. The shadow looks tall, but its feet are very small.',
  'Look from another side','Ask who is there',
  'You move around the paper tree. The shadow becomes shorter. A little hatchling is standing beside a lantern. “I thought I looked enormous,” it says.',
  '“Hello,” says {pet} softly. A tiny voice answers, “I was trying to look brave.” A hatchling steps out, carrying a paper leaf.',
  'Move the pretend light','Sit beside the hatchling',
  'You move the pretend light and watch the shadow change. Big shadows can belong to little things. The hatchling invents a shadow dance for you.',
  'You sit together without asking the hatchling to be bigger or louder. Soon it shares its leaf. Being welcome feels better than looking enormous.',
  'The three friends make a tiny shadow theatre. {pet} remembers that looking again—and listening—can change a scary first guess.'),
 ('moon-mail','A letter for the moon','Space','space','☾',
  '{pet} finds an empty envelope in the pretend rocket. “What would the moon like to hear?” The window is full of quiet stars.',
  'Draw a moon picture','Write a kind greeting',
  'You draw the moon with a cosy scarf. A passing comet laughs gently. “That looks warm! But how will the moon know who sent it?”',
  'You choose the words “Thank you for lighting our pretend journey.” A little star offers to carry the message, but first it needs a safe place to fold it.',
  'Fold a paper moonboat','Ask the comet to help',
  'Your envelope becomes a pretend moonboat. You test it on a blanket sea. It tips once, so you fold a wider base and try again.',
  'The comet slows down to listen. Together you make a delivery map with three stars and a crescent. Asking for help becomes part of the adventure.',
  'The moon sends back a silver paper dot. It has no price and earns no points. It simply reminds {pet} of something kind you made together.'),
 ('lost-whale-song','The missing whale song','Ocean','ocean','≈',
  'Under a blanket ocean, a young whale has forgotten the last note of its song. {pet} can hear three gentle sounds: hum, splash, hum.',
  'Listen to the rhythm','Ask the whale how it feels',
  'You wait through a quiet pause. Another hum arrives. The whale smiles: the song was not broken. It had a space for breathing.',
  '“I feel rushed,” says the whale. {pet} sits on a pretend sea rock. “We can wait. Your song belongs to you.”',
  'Make a slow wave rhythm','Leave a quiet pause',
  'You move your hands like slow waves. The whale joins when it is ready. Your rhythms are different, and they still fit together.',
  'Nobody fills the silence. At last the whale adds a small new note. It sounds different from yesterday, and that is all right.',
  'The blanket ocean becomes quiet again. {pet} keeps a memory of listening patiently, and of a song that had room for everyone.'),
 ('fox-colour','The fox with the blue picture','Animals','meadow','♥',
  'A little fox paints a blue sun. Another animal says suns should be yellow. The fox turns its picture face down. {pet} notices.',
  'Ask about the picture','Show a surprising colour',
  '“It is the sun in my dream,” says the fox. In that dream the sky is peach and the grass is silver. {pet} wants to hear more.',
  'You draw a purple leaf beside the fox. “Pictures can show things we imagine too,” says {pet}. The fox peeks at the paper.',
  'Make a dream gallery','Invite a gentle question',
  'Each friend makes a different dream picture. You leave spaces between them so every picture has a home. No one chooses a winner.',
  'You ask, “What happens in your dream?” The fox tells a story about cool blue sunshine. The other animal listens and sees the picture differently.',
  'The blue sun goes on the pretend gallery wall. {pet} remembers that curiosity can make room for ideas that are different from our own.'),
 ('seed-secret','The seed that took its time','Nature','meadow','✿',
  'In an imaginary garden, {pet} plants a paper seed beside a tall flower. Nothing happens at once. “Perhaps this seed has its own pace,” says {pet}.',
  'Look for small changes','Make a care plan',
  'You notice a tiny bend in the pretend soil. It is easy to miss beside the tall flower. The garden has many kinds of growing.',
  'You draw a sun, a water drop and a clock. The plan leaves time to wait. {pet} puts away the measuring stick: this is not a race.',
  'Imagine tomorrow’s sprout','Enjoy the garden today',
  'You imagine two little leaves reaching up. They do not have to look exactly like the tall flower. You give the seed a hopeful name.',
  'You watch a paper butterfly and notice the leaf shapes nearby. There are things to enjoy while something new is growing.',
  'Later in your pretend story, the seed becomes a sprout. {pet} keeps your care-plan picture as a memory of patience, not of being first.'),
 ('dino-bridge','The bridge for different feet','Dinosaurs','meadow','■',
  'A pretend stream divides the dinosaur picnic. A longneck steps across, but a tiny hatchling cannot. {pet} looks at their very different feet.',
  'Ask the hatchling what helps','Test a small model bridge',
  '“I need stones closer together,” says the hatchling. You make room for its idea. The longneck offers to carry pretend building blocks.',
  'You build a model on the rug. One gap is too wide for a little toy foot. Finding the gap gives you a useful clue.',
  'Add a middle stepping stone','Build a wide flat path',
  'The new stone makes two small steps instead of one enormous jump. The hatchling chooses to try, and the friends wait nearby.',
  'You make a broad path from flat blocks. There is room for different feet and different speeds. Nobody needs to hurry.',
  'Everyone reaches the imaginary picnic. {pet} remembers that a good path can change to welcome more friends.'),
 ('star-map','The map with an empty space','Space','space','★',
  'The pretend star map has an empty corner. {pet} wonders whether a missing mark means the map is wrong—or whether there is more to discover.',
  'Ask a star traveller','Look for a new pattern',
  'The traveller says, “I have only seen part of the sky.” Its map is useful, but it is not everything. {pet} leaves room for a new idea.',
  'Three stars make a triangle you have not noticed before. You trace it with a finger. Looking slowly reveals a new path.',
  'Draw a possible route','Mark a question for later',
  'You draw your route with a dotted line to show it is a guess. A guess can help you explore without pretending you already know.',
  'You add a friendly question mark. “We can wonder about something without solving it today,” says {pet}.',
  'The map returns to your room with a little more detail and plenty of open space. {pet} remembers how you made room for curiosity.'),
 ('otter-tool','The otter’s impossible basket','Animals','ocean','○',
  'An otter tries to carry six pretend pebbles in one paw. Plop! They tumble onto the rug. {pet} sits down to think beside it.',
  'Try fewer at once','Look for something to carry them',
  'The otter carries two pebbles, then comes back. It takes more trips, but the pebbles stay safe. A smaller step can work well.',
  'You find a paper basket with a loose handle. It could help, but first you examine where the handle bends.',
  'Make a stronger paper handle','Ask friends to share the trips',
  'You fold a wider handle and test it with one pretend pebble before adding more. The otter likes testing an idea in small steps.',
  'Each friend chooses a little load. Nobody has to carry the same amount. Together they bring the pebbles to the pretend shore.',
  'The otter makes a pebble picture for everyone. {pet} remembers that trying another way and sharing work are both clever choices.'),
 ('garden-mystery','Who moved the garden colours?','Nature','sunset','✦',
  'The pretend garden looks golden where it looked green before. {pet} finds no spilled paint. The paper sun is lower in the sky.',
  'Look at the light','Ask a garden friend',
  'You hold a pretend leaf near the warm paper sun, then in the shade. The leaf has not changed into a new leaf, but it looks different.',
  'A butterfly says the garden looks different at different times. “Perhaps we can notice it together,” says {pet}.',
  'Draw two versions of the garden','Make a little noticing book',
  'One picture shows a bright morning, the other a gentle evening. Both belong to the same garden. You choose colours that tell each story.',
  'You put a leaf shape and a sunshine mark in your book. There is space for another observation on another day, with a grown-up nearby.',
  'The colour mystery becomes a question to enjoy. {pet} keeps your picture and suggests looking for changing light in your own room sometime.')]
for id,title,theme,bg,symbol,start,left,right,lt,rt,choice1,choice2,one,two,end in stories:
 def sc(text,choices,interaction=False):
  out={'text':text,'choices':[{'label':l,'next':n} for l,n in choices],'background':bg,'symbol':symbol,'emotion':'curious'}
  if interaction:out['interaction']={'label':'Touch our discovery','symbol':symbol,'message':'A little clue to remember together.'}
  return out
 item={'id':id,'title':title,'topic':title.lower(),'theme':theme,'subtitle':theme+' · A story together','start':'start','scenes':{
  'start':sc(start,[(left,'left'),(right,'right')]),'left':sc(lt,[(choice1,'one'),(choice2,'two')],True),
  'right':sc(rt,[(choice1,'one'),(choice2,'two')],True),'one':sc(one,[('Bring our memory home','end')]),
  'two':sc(two,[('Bring our memory home','end')]),'end':sc(end,[])}}
 pack['stories']=[x for x in pack['stories'] if x['id']!=id]+[item]
for kind in ['drawings','puzzles','stories']:
 for item in pack[kind]:
  item.setdefault('theme',{'rocket':'Space','fish':'Ocean','butterfly':'Animals','snail':'Animals','little-star':'Space','quiet-shell':'Ocean'}.get(item['id'],'Nature'))
  item.setdefault('access','sample' if item==pack[kind][0] else 'library')
for story in pack['stories']:
 if story['id'] in ['little-star','quiet-shell','dino-bridge','fox-colour']:story['milestone']='kindness'
pack['version']=3
pack['themes']=themes
p.write_text(json.dumps(pack,ensure_ascii=False,indent=2)+'\n')
print({kind:len(pack[kind]) for kind in ['drawings','puzzles','stories']})
