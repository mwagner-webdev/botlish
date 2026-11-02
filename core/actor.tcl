# actor.tcl -- the internal intrinsic of std::actor
# (SAME-THREAD-ACTORS-MILESTONE-1.md, "Context-free communication").
#
# A same-thread actor that holds no context communicates only through its
# own coroutine: it yields its requests (a receive, a send) to the task
# that hosts it and is resumed with the answers. A coroutine's resume
# message is one declared struct type and the mailbox table is the
# library's own context, so neither can be generic in the message type: a
# message crosses both as an `any` value. Nothing in the language turns an
# `any` back into a static type (the checker refuses it, rightly), so the
# library recovers a message with this intrinsic:
#
#   std::actor::recover[M](x)   X itself, typed M
#
# It checks nothing and converts nothing: it is the identity at run time on
# every backend. It is internal to the standard library
# (core::native::declareInternalMember): no program can name it. Its one
# caller is std::actor's `recovered` (stdlib/actor.bot), which uses it only
# after checking that the answer it holds carries the identity (slot and
# generation) of the very mailbox whose typed Receiver[M] the caller holds,
# and every value queued under that identity was put there by
# std::actor::send/post/deliver with an Address[M] that std::actor::open[M]
# made beside that Receiver's Inbox[M]. Opacity keeps both identities
# unforgeable, and generations keep a reused slot's identity distinct, so
# the value is an M: the typing a send's argument check proved at the
# sender is the typing the receiver gets.

namespace eval core::actor {}

# The value itself (std::actor::recover).
proc core::actor::recover {x} {
    return $x
}

core::native::register std::actor::recover -arity 1 -impl core::actor::recover \
    -param-types {any} -result-type any -context-free 1 -nomethod 1 \
    -ownership {move} -imprint {vars {T} params {any} result {imprint T}}
core::native::declareInternalMember std::actor::recover
