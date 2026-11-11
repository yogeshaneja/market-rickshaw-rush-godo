"""Run actual Godot imports/tests. Treat SCRIPT ERROR as failure even if Godot exits zero."""
import argparse,subprocess,pathlib,re,sys
parser=argparse.ArgumentParser();parser.add_argument('--godot',default='godot');args=parser.parse_args()
root=pathlib.Path(__file__).resolve().parents[1]
commands=[(['--editor','--import','--quit'],None),(['--script','res://tests/test_runner.gd'],'RUNNER CHECKS:'),(['--script','res://tests/test_ui.gd'],'UI/STORE CHECKS:'),(['--script','res://tests/test_presentation.gd'],'PRESENTATION CHECKS:')]
for tail,marker in commands:
 try:r=subprocess.run([args.godot,'--headless','--path',str(root),*tail],capture_output=True,text=True,timeout=60)
 except (OSError,subprocess.TimeoutExpired) as error:print('CHECK BLOCKED:',error);sys.exit(1)
 output=r.stdout+'\n'+r.stderr
 if r.returncode or re.search(r'(?m)^(?:SCRIPT ERROR|ERROR):',output) or marker and marker not in output:
  print(output);sys.exit(1)
 for line in output.splitlines():
  if 'CHECKS:' in line or 'Spawn safety:' in line:print(line)
print('Godot import and all headless suites passed. No rendered/device check is implied.')
