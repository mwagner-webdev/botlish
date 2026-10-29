# patch.tcl -- prototype B of LEXICAL-RESOURCE-CLEANUP-EXPLORATION-
# MILESTONE-1.md (section 4): scope-owned registrations, the scheduler
# tracking cleanup obligations apart from the values that name them.
#
# The patch, applied to a private copy of stdlib/event_loop.bot (never to
# the repository's): every registration made while a task is dispatched is
# owned by that task (a row field, r_owner), and the scheduler revokes a
# task's registrations when the task retires -- completes, fails, or is
# abandoned. Lexical scopes inside a task are explicit marks: scope()
# returns a mark, end_scope(MARK) revokes the current task's registrations
# made since it. Nothing in the language changes.
#
# Usage: source it and call [bscope::patch TEXT] with event_loop.bot's text.

namespace eval bscope {}

proc bscope::Once {text old new} {
    set at [string first $old $text]
    if {$at < 0 || [string first $old $text [expr {$at + 1}]] >= 0} {
        error "patch anchor does not occur exactly once: $old"
    }
    return [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
}

proc bscope::patch {text} {
    # A registration row's owner (a task id, -1 for none).
    set text [Once $text "private rs = 20\n" "private rs = 21\n"]
    set text [Once $text "private r_inflight = 19\n" "private r_inflight = 19\nprivate r_owner = 20\n"]
    # The dispatched task's id (s_current holds its serial).
    set text [Once $text "private s_count = 49\n" "private s_current_id = 49\nprivate s_count = 50\n"]
    set text [Once $text "    set_reg(s_current, tget(id, t_serial))\n" \
        "    set_reg(s_current, tget(id, t_serial))\n    set_reg(s_current_id, id)\n"]
    # A registration made inside a dispatch belongs to the dispatched task.
    set text [Once $text "    rset(slot, r_inflight, 0)\n" \
        "    rset(slot, r_inflight, 0)\n    owner = if ev.st.at(s_dispatching) == 1:\n        ev.st.at(s_current_id)\n    else:\n        -1\n    rset(slot, r_owner, owner)\n"]
    # A retiring task is queued (retire_task comes before revocation in the
    # module: no forward references), and its registrations are revoked
    # where the scheduler next stands after revoke_checked's definition.
    set text [Once $text "    releases: MutableVector\[int\]\n" "    releases: MutableVector\[int\]\n    retired: MutableVector\[int\]\n"]
    set text [Once $text "        releases: no_ints(), outcomes: no_ints(),\n" "        releases: no_ints(), outcomes: no_ints(), retired: no_ints(),\n"]
    set text [Once $text "private nomethod fn retire_task(id: int, context ev: Loop) errors IndexNotFound:\n    tset(id, t_live, 0)\n" \
        "private nomethod fn retire_task(id: int, context ev: Loop) errors IndexNotFound:\n    ev.retired.push(id)\n    tset(id, t_live, 0)\n"]
    set text [Once $text "    tget(id, t_serial)\n\n" "    revoke_retired()\n    tget(id, t_serial)\n\n"]
    set text [Once $text "        bump(s_idle_turns)\n    n\n" "        bump(s_idle_turns)\n    revoke_retired()\n    n\n"]
    set text [Once $text "        note(cat(\"abandon \", dropped))\n" "        note(cat(\"abandon \", dropped))\n    revoke_retired()\n"]
    set text [Once $text "# Parking and adoption\n" {# Prototype B: scope-owned registrations

# Revoke every live registration task ID owns (made at or after sequence
# number SINCE, -1 for all): a scan of the registration table.
private nomethod fn revoke_owned(id: int, since: int, context ev: Loop) errors IndexNotFound:
    loop slot from 0 to ev.st.at(s_nregs):
        if rget(slot, r_kind) != kind_free and rget(slot, r_owner) == id and rget(slot, r_seq) >= since:
            revoke_checked(Reg {slot: slot, gen: rget(slot, r_gen)})

# Revoke the registrations of every task retired since the last call.
private fn revoke_retired(context ev: Loop) errors IndexNotFound:
    loop:
        if ev.retired.empty?():
            break
        revoke_owned(ev.retired.pop(), -1)

# A mark for end_scope: the registrations the current task makes after it.
fn scope(context ev: Loop) -> int errors SchedulerFault:
    reg_of(s_seq)

# Revoke the registrations the current task made since MARK (scope's).
fn end_scope(mark: int, context ev: Loop) errors SchedulerFault:
    if reg_of(s_dispatching) == 1:
        revoke_owned(reg_of(s_current_id), mark):
            on IndexNotFound:
                fail SchedulerFault

# The prototype's observation hook (never API): the identity SLOT, GEN.
fn reg_at(slot: int, gen: int) -> Reg:
    Reg {slot: slot, gen: gen}

# The task id that owns REG (-1: none, or REG is not live).
fn owner_of(reg: Reg, context ev: Loop) -> int errors SchedulerFault:
    if not live?(reg):
        return -1
    reg_field(reg, r_owner)

# ---------------------------------------------------------------------------
# Parking and adoption
}]
    return $text
}
