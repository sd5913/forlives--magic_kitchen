"""Run gameplay regressions with an explicitly installed Godot executable."""
import argparse
from pathlib import Path
import shutil
import subprocess
import sys

SCRIPTS = [
    'tests/test_order_manager.gd',
    'tests/test_order_station.gd',
    'tests/test_playable_shift.gd',
    'scenes/cooking_station/test_cooking_station.gd',
    'tests/test_shift_flow.gd',
    'tests/test_shift_udp.gd',
    'tests/test_shift_ui.gd',
    'tests/test_approved_order_ui.gd',
]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--godot', default=shutil.which('godot') or shutil.which('Godot'))
    args = parser.parse_args()
    if not args.godot:
        parser.error('Provide --godot with the Godot 4.7.2 executable path.')
    root = Path(__file__).resolve().parents[1]
    for script in SCRIPTS:
        try:
            result = subprocess.run([args.godot, '--headless', '--max-fps', '60', '--path', str(root / 'game'),
                                     '--script', 'res://' + script],
                                    capture_output=True, text=True, timeout=90)
        except subprocess.TimeoutExpired as error:
            print('Timed out: ' + script)
            for captured in (error.stdout, error.stderr):
                if captured:
                    print(captured.decode('utf-8', errors='replace') if isinstance(captured, bytes) else captured)
            return 1
        output = result.stdout + result.stderr
        print(output.strip())
        if result.returncode or any(marker in output for marker in
                                    ('SCRIPT ERROR:', 'ERROR:', 'FAIL:', 'Assertion failed')):
            return 1
    print('All {} Godot suites passed. This does not validate camera hardware or a human playtest.'.format(len(SCRIPTS)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
