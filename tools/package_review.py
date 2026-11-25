"""Export and smoke-test a Godot project pack for review; standard library only."""
import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
REPOSITORY = "https://github.com/sd5913/forlives--magic_kitchen"
ERROR_MARKERS = ("SCRIPT ERROR:", "ERROR:", "Assertion failed")


def run(arguments, log_path, timeout=180):
    result = subprocess.run(arguments, cwd=ROOT, capture_output=True, text=True,
                            timeout=timeout)
    output = result.stdout + result.stderr
    log_path.write_text(output, encoding="utf-8")
    if result.returncode or any(marker in output for marker in ERROR_MARKERS):
        raise RuntimeError("Command failed; see " + str(log_path))
    return output.strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", required=True, help="Godot 4.7.2 executable")
    parser.add_argument("--output", default=str(ROOT / "build" / "review_candidate"))
    args = parser.parse_args()
    output = Path(args.output).expanduser().resolve()
    # Exported files are deliberately ignored and must never overwrite source files.
    if output == ROOT or output == ROOT / "game" or ROOT / "game" in output.parents:
        parser.error("Choose an output directory outside game/ and the repository root itself.")
    output.mkdir(parents=True, exist_ok=True)
    logs = output / "checks"
    logs.mkdir(exist_ok=True)
    try:
        engine = run([args.godot, "--version"], logs / "engine.txt")
        if not engine.startswith("4.7.2."):
            raise RuntimeError("Use the project's Godot 4.7.2 Standard version.")
        run([args.godot, "--headless", "--path", str(ROOT / "game"),
             "--editor", "--import", "--quit"], logs / "import.log")
        pack = output / "magic_kitchen.pck"
        run([args.godot, "--headless", "--path", str(ROOT / "game"),
             "--export-pack", "Project Pack", str(pack)], logs / "export.log")
        if not pack.is_file() or pack.stat().st_size == 0:
            raise RuntimeError("Export did not produce a non-empty project pack.")
        run([args.godot, "--headless", "--main-pack", str(pack), "--quit-after", "10"],
            logs / "launch.log")
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        print(str(error), file=sys.stderr)
        return 1
    commit = subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT,
                            capture_output=True, text=True, check=True).stdout.strip()
    dirty = bool(subprocess.run(["git", "status", "--porcelain"], cwd=ROOT,
                               capture_output=True, text=True, check=True).stdout)
    metadata = {
        "repository": REPOSITORY, "source_commit": commit,
        "working_tree_has_changes": dirty, "godot": engine,
        "built_at_utc": datetime.now(timezone.utc).isoformat(),
        "verified_host": platform.system(),
        "checks": ["source_import", "project_pack_export", "headless_pack_startup"],
        "not_verified_by_this_tool": ["human_playtest", "camera_accuracy", "other_operating_systems"],
        "distribution_status": "review_candidate_asset_permissions_pending",
    }
    (output / "build_info.json").write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    (output / "CANVAS-URL.txt").write_text(REPOSITORY + "\n", encoding="utf-8")
    for name in ("READINESS-2026-11-25.md", "PLAYTEST-RECORD.md", "FEEDBACK-AND-CHANGES.md"):
        shutil.copy2(ROOT / "docs" / "assessment" / name, output / name)
    licenses = output / "licenses"
    licenses.mkdir(exist_ok=True)
    shutil.copy2(ROOT / "game" / "assets" / "fonts" / "bree_serif_license.txt", licenses)
    (output / "README.md").write_text("""# Magic Kitchen review candidate / 候选试玩包

Install Godot 4.7.2 Standard, then run its executable with:

先安装 Godot 4.7.2 Standard，再使用对应可执行文件启动：

```sh
Godot --main-pack magic_kitchen.pck
```

Replace `Godot` with the executable's actual path; run from this folder.

请将 `Godot` 替换为实际可执行文件路径，在本目录运行。

Accept a ticket. Roast: 1 put in, 2 take out, 3 slice. Prepare: 1 duck,
2 hawthorn, 3 scallion, 4 cucumber, 5 sauce; Space rolls. Click Complete order,
wait three seconds, then return. Mouse cards work too. Esc pauses;
focus loss pauses until explicit resume.

接单。烤炉：1 放入、2 取出、3 片鸭。料理：1 鸭肉、2 山楂、3 葱、
4 黄瓜、5 酱，空格卷制。点击完成订单，三秒后返回；也可鼠标点击卡片。
Esc 暂停，窗口失焦后需手动继续。

This is a project pack, not a standalone application. It needs no API key.
Camera launching requires the source checkout and its separate environment.
The tool checks import, export and headless startup on the recorded host;
it does not establish a human trial or verification on another OS.
Final module visuals, rule reconciliation and reference-art permissions remain open.

这是需要 Godot 的资源包，不是独立应用，不需要 API 密钥。
摄像头启动需要源码和另外配置的环境。本工具检查记录平台的导入、导出及无窗口启动，
不能代表真人试玩或其他系统验证。最终模块视觉、规则统一及参考图许可仍待处理。

Source, full setup and credits / 源码、运行说明及致谢：
https://github.com/sd5913/forlives--magic_kitchen

Canvas takes the repository URL, not this local folder. Keep the same repository
accessible through the deadline. See the readiness document for the verified receipt.

Canvas 提交仓库 URL，不提交本机目录；截止前持续完善并保持同一仓库可访问。
已确认的提交回执见交付核对文件。
""", encoding="utf-8")
    archive = output.parent / (output.name + ".zip")
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as bundle:
        names = ["magic_kitchen.pck", "build_info.json", "CANVAS-URL.txt", "README.md",
                 "READINESS-2026-11-25.md", "PLAYTEST-RECORD.md", "FEEDBACK-AND-CHANGES.md",
                 "licenses/bree_serif_license.txt", "checks/engine.txt", "checks/import.log",
                 "checks/export.log", "checks/launch.log"]
        for name in names:
            path = output / name
            bundle.write(path, path.relative_to(output.parent))
    with zipfile.ZipFile(archive) as bundle:
        if bundle.testzip() is not None:
            print("ZIP integrity check failed", file=sys.stderr)
            return 1
    print("Review pack exported and startup checked: " + str(archive))
    return 0


if __name__ == "__main__":
    sys.exit(main())
