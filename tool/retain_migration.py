"""Generate the first migration with Supabase CLI; retain exact tested SQL."""
import pathlib, subprocess
root=pathlib.Path('supabase/migrations')
files=list(root.glob('*_parent_v07.sql'))
source=pathlib.Path('supabase/schema.sql').read_text()
if not files:
    for args in [[],['migration'],['migration','new']]:
        subprocess.run(['supabase',*args,'--help'],check=True,stdout=subprocess.DEVNULL)
    subprocess.run(['supabase','migration','new','parent_v07'],check=True)
    files=list(root.glob('*_parent_v07.sql'))
    assert len(files)==1
    files[0].write_text(source)
else:
    assert len(files)==1 and files[0].read_text()==source, 'Schema differs from retained migration; review migration changes explicitly.'
