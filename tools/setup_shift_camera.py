"""Create an isolated camera environment from a Python 3.10–3.12 installation."""
from pathlib import Path
import os
import subprocess
import sys
import venv


def main():
    if not (3, 10) <= sys.version_info[:2] <= (3, 12):
        raise SystemExit('Run this helper with Python 3.10–3.12 (3.12 recommended).')
    root = Path(__file__).resolve().parents[1]
    environment = root / '.venv-gesture'
    venv.EnvBuilder(with_pip=True).create(environment)
    python = environment / ('Scripts/python.exe' if os.name == 'nt' else 'bin/python')
    subprocess.run([str(python), '-m', 'pip', 'install', '-r',
                    str(root / 'tools/gesture-requirements.txt')], check=True)
    subprocess.run([str(python), '-c',
                    'import cv2, mediapipe as mp; assert hasattr(mp, "solutions"); '
                    'print("OpenCV", cv2.__version__, "MediaPipe", mp.__version__)'], check=True)
    print('Camera dependencies ready. Start the game and click Camera; video stays on this computer.')


if __name__ == '__main__':
    main()
