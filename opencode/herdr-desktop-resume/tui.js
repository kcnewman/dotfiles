import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";

export default {
  id: "herdr-desktop-resume",
  setup(api) {
    if (!process.env.HC_TERMINAL_ID) return;
    const helper = join(homedir(), ".local/bin/herdr-resume");
    let recorded;
    let pending = false;
    const timer = setInterval(() => {
      if (pending) return;
      try {
        const route = api.ui.router.current();
        if (route?.type !== "session" || !route.sessionID) return;
        const session = api.data.session.root?.(route.sessionID) || route.sessionID;
        const info = api.data.session.get(session);
        if (!info || info.parentID || session === recorded) return;
        pending = true;
        execFile(helper, ["opencode", session, String(process.pid)], { timeout: 2000 }, (error) => {
          if (!error) recorded = session;
          pending = false;
        });
      } catch {
        pending = false;
      }
    }, 750);
    timer.unref?.();
    return () => clearInterval(timer);
  },
};
