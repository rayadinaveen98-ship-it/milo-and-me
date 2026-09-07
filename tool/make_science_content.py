"""Idempotent reviewed discovery content; real-world instructions live in code."""
import json
from pathlib import Path
path = Path('assets/content/meadow.json')
pack = json.loads(path.read_text())
def round_(prompt, pairs):
    return {'prompt': prompt, 'options': list(pairs), 'responses': pairs}
def activity(id_, title, template, rounds, safety='A'):
    return {'id': id_, 'title': title, 'topic': title.lower(), 'theme': 'Nature', 'safety': safety, 'template': template, 'rounds': rounds}
pack['science'] = [
 activity('colour-lab', 'Milo’s colour puddles', 'colour', [
  round_('Add a pretend paint colour to yellow.', {'Red': 'Red and yellow paint can make orange.', 'Blue': 'Blue and yellow paint can make green.'}),
  round_('Now add a pretend paint colour to blue.', {'Red': 'Red and blue paint can make purple.', 'Yellow': 'Yellow and blue paint can make green.'}),
  round_('How light shall our pretend green become?', {'A little white': 'White paint makes a lighter green.', 'More white': 'More white paint makes a paler green.'})]),
 activity('shadow-lab', 'A shadow for Milo', 'shadow', [
  round_('Move our pretend light. Watch the shadow stretch.', {'Near': 'With our light nearer the object, its shadow grows.', 'Far': 'Moving our light farther away makes this shadow smaller.'}),
  round_('Where shall our pretend light shine from?', {'Left': 'The shadow falls away from the light, to the right.', 'Right': 'The shadow falls to the left.'}),
  round_('Can light pass through our pretend object?', {'Clear glass': 'Clear glass lets much of the light through.', 'Cardboard': 'Cardboard blocks light and makes a dark shadow.'})]),
 activity('float-lab', 'The pretend pond', 'float', [
  round_('Choose something for our digital pond.', {'Cork': 'Our cork floats. It is less dense than water.', 'Stone': 'Our solid stone sinks. It is denser than water.'}),
  round_('Try two shapes made from the same pretend clay.', {'Ball': 'The solid clay ball sinks.', 'Hollow boat': 'A wide hollow clay boat can float by pushing aside enough water.'}),
  round_('What might change our pretend boat?', {'Add weight': 'Enough extra weight makes our boat sink.', 'Keep it empty': 'Our empty boat keeps floating.'})]),
 activity('plant-lab', 'A tiny digital seed', 'plant', [
  round_('Give our pretend seed a little water.', {'A few drops': 'Water helps a seed begin to grow.', 'Notice the seed': 'A seed holds the beginning of a plant.'}),
  round_('Our seed has roots and a shoot. Look closely.', {'Roots': 'Roots take up water and hold the plant in place.', 'Shoot': 'The shoot grows towards the light.'}),
  round_('Our pretend leaves have opened.', {'Light': 'Green leaves use light to help the plant make food.', 'Time': 'Real plants grow slowly. Our pretend garden skips ahead.'})]),
 activity('magnet-lab', 'Milo’s digital magnet', 'magnet', [
  round_('Choose an object for our digital magnet.', {'Iron nail': 'Iron is attracted to our magnet. This nail stays on screen.', 'Wood': 'Wood is not attracted to the magnet.'}),
  round_('Try another pretend material.', {'Steel clip': 'Many steel clips are attracted to magnets.', 'Plastic': 'Plastic is not attracted to our magnet.'}),
  round_('Bring two pretend magnet ends together.', {'Same poles': 'Matching poles push apart.', 'Opposite poles': 'Opposite poles pull together.'})]),
 activity('water-lab', 'A water drop’s journey', 'water', [
  round_('Where can our pretend puddle water go?', {'Into the air': 'Some liquid water becomes water vapour in the air.', 'Stay a while': 'Some water stays in the puddle while other water evaporates.'}),
  round_('Higher up, water vapour cools.', {'Make droplets': 'Tiny liquid droplets can gather into clouds.', 'Look at clouds': 'Clouds contain tiny water droplets or ice crystals.'}),
  round_('The cloud’s drops grow heavier.', {'Rain': 'Water falls as rain and gathers again.', 'Follow a stream': 'Streams can carry water towards lakes and the sea.'})]),
 activity('pattern-lab', 'Nature’s repeating shapes', 'pattern', [
  round_('Leaf, pebble, leaf, pebble… what could come next?', {'Leaf': 'A leaf continues our repeating pair.', 'Flower': 'A flower starts a new pattern. We can invent one too.'}),
  round_('Look at our pretend butterfly wings.', {'Left wing': 'The two sides have matching shapes.', 'Right wing': 'Many butterfly wing patterns are roughly symmetrical.'}),
  round_('Make a pattern with Milo.', {'Big, small': 'Big, small, big, small: a repeating size pattern.', 'Round, long': 'Round, long, round, long: a repeating shape pattern.'})]),
]
for id_, title, template, safety in [('red-noticing','Three red things','red-objects','B'), ('pattern-noticing','Patterns from our seat','room-patterns','B'), ('leaf-noticing','Leaf shapes together','leaf-shapes','C')]:
    pack['science'].append(activity(id_, title, template, [round_('Reviewed observation', {'I noticed it':'Noticing is lovely.', 'Imagine it instead':'Imagining is lovely.'}) for _ in range(3)], safety))
pack['version'] = 6
path.write_text(json.dumps(pack, ensure_ascii=False, indent=2) + '\n')
