"""Validate authored pack data without needing Flutter. Runtime validates independently."""
import json, math, sys
from pathlib import Path

def validate(p):
 def need(ok, reason):
  if not ok: raise ValueError(reason)
 need(isinstance(p,dict) and p.get('schema')==1,'Unsupported schema')
 need(isinstance(p.get('id'),str) and p['id'] and isinstance(p.get('version'),int) and p['version']>0,'Bad pack identity')
 ids=set()
 for kind in ['drawings','puzzles','stories']:
  need(isinstance(p.get(kind),list) and len(p[kind])<=200,'Invalid catalogue')
  for item in p[kind]:
   need(isinstance(item,dict),'Invalid content item')
   id=item.get('id');need(isinstance(id,str) and id and id not in ids,'Duplicate or missing identity');ids.add(id)
   need(isinstance(item.get('title'),str) and item['title'],'Missing title')
   if kind=='drawings':
    need(isinstance(item.get('steps'),list) and item['steps'],'Empty drawing')
    for step in item['steps']:
     need(isinstance(step.get('say'),str),'Missing drawing instruction')
     need(isinstance(step.get('points'),list) and len(step['points'])>=2,'Empty stroke')
     for pt in step['points']:
      need(isinstance(pt,list) and len(pt)==2 and all(isinstance(x,(int,float)) and not isinstance(x,bool) and math.isfinite(x) and 0<=x<=1 for x in pt),'Out-of-bounds point')
   if kind=='puzzles':
    need(item.get('engine') in ['match','sort','sequence','spatial','logic'],'Unknown puzzle engine')
    need(isinstance(item.get('prompt'),str),'Missing puzzle prompt')
    need(isinstance(item.get('options'),list) and len(item['options'])>=2,'Missing options')
    need(isinstance(item.get('answer'),list) and item['answer'] and all(a in item['options'] for a in item['answer']),'Unsolvable puzzle')
   if kind=='stories':
    scenes=item.get('scenes');need(isinstance(scenes,dict) and len(scenes)<=100 and item.get('start') in scenes,'Bad story start')
    visited=set();pending=[item['start']]
    while pending:
     id=pending.pop()
     if id in visited:continue
     visited.add(id);s=scenes[id]
     need(isinstance(s.get('text'),str) and isinstance(s.get('choices'),list),'Bad story scene')
     for c in s['choices']:
      need(isinstance(c.get('label'),str) and c.get('next') in scenes,'Broken story branch');pending.append(c['next'])
    can_end={id for id in visited if not scenes[id]['choices']}
    while True:
     added={id for id in visited if any(c['next'] in can_end for c in scenes[id]['choices'])}
     if added<=can_end:break
     can_end|=added
    need(can_end==visited,'Story contains a branch with no ending')
    need(visited==set(scenes),'Unreachable authored scene')
 return {k:len(p[k]) for k in ['drawings','puzzles','stories']}

if __name__=='__main__':
 path=Path(sys.argv[1]) if len(sys.argv)>1 else Path(__file__).resolve().parents[1]/'assets/content/meadow.json'
 p=json.loads(path.read_text());print(json.dumps({'file':str(path),'valid':True,'counts':validate(p)},indent=2))
