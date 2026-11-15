//go:build windows

// The clock of bench/bench.tcl's Go reference programs on Windows (best.go):
// QueryPerformanceCounter.
//
// Go's own clock on Windows (time.Now, time.Since) is the kernel's interrupt
// time -- the runtime's nanotime1 reads KUSER_SHARED_DATA's InterruptTime --
// which advances in steps of up to 15.6 ms: one call of a program read as no
// time at all. The programs used to repeat a call there for 50 steps and
// report the average call, so Go alone was timed in a warm steady state, its
// clock's cost spread over thousands of calls, while every other column
// times single calls. The performance counter is the clock the other columns
// read on Windows (Rust's Instant: the Botlish native driver's timing and the
// Rust reference programs'), at the same resolution (100 ns where its
// frequency is 10 MHz). A reading goes through Go's syscall path, not a
// direct call as Rust's does; that cost is in the timed run, as each column's
// own clock's cost is.

package main

import (
	"syscall"
	"unsafe"
)

// clockStamp is a reading of the performance counter, in its ticks.
type clockStamp int64

var (
	qpcAddr      uintptr
	qpcFrequency int64
	qpcCounter   int64
)

func init() {
	kernel32 := syscall.MustLoadDLL("kernel32.dll")
	qpcAddr = kernel32.MustFindProc("QueryPerformanceCounter").Addr()
	qpf := kernel32.MustFindProc("QueryPerformanceFrequency").Addr()
	r, _, err := syscall.SyscallN(qpf, uintptr(unsafe.Pointer(&qpcFrequency)))
	if r == 0 || qpcFrequency <= 0 {
		panic("QueryPerformanceFrequency failed: " + err.Error())
	}
}

func clockNow() clockStamp {
	syscall.SyscallN(qpcAddr, uintptr(unsafe.Pointer(&qpcCounter)))
	return clockStamp(qpcCounter)
}

func microsSince(t0 clockStamp) float64 {
	return float64(clockNow()-t0) * 1e6 / float64(qpcFrequency)
}
