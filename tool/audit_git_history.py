"""Scan tracked history for common credential formats without printing values.
This bounded pattern audit supplements review; it cannot prove no secret exists.
"""
from pathlib import Path
import re, subprocess, sys
ROOT=Path(__file__).resolve().parents[1]
def git(*args): return subprocess.check_output(['git','-C',str(ROOT),*args])
patterns={
 'private-key': r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
 'github-token': r'\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})',
 'aws-key': r'\b(?:AKIA|ASIA)[A-Z0-9]{16}\b',
 'jwt': r'\beyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}',
 'environment-secret': r'(?im)^[A-Z_]*(?:SECRET|TOKEN|PASSWORD|API_KEY|PUBLISHABLE_KEY)[ \t]*=[ \t]*[^\s#]+'
}
findings=[];count=0
for row in git('rev-list','--objects','--all').decode().splitlines():
 oid,_,path=row.partition(' ')
 if git('cat-file','-t',oid).strip()!=b'blob':continue
 data=git('cat-file','-p',oid)
 if b'\0' in data:continue
 count+=1;text=data.decode('utf-8',errors='replace')
 for label,pattern in patterns.items():
  if re.search(pattern,text):findings.append((path,label))
if findings:
 for path,label in sorted(set(findings)):print(f'Review required: {path} ({label})')
 sys.exit(1)
print(f'Credential-pattern audit passed for {count} text blobs in Git history. No secret values printed.')
