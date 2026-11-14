# Command substitution: syntax some implementations execute. Every fixture
# here is synthetic and audited; Ruby's adapter records the commands without
# running them, and its "trusted" configuration runs only the exact commands
# listed in `trusted` (harmless builtins). Bash never runs any of these: the
# static classifier rejects them.

S = "commands"

F("cmd-dollar-paren", S, "$(echo hi) unquoted", "KEY=$(echo hi)\n", trusted=["echo hi"])
F("cmd-dollar-paren-double", S, "$(echo hi) inside double quotes", 'KEY="$(echo hi)"\n', trusted=["echo hi"])
F("cmd-dollar-paren-single", S, "$(echo hi) inside single quotes", "KEY='$(echo hi)'\n", trusted=["echo hi"])
F("cmd-dollar-paren-escaped", S, "An escaped \\$(echo hi)", "KEY=\\$(echo hi)\n", trusted=["echo hi"])
F("cmd-dollar-paren-text", S, "A command inside surrounding text", 'KEY="pre-$(echo hi)-post"\n', trusted=["echo hi"])
F("cmd-nested", S, "A nested command substitution", "KEY=$(echo $(echo inner))\n",
  trusted=["echo $(echo inner)", "echo inner"])
F("cmd-variable-into-command", S, "A variable substituted into the command text",
  "WORD=fromfile\nKEY=$(echo $WORD)\n", trusted=["echo fromfile", "echo $WORD"])
F("cmd-backtick", S, "A backtick command", "KEY=`echo hi`\n", trusted=["echo hi"])
F("cmd-unbalanced", S, "An unbalanced $( without its closing parenthesis", "KEY=$(echo hi\n", trusted=["echo hi"])
F("cmd-arithmetic", S, "Arithmetic expansion $((1+2))", "KEY=$((1+2))\n", trusted=["(1+2)"])
F("cmd-output-newline", S, "A command whose output ends with a newline (chomped?)",
  "KEY=[$(printf 'a\\n\\n')]\n", trusted=["printf 'a\\n\\n'"])
