from pathlib import Path
import subprocess

name = "game/scenes/cooking_station/cooking_station_layered.tscn"
Path(name).write_bytes(subprocess.check_output(["git", "show", "HEAD:" + name]))
