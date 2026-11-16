	.globaltype	__stack_pointer, i32
	.text
	.globl	get_sp
	.type	get_sp,@function
get_sp:
	.functype	get_sp () -> (i32)
	global.get	__stack_pointer
	end_function
	.globl	set_sp
	.type	set_sp,@function
set_sp:
	.functype	set_sp (i32) -> ()
	local.get	0
	global.set	__stack_pointer
	end_function
