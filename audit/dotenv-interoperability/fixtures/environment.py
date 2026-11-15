# The process environment: precedence between existing variables and the
# file. These fixtures assign or reference the variables the conflict mode
# supplies (common.CONFLICT); in the clean mode the same names are undefined.

V = "environment"

F("env-preset-assigned", V, "The file assigns a variable the environment already has",
  "CENSUS_PRESET=from-file\n", intended=None)
F("env-preset-assigned-quoted", V, "The same, double-quoted", 'CENSUS_PRESET="from-file"\n', intended=None)
F("env-empty-assigned", V, "The file assigns a variable the environment has as empty",
  "CENSUS_EMPTY_ENV=from-file\n", intended=None)
F("env-preset-then-ref", V, "The file assigns an existing variable, then references it",
  "CENSUS_PRESET=from-file\nKEY=[${CENSUS_PRESET}]\n", intended=None)
F("env-ref-only", V, "The file references an environment variable it does not assign",
  "KEY=[${CENSUS_REF}]\n", intended=None)
F("env-ref-dollar", V, "The same, unbraced", "KEY=[$CENSUS_REF]\n", intended=None)
F("env-ref-double", V, "The same, inside double quotes", 'KEY="[${CENSUS_REF}]"\n', intended=None)
F("env-ref-single", V, "The same, inside single quotes", "KEY='[${CENSUS_REF}]'\n", intended=None)
F("env-ref-default", V, "A default for an environment variable", "KEY=[${CENSUS_REF:-fallback}]\n", intended=None)
F("env-empty-default", V, "A default for an environment variable that is empty",
  "KEY=[${CENSUS_EMPTY_ENV:-fallback}]\n", intended=None)
F("env-empty-dash-default", V, "A dash default for an environment variable that is empty",
  "KEY=[${CENSUS_EMPTY_ENV-fallback}]\n", intended=None)
F("env-spaces-ref", V, "A reference to an environment value with leading and trailing spaces",
  "KEY=[$CENSUS_SPACES]\n", intended=None)
F("env-preset-export", V, "export of an existing variable", "export CENSUS_PRESET=from-file\n", intended=None)
F("env-preset-bare", V, "A bare key naming an existing variable", "CENSUS_PRESET\n", intended=None)
F("env-preset-duplicate", V, "Two assignments of an existing variable",
  "CENSUS_PRESET=first\nCENSUS_PRESET=second\n", intended=None)
