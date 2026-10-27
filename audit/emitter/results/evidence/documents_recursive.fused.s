<botlish_fn_23>:
    2ff0:	push   %rbp
    2ff1:	mov    %rsp,%rbp
    2ff4:	sub    $0x80,%rsp
    2ffb:	mov    %rbx,0x50(%rsp)
    3000:	mov    %r12,0x58(%rsp)
    3005:	mov    %r13,0x60(%rsp)
    300a:	mov    %r14,0x68(%rsp)
    300f:	mov    %r15,0x70(%rsp)
    3014:	mov    %rdi,%r13
    3017:	movq   $0x0,(%rsp)
    301f:	movq   $0x0,0x8(%rsp)
    3028:	movq   $0x0,0x10(%rsp)
    3031:	movq   $0x0,0x18(%rsp)
    303a:	movq   $0x0,0x20(%rsp)
    3043:	movq   $0x0,0x28(%rsp)
    304c:	mov    %r13,%rdi
    304f:	call   3054 <botlish_fn_23+0x64>
			3050: R_X86_64_PLT32	botlish_fn_22-0x4
    3054:	test   %rax,%rax
    3057:	je     3420 <botlish_fn_23+0x430>
    305d:	mov    %rax,(%rsp)
    3061:	mov    %rax,%rbx
    3064:	mov    $0x7,%esi
    3069:	movq   $0x7,0x8(%rsp)
    3072:	mov    $0x1,%edx
    3077:	movq   $0x1,0x10(%rsp)
    3080:	mov    %r13,%rdi
    3083:	call   3088 <botlish_fn_23+0x98>
			3084: R_X86_64_PLT32	rt_mutarray_create-0x4
    3088:	mov    %rax,%r12
    308b:	test   %r12,%r12
    308e:	je     3420 <botlish_fn_23+0x430>
    3094:	mov    %r12,0x8(%rsp)
    3099:	lea    0x30(%rsp),%r8
    309e:	mov    %rbx,%rax
    30a1:	mov    %rax,0x30(%rsp)
    30a6:	mov    $0x18,%esi
    30ab:	mov    0x0(%rip),%rdx        # 30b2 <botlish_fn_23+0xc2>
			30ae: R_X86_64_GOTPCREL	botlish_entry_24-0x4
    30b2:	mov    $0x1,%ecx
    30b7:	mov    %r13,%rdi
    30ba:	call   30bf <botlish_fn_23+0xcf>
			30bb: R_X86_64_PLT32	rt_closure_new-0x4
    30bf:	mov    %rax,(%rsp)
    30c3:	mov    %rax,%rsi
    30c6:	mov    %r13,%rdi
    30c9:	call   30ce <botlish_fn_23+0xde>
			30ca: R_X86_64_PLT32	rt_co_create-0x4
    30ce:	mov    %rax,%r14
    30d1:	mov    %rax,(%rsp)
    30d5:	mov    %r14,%rsi
    30d8:	mov    %r13,%rdi
    30db:	call   30e0 <botlish_fn_23+0xf0>
			30dc: R_X86_64_PLT32	rt_co_start-0x4
    30e0:	test   %rax,%rax
    30e3:	mov    %rax,%rcx
    30e6:	jne    3110 <botlish_fn_23+0x120>
    30ec:	mov    %r13,%rdi
    30ef:	call   30f4 <botlish_fn_23+0x104>
			30f0: R_X86_64_PLT32	rt_declared_error-0x4
    30f4:	cmp    $0x40000001,%rax
    30fa:	jne    3420 <botlish_fn_23+0x430>
    3100:	mov    %r14,%rsi
    3103:	mov    %r13,%rdi
    3106:	call   310b <botlish_fn_23+0x11b>
			3107: R_X86_64_PLT32	rt_co_release-0x4
    310b:	jmp    3420 <botlish_fn_23+0x430>
    3110:	mov    0x18(%r12),%rax
    3115:	test   %rax,%rax
    3118:	je     346d <botlish_fn_23+0x47d>
    311e:	mov    0x10(%r12),%rsi
    3123:	mov    %r12,%rbx
    3126:	mov    %rcx,0x10(%rsi)
    312a:	mov    $0x7fffffff,%esi
    312f:	mov    %rsi,%r12
    3132:	neg    %r12
    3135:	cmovs  %rsi,%r12
    3139:	mov    %r14,%rsi
    313c:	mov    %r13,%rdi
    313f:	call   3144 <botlish_fn_23+0x154>
			3140: R_X86_64_PLT32	rt_co_done-0x4
    3144:	cmp    $0x6,%rax
    3148:	je     33d8 <botlish_fn_23+0x3e8>
    314e:	movq   $0x1,0x10(%rsp)
    3157:	mov    0x10(%rbx),%r11
    315b:	mov    (%r11),%rsi
    315e:	mov    %rsi,0x18(%rsp)
    3163:	mov    0x10(%rbx),%rax
    3167:	mov    0x10(%rax),%rdx
    316b:	mov    %rdx,0x20(%rsp)
    3170:	mov    %rdx,%r15
    3173:	movq   $0x3f,0x28(%rsp)
    317c:	test   $0x1,%rsi
    3183:	je     31ad <botlish_fn_23+0x1bd>
    3189:	mov    %rsi,%rax
    318c:	sar    $1,%rax
    318f:	imulq  0x332(%rip)        # 34c8 <botlish_fn_23+0x4d8>
    3196:	seto   %cl
    3199:	or     $0x1,%rax
    319d:	test   %cl,%cl
    319f:	jne    31ad <botlish_fn_23+0x1bd>
    31a5:	mov    %rax,%rsi
    31a8:	jmp    31bd <botlish_fn_23+0x1cd>
    31ad:	mov    $0x3f,%edx
    31b2:	mov    %r13,%rdi
    31b5:	call   31ba <botlish_fn_23+0x1ca>
			31b6: R_X86_64_PLT32	rt_int_mul-0x4
    31ba:	mov    %rax,%rsi
    31bd:	mov    %rsi,0x18(%rsp)
    31c2:	mov    %r15,%rdx
    31c5:	mov    %rsi,%rax
    31c8:	and    %rdx,%rax
    31cb:	test   $0x1,%rax
    31d1:	je     31ec <botlish_fn_23+0x1fc>
    31d7:	lea    -0x1(%rdx),%rcx
    31db:	mov    %rsi,%rax
    31de:	add    %rcx,%rax
    31e1:	seto   %cl
    31e4:	test   %cl,%cl
    31e6:	je     31f4 <botlish_fn_23+0x204>
    31ec:	mov    %r13,%rdi
    31ef:	call   31f4 <botlish_fn_23+0x204>
			31f0: R_X86_64_PLT32	rt_int_add-0x4
    31f4:	mov    %rax,0x18(%rsp)
    31f9:	movq   $0x3,0x20(%rsp)
    3202:	test   $0x1,%rax
    3208:	jne    3216 <botlish_fn_23+0x226>
    320e:	mov    %rax,%rcx
    3211:	jmp    322b <botlish_fn_23+0x23b>
    3216:	mov    %rax,%rsi
    3219:	add    $0x2,%rsi
    321d:	mov    %rax,%rcx
    3220:	seto   %al
    3223:	test   %al,%al
    3225:	je     323e <botlish_fn_23+0x24e>
    322b:	mov    $0x3,%edx
    3230:	mov    %rcx,%rsi
    3233:	mov    %r13,%rdi
    3236:	call   323b <botlish_fn_23+0x24b>
			3237: R_X86_64_PLT32	rt_int_add-0x4
    323b:	mov    %rax,%rsi
    323e:	mov    %rsi,0x18(%rsp)
    3243:	mov    $0xffffffff,%eax
    3248:	mov    %rax,0x20(%rsp)
    324d:	test   $0x1,%rsi
    3254:	jne    329c <botlish_fn_23+0x2ac>
    325a:	mov    $0xffffffff,%edx
    325f:	mov    %r13,%rdi
    3262:	call   3267 <botlish_fn_23+0x277>
			3263: R_X86_64_PLT32	rt_int_mod-0x4
    3267:	test   %rax,%rax
    326a:	jne    3294 <botlish_fn_23+0x2a4>
    3270:	mov    %r13,%rdi
    3273:	call   3278 <botlish_fn_23+0x288>
			3274: R_X86_64_PLT32	rt_declared_error-0x4
    3278:	cmp    $0x40000001,%rax
    327e:	jne    3420 <botlish_fn_23+0x430>
    3284:	mov    %r14,%rsi
    3287:	mov    %r13,%rdi
    328a:	call   328f <botlish_fn_23+0x29f>
			328b: R_X86_64_PLT32	rt_co_release-0x4
    328f:	jmp    3420 <botlish_fn_23+0x430>
    3294:	mov    %rax,%rcx
    3297:	jmp    32da <botlish_fn_23+0x2ea>
    329c:	sar    $1,%rsi
    329f:	mov    %rsi,%rax
    32a2:	imulq  0x227(%rip)        # 34d0 <botlish_fn_23+0x4e0>
    32a9:	lea    (%rdx,%rsi,1),%rax
    32ad:	sar    $0x1e,%rax
    32b1:	mov    %rax,%rcx
    32b4:	shr    $0x3f,%rcx
    32b8:	add    %rcx,%rax
    32bb:	imul   $0x7fffffff,%rax,%rax
    32c2:	sub    %rax,%rsi
    32c5:	lea    (%rsi,%r12,1),%rax
    32c9:	test   %rsi,%rsi
    32cc:	cmovl  %rax,%rsi
    32d0:	shl    $1,%rsi
    32d3:	or     $0x1,%rsi
    32d7:	mov    %rsi,%rcx
    32da:	mov    0x18(%rbx),%rax
    32de:	test   %rax,%rax
    32e1:	je     3485 <botlish_fn_23+0x495>
    32e7:	mov    0x10(%rbx),%rax
    32eb:	mov    %rcx,(%rax)
    32ee:	movq   $0x3,0x10(%rsp)
    32f7:	mov    0x10(%rbx),%rax
    32fb:	mov    0x8(%rax),%rsi
    32ff:	mov    %rsi,0x18(%rsp)
    3304:	movq   $0x3,0x20(%rsp)
    330d:	test   $0x1,%rsi
    3314:	je     332e <botlish_fn_23+0x33e>
    331a:	mov    %rsi,%rcx
    331d:	add    $0x2,%rcx
    3321:	seto   %dil
    3325:	test   %dil,%dil
    3328:	je     333e <botlish_fn_23+0x34e>
    332e:	mov    $0x3,%edx
    3333:	mov    %r13,%rdi
    3336:	call   333b <botlish_fn_23+0x34b>
			3337: R_X86_64_PLT32	rt_int_add-0x4
    333b:	mov    %rax,%rcx
    333e:	mov    0x18(%rbx),%r10
    3342:	test   %r10,%r10
    3345:	je     349a <botlish_fn_23+0x4aa>
    334b:	mov    0x10(%rbx),%rax
    334f:	mov    %rcx,0x8(%rax)
    3353:	mov    $0x5,%edx
    3358:	mov    %rdx,%r15
    335b:	movq   $0x5,0x10(%rsp)
    3364:	mov    %r14,%rsi
    3367:	mov    %r13,%rdi
    336a:	call   336f <botlish_fn_23+0x37f>
			336b: R_X86_64_PLT32	rt_co_resume0-0x4
    336f:	test   %rax,%rax
    3372:	mov    %rax,%rcx
    3375:	jne    33be <botlish_fn_23+0x3ce>
    337b:	mov    %r13,%rdi
    337e:	call   3383 <botlish_fn_23+0x393>
			337f: R_X86_64_PLT32	rt_declared_error-0x4
    3383:	cmp    $0x40000001,%rax
    3389:	jne    339a <botlish_fn_23+0x3aa>
    338f:	mov    %r14,%rsi
    3392:	mov    %r13,%rdi
    3395:	call   339a <botlish_fn_23+0x3aa>
			3396: R_X86_64_PLT32	rt_co_release-0x4
    339a:	mov    %r13,%rdi
    339d:	call   33a2 <botlish_fn_23+0x3b2>
			339e: R_X86_64_PLT32	rt_declared_error-0x4
    33a2:	cmp    $0x40000001,%rax
    33a8:	jne    3420 <botlish_fn_23+0x430>
    33ae:	mov    %r14,%rsi
    33b1:	mov    %r13,%rdi
    33b4:	call   33b9 <botlish_fn_23+0x3c9>
			33b5: R_X86_64_PLT32	rt_co_release-0x4
    33b9:	jmp    3420 <botlish_fn_23+0x430>
    33be:	mov    0x18(%rbx),%rax
    33c2:	test   %rax,%rax
    33c5:	je     34af <botlish_fn_23+0x4bf>
    33cb:	mov    0x10(%rbx),%rax
    33cf:	mov    %rcx,0x10(%rax)
    33d3:	jmp    3139 <botlish_fn_23+0x149>
    33d8:	mov    %r14,%rsi
    33db:	mov    %r13,%rdi
    33de:	call   33e3 <botlish_fn_23+0x3f3>
			33df: R_X86_64_PLT32	rt_co_release-0x4
    33e3:	mov    0x10(%rbx),%rax
    33e7:	mov    0x8(%rax),%rax
    33eb:	mov    %rax,(%rsp)
    33ef:	mov    0x10(%rbx),%rcx
    33f3:	mov    (%rcx),%rcx
    33f6:	mov    %rcx,0x8(%rsp)
    33fb:	lea    0x38(%rsp),%rdx
    3400:	mov    %rax,0x38(%rsp)
    3405:	mov    %rcx,0x40(%rsp)
    340a:	mov    $0x2,%esi
    340f:	mov    %r13,%rdi
    3412:	call   3417 <botlish_fn_23+0x427>
			3413: R_X86_64_PLT32	rt_list_new-0x4
    3417:	test   %rax,%rax
    341a:	jne    3448 <botlish_fn_23+0x458>
    3420:	xor    %rax,%rax
    3423:	mov    0x50(%rsp),%rbx
    3428:	mov    0x58(%rsp),%r12
    342d:	mov    0x60(%rsp),%r13
    3432:	mov    0x68(%rsp),%r14
    3437:	mov    0x70(%rsp),%r15
    343c:	add    $0x80,%rsp
    3443:	mov    %rbp,%rsp
    3446:	pop    %rbp
    3447:	ret
    3448:	mov    0x50(%rsp),%rbx
    344d:	mov    0x58(%rsp),%r12
    3452:	mov    0x60(%rsp),%r13
    3457:	mov    0x68(%rsp),%r14
    345c:	mov    0x70(%rsp),%r15
    3461:	add    $0x80,%rsp
    3468:	mov    %rbp,%rsp
    346b:	pop    %rbp
    346c:	ret
    346d:	mov    $0x5,%edx
    3472:	mov    %r12,%rsi
    3475:	mov    %r13,%rdi
    3478:	call   347d <botlish_fn_23+0x48d>
			3479: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    347d:	mov    %r12,%rbx
    3480:	jmp    312a <botlish_fn_23+0x13a>
    3485:	mov    $0x1,%edx
    348a:	mov    %rbx,%rsi
    348d:	mov    %r13,%rdi
    3490:	call   3495 <botlish_fn_23+0x4a5>
			3491: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    3495:	jmp    32ee <botlish_fn_23+0x2fe>
    349a:	mov    $0x3,%edx
    349f:	mov    %rbx,%rsi
    34a2:	mov    %r13,%rdi
    34a5:	call   34aa <botlish_fn_23+0x4ba>
			34a6: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    34aa:	jmp    3353 <botlish_fn_23+0x363>
    34af:	mov    %r15,%rdx
    34b2:	mov    %rbx,%rsi
    34b5:	mov    %r13,%rdi
    34b8:	call   34bd <botlish_fn_23+0x4cd>
			34b9: R_X86_64_PLT32	rt_mutarray_set_proven-0x4
    34bd:	jmp    3139 <botlish_fn_23+0x149>
    34c2:	add    %al,(%rax)
    34c4:	add    %al,(%rax)
    34c6:	add    %al,(%rax)
    34c8:	ds add %al,(%rax)
    34cb:	add    %al,(%rax)
    34cd:	add    %al,(%rax)
    34cf:	add    %al,(%rbx)
    34d1:	add    %al,(%rax)
    34d3:	add    %al,(%rcx)
    34d5:	add    %al,(%rax)
    34d7:	.byte 0x80
