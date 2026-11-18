"""inspect.py -- probe A's independent reader (RN-OFFLINE-DOMAIN-ARCHITECTURE-
CENSUS-MILESTONE-1.md): reads the probe's database with Python's own sqlite3
module (another SQLite build, no Botlish code) and prints one canonical line.
A hot journal left by a process that died mid-transaction is reported first;
opening the database then rolls it back, as SQLite's recovery does.

    python3 -I inspect.py DB
"""
import os
import sqlite3
import sys

db = sys.argv[1]
journal = db + "-journal"
hot = os.path.exists(journal) and os.path.getsize(journal) > 0
c = sqlite3.connect(db)
pets = ",".join("%d:%s/%s" % r for r in c.execute("select id, name, status from pets order by id"))
base = ",".join("%d:%s/%s@%d" % r for r in c.execute("select id, name, status, remote_rev from pet_baselines order by id"))
outbox = ",".join(
    "%d:%s:base%d:att%d:%s:sent=%s" % (pid, state, rev, att, key, "-" if sn is None else "%s/%s" % (sn, ss))
    for pid, state, rev, att, key, sn, ss in c.execute(
        "select pet_id, state, base_rev, attempts, mutation_key, sent_name, sent_status from outbox order by pet_id"))
lr = c.execute("select value from meta where key = 'local_revision'").fetchone()[0]
check = c.execute("pragma integrity_check").fetchone()[0]
print("%spets=%s base=%s outbox=[%s] local_revision=%d integrity=%s" % ("hot-journal " if hot else "", pets, base, outbox, lr, check))
