"""Offline structural checks. NOT a substitute for dart analyze or compilation."""
from pathlib import Path
import re, sys
root=Path(__file__).resolve().parents[1]
errors=[]
for f in root.rglob('*.dart'):
 text=f.read_text();stack=[];i=0
 while i<len(text):
  if text.startswith('//',i):
   j=text.find('\n',i);i=len(text) if j<0 else j;continue
  if text.startswith('/*',i):
   j=text.find('*/',i+2);i=len(text) if j<0 else j+2;continue
  ch=text[i]
  if ch in "\"'":
   quote=ch*3 if text.startswith(ch*3,i) else ch;i+=len(quote)
   while i<len(text):
    if text[i]=='\\':i+=2;continue
    if text.startswith(quote,i):i+=len(quote);break
    i+=1
   continue
  if ch in '([{':stack.append((ch,i))
  if ch in ')]}':
   if not stack or stack[-1][0]!='([{'[')]}'.index(ch)]:
    errors.append(f'{f.relative_to(root)}:{text[:i].count(chr(10))+1}: unexpected {ch}');break
   stack.pop()
  i+=1
 else:
  for ch,j in stack:errors.append(f'{f.relative_to(root)}:{text[:j].count(chr(10))+1}: unclosed {ch}')
 for imp in re.findall(r"import\s+'([^']+)'",text):
  if ':' not in imp and not (f.parent/imp).exists():errors.append(f'{f}: missing import {imp}')
if errors: print('\n'.join(errors));sys.exit(1)
print('Dart delimiter and relative-import checks passed (not compilation).')
