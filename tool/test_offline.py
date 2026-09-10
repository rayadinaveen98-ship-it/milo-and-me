"""Tests runnable here: actual pack integrity, SQL atomicity, manifest/build structure.
Flutter engine/widget suites live in test/ and require Flutter.
"""
import copy, json, sqlite3, unittest, re
from pathlib import Path
from validate_content import validate
ROOT=Path(__file__).resolve().parents[1]
PACK=json.loads((ROOT/'assets/content/meadow.json').read_text())
class PackTests(unittest.TestCase):
 def test_original_pack(self):self.assertEqual(validate(PACK),{'drawings':24,'puzzles':55,'stories':12})
 def bad(self,edit):
  p=copy.deepcopy(PACK);edit(p)
  with self.assertRaises(ValueError):validate(p)
 def test_unknown_schema(self):self.bad(lambda p:p.update(schema=99))
 def test_duplicate_identity(self):self.bad(lambda p:p['puzzles'][0].update(id='flower'))
 def test_out_of_bounds_stroke(self):self.bad(lambda p:p['drawings'][0]['steps'][0]['points'][0].__setitem__(0,1.2))
 def test_nonfinite_stroke(self):self.bad(lambda p:p['drawings'][0]['steps'][0]['points'][0].__setitem__(0,float('nan')))
 def test_unknown_engine(self):self.bad(lambda p:p['puzzles'][0].update(engine='external-code'))
 def test_empty_answer(self):self.bad(lambda p:p['puzzles'][0].update(answer=[]))
 def test_unsolvable(self):self.bad(lambda p:p['puzzles'][0].update(answer=['not-an-option']))
 def test_broken_branch(self):self.bad(lambda p:p['stories'][0]['scenes']['start']['choices'][0].update(next='missing'))
 def test_dead_end_loop(self):self.bad(lambda p:p['stories'][0]['scenes']['home'].update(choices=[{'label':'Loop','next':'home'}]))
 def test_every_engine_has_content(self):self.assertEqual({p['engine'] for p in PACK['puzzles']},{'match','sort','sequence','spatial','logic'})
 def test_every_story_has_choices(self):self.assertTrue(all(any(len(s['choices'])>1 for s in p['scenes'].values()) for p in PACK['stories']))
class SqlTests(unittest.TestCase):
 def setUp(self):
  self.db=sqlite3.connect(':memory:')
  src=(ROOT/'lib/data/database.dart').read_text()
  for sql in re.findall(r"customStatement\(\s*'(CREATE TABLE [^']+)'\s*,?\s*\)",src):self.db.execute(sql)
 def tearDown(self):self.db.close()
 def test_world_roundtrip(self):
  payload=json.dumps({'nickname':'Friend','memories':[{'kind':'drawing','title':'Flower'}]})
  self.db.execute('INSERT INTO world VALUES(1,?)',(payload,));self.db.commit()
  self.assertEqual(json.loads(self.db.execute('SELECT payload FROM world').fetchone()[0])['memories'][0]['title'],'Flower')
 def test_failed_transaction_preserves_creation(self):
  self.db.execute('INSERT INTO world VALUES(1,?)',('old',));self.db.commit()
  try:
   with self.db:self.db.execute('UPDATE world SET payload=? WHERE id=1',('new',));self.db.execute('INSERT INTO world VALUES(2,?)',('bad',))
  except sqlite3.IntegrityError:pass
  self.assertEqual(self.db.execute('SELECT payload FROM world').fetchone()[0],'old')
 def test_draft_table_present(self):
  self.db.execute('INSERT INTO drawing_drafts VALUES(?,?)',('flower','{"strokes":[]}'))
  self.assertEqual(self.db.execute('SELECT COUNT(*) FROM drawing_drafts').fetchone()[0],1)
 def test_all_local_tables_created(self):self.assertEqual({r[0] for r in self.db.execute("SELECT name FROM sqlite_master WHERE type='table'")},{'world','packs','drawing_drafts','session','creations','pack_media'})
class DeliveryTests(unittest.TestCase):
 def test_no_sensitive_permissions(self):
  text=(ROOT/'android/app/src/main/AndroidManifest.xml').read_text()
  for p in ['RECORD_AUDIO','ACCESS_FINE_LOCATION','READ_CONTACTS','AD_ID','CAMERA']:self.assertNotIn(p,text)
  self.assertIn('android:allowBackup="false"',text)
 def test_every_asset_exists(self):
  for f in ['audio/room.wav','audio/reward.wav','brand/app-icon-512.png','content/meadow.json']:self.assertTrue((ROOT/'assets'/f).is_file())
 def test_no_fake_release_signing(self):self.assertNotIn('getByName("debug")',(ROOT/'android/app/build.gradle.kts').read_text())
if __name__=='__main__':unittest.main(verbosity=2)
