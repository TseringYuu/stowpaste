#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/paths.sh"

swift test --package-path "$APP_PACKAGE_DIR" ${SWIFT_BUILD_FLAGS:-} --list-tests >/dev/null

python3 - "$APP_PACKAGE_DIR" <<'PY'
import os
import shlex
import signal
import subprocess
import sys
import tempfile
import time

command = ["swift", "test", "--package-path", sys.argv[1]]
command += shlex.split(os.environ.get("SWIFT_BUILD_FLAGS", ""))
command += ["--skip-build", "--filter", "testMountedPanelRemainsBoundedAcrossRepeatedTextPastes"]
peak_kib = 0
failure = None
with tempfile.TemporaryDirectory(prefix="StowPastePasteMemory-") as workspace, tempfile.TemporaryFile() as log:
    environment = dict(os.environ, STOWPASTE_PASTE_MEMORY_CHECK="1", STOWPASTE_PASTE_MEMORY_WORK_DIR=workspace)
    process = subprocess.Popen(command, stdout=log, stderr=subprocess.STDOUT, start_new_session=True, env=environment)
    deadline = time.monotonic() + 60
    while process.poll() is None:
        rows = subprocess.check_output(["ps", "-axo", "pid=,ppid=,rss="], text=True)
        processes = [tuple(map(int, row.split())) for row in rows.splitlines()]
        owned = {process.pid}
        while True:
            descendants = {pid for pid, parent, _ in processes if parent in owned}
            if descendants <= owned:
                break
            owned.update(descendants)
        rss = [rss for pid, _, rss in processes if pid in owned]
        peak_kib = max(peak_kib, max(rss, default=0))
        if peak_kib > 512 * 1024:
            failure = f"paste regression exceeded the 512 MiB RSS limit (observed {peak_kib // 1024} MiB)"
        elif time.monotonic() >= deadline:
            failure = "paste regression exceeded the 60 second limit"
        if failure:
            for pid in sorted(owned, reverse=True):
                try:
                    os.kill(pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
            break
        time.sleep(0.05)
    process.wait()
    log.seek(0)
    sys.stdout.write(log.read().decode("utf-8", errors="replace"))
if failure or process.returncode:
    sys.exit(failure or process.returncode)
print(f"paste memory regression passed (observed peak {peak_kib // 1024} MiB, limit 512 MiB)")
PY
