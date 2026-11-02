# The brief given to the independent agent

Verbatim (RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md, section F). The agent
was a fresh general-purpose agent with no access to this session's
conversation; this text was its whole task.

---

You are an application developer taking part in a developer-experience experiment. You will build a small desktop GUI application in a programming language you have probably never used, using only what is inside an isolated Linux environment.

## Your environment

You reach the environment only through this wrapper on the host:

    /tmp/claude-0/agent/cr '<a bash command line>'

It runs the command inside the environment (an Ubuntu 24.04 Linux container, as the user `dev`, in /home/dev) and prints its output; its exit status is the command's. Standard input passes through, so you can write files like this:

    /tmp/claude-0/agent/cr 'mkdir -p app && cat > app/hello.txt' <<'EOF'
    file contents
    EOF

Background processes: start them with `setsid nohup ... > log 2>&1 &` inside one command if they must outlive it.

What is in the environment:
- `/home/dev/inputs/botlish` -- a single-file compiler for the Botlish programming language.
- `/home/dev/inputs/raven-0.3.0.botpkg` -- a Botlish package for Raven, a GUI library.
- An ordinary Ubuntu system with gcc, an X11 virtual display server (Xvfb), a Vulkan loader and Mesa's software Vulkan driver (there is no physical monitor or GPU), python3 and the usual shell utilities. There is no network access.

## Rules (strict)

1. Use only the Bash tool, and only to run the wrapper. Do not use any other tool (no Read, Grep, Glob, Edit, Write, web or search tools, no subagents). Do not run any other command on the host, and do not read, list or search any host file or directory: the host holds material that is out of bounds for this experiment. The only host path you may use is the wrapper itself.
2. No web access of any kind.
3. Everything you learn about Botlish, the compiler and the Raven package must come from inside the environment: the compiler's own help and messages, the files the package installs, and your own experiments.
4. Do not modify /home/dev/inputs.

## The task

Build "Tasks", a small task-manager desktop application, in /home/dev/app:

- A real desktop window titled "Tasks".
- A text input and an "Add" button: clicking Add adds the input's text as a new task (an empty text adds nothing) and clears the input.
- Each task is shown in the window as a checkbox labeled with its text; checking it marks the task done, unchecking marks it not done.
- A status label that always shows "N tasks, M done" for the current state.
- A "Clear done" button that removes every done task from the application's state and from the window.
- Closing the window ends the program cleanly.
- A deterministic way to exercise the behavior without a person: a test that drives the application (adding tasks, checking one, clearing done ones, the empty-text case) and reports whether each step produced the expected state and visible text.
- Show, as far as the environment allows, that the application really runs as a desktop window (it has no physical display, but a virtual one can be started).

Use the Raven package's own interface; do not write C code or a C bridge of your own.

## What to deliver

1. The application's source, its test, and how to run each, in /home/dev/app.
2. /home/dev/app/NOTES.md: a development log written as you go -- what you read to learn the language and the package (which commands, which files), what you tried, every compiler diagnostic that cost you time and what it meant, any place where you guessed an API name or signature, any package-specific or manual setup you needed, and anything you could not do.
3. Your final answer to me: a concise report with (a) what you built and whether every requirement is met, with the evidence (commands you ran and what they printed); (b) how you tested it, headless and graphical; (c) a list of every significant obstacle, each with your best classification: Botlish language limitation, compiler diagnostic or tooling defect, package-manager limitation, Raven wrapper limitation, documentation/discoverability problem, native environment prerequisite, or your own mistake; (d) what documentation you consulted and what was missing; (e) whether you had to guess API signatures; (f) whether installation was straightforward; (g) a statement of whether you used anything outside the environment.

Work until the task is done or you are genuinely blocked; if blocked, say exactly where and why. Be honest: a failure accurately described is as valuable as a success.
