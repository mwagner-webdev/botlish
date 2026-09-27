# Deferred reclamation: callgrind --toggle-collect=botlish_audit_reset, bench 21 (20 between-run resets), Ir per reset

| program | objects reclaimed per reset | Ir per reset | Ir per reclaimed object |
|---|---:|---:|---:|
| frozen | 8,823 | 2,621,775 | 297.2 |
| pre-r2 | 20 | 6,866 | 343.3 |
| r2 | 20 | 6,797 | 339.8 |
| r2a | 11,620 | 3,452,481 | 297.1 |
| r2a2 | 10,023 | 2,978,175 | 297.1 |
| cf-exact | 6,823 | 2,026,975 | 297.1 |
| frozen-noregion | 11,623 | 3,453,373 | 297.1 |
