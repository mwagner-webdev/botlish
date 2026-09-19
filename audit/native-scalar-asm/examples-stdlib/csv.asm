; source:  examples/stdlib/csv.bot
; backend: Cranelift (specialize=1), native::object
; object:  ELF64 x86-64, unlinked (Botlish-generated code only; runtime
;          helpers are unresolved imports, so their bodies are not present)
; format:  objdump -dr --no-show-raw-insn -M intel
; total machine code bytes: 5997  (per function: 169 469 534 677 887 470 759 742 492 532 266)
;
; function symbol -> Botlish label:
;   botlish_fn_0 / botlish_entry_0 -> <program entry>
;   botlish_fn_1 / botlish_entry_1 -> peek<str, int>
;   botlish_fn_2 / botlish_entry_2 -> peek<str, int>
;   botlish_fn_3 / botlish_entry_3 -> scan_unquoted<str, int, int>
;   botlish_fn_4 / botlish_entry_4 -> scan_quoted<str, int, str>
;   botlish_fn_5 / botlish_entry_5 -> scan_field<str, int>
;   botlish_fn_6 / botlish_entry_6 -> scan_record<str, int, list<never>>
;   botlish_fn_7 / botlish_entry_7 -> scan_record<str, int, list<str>>
;   botlish_fn_8 / botlish_entry_8 -> scan_records<str, int, list<never>>
;   botlish_fn_9 / botlish_entry_9 -> scan_records<str, int, list<list<str>>>
;   botlish_fn_10 / botlish_entry_10 -> csv_parse<str>


csv.asm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <botlish_fn_0: <program entry>>:
       0:	push   rbp
       1:	mov    rbp,rsp
       4:	sub    rsp,0x10
       8:	mov    QWORD PTR [rsp],r13
       c:	mov    QWORD PTR [rsp+0x8],r14
      11:	mov    r13,QWORD PTR [rdi]
      14:	mov    rax,QWORD PTR [rdi+0x8]
      18:	lea    rcx,[r13+0x8]
      1c:	cmp    rcx,rax
      1f:	ja     7b <botlish_fn_0+0x7b>
      25:	lea    rax,[r13+0x8]
      29:	mov    QWORD PTR [rdi],rax
      2c:	mov    rax,QWORD PTR [rdi+0x10]
      30:	mov    r14,rdi
      33:	mov    rsi,QWORD PTR [rax]
      36:	mov    QWORD PTR [r13+0x0],rsi
      3a:	call   3f <botlish_fn_0+0x3f>
			3b: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
      3f:	test   rax,rax
      42:	jne    63 <botlish_fn_0+0x63>
      48:	mov    rdi,r14
      4b:	mov    QWORD PTR [rdi],r13
      4e:	xor    rax,rax
      51:	mov    r13,QWORD PTR [rsp]
      55:	mov    r14,QWORD PTR [rsp+0x8]
      5a:	add    rsp,0x10
      5e:	mov    rsp,rbp
      61:	pop    rbp
      62:	ret
      63:	mov    rdi,r14
      66:	mov    QWORD PTR [rdi],r13
      69:	mov    r13,QWORD PTR [rsp]
      6d:	mov    r14,QWORD PTR [rsp+0x8]
      72:	add    rsp,0x10
      76:	mov    rsp,rbp
      79:	pop    rbp
      7a:	ret
      7b:	call   80 <botlish_fn_0+0x80>
			7c: R_X86_64_PLT32	rt_stack_overflow-0x4
      80:	xor    rax,rax
      83:	mov    r13,QWORD PTR [rsp]
      87:	mov    r14,QWORD PTR [rsp+0x8]
      8c:	add    rsp,0x10
      90:	mov    rsp,rbp
      93:	pop    rbp
      94:	ret

0000000000000095 <botlish_entry_0: <program entry>>:
      95:	push   rbp
      96:	mov    rbp,rsp
      99:	call   9e <botlish_entry_0+0x9>
			9a: R_X86_64_PLT32	botlish_fn_0-0x4 ; <program entry>
      9e:	mov    rsp,rbp
      a1:	pop    rbp
      a2:	ret
      a3:	add    BYTE PTR [rax],al
      a5:	add    BYTE PTR [rax],al
	...

00000000000000a8 <botlish_fn_1: peek<str, int>>:
      a8:	push   rbp
      a9:	mov    rbp,rsp
      ac:	sub    rsp,0x20
      b0:	mov    QWORD PTR [rsp],rbx
      b4:	mov    QWORD PTR [rsp+0x8],r12
      b9:	mov    QWORD PTR [rsp+0x10],r13
      be:	mov    QWORD PTR [rsp+0x18],r14
      c3:	mov    r12,QWORD PTR [rdi]
      c6:	mov    rax,QWORD PTR [rdi+0x8]
      ca:	lea    rcx,[r12+0x18]
      cf:	cmp    rcx,rax
      d2:	ja     215 <botlish_fn_1+0x16d>
      d8:	lea    rax,[r12+0x18]
      dd:	mov    QWORD PTR [rdi],rax
      e0:	mov    r13,rdi
      e3:	mov    QWORD PTR [r12],rsi
      e7:	mov    r14,rsi
      ea:	mov    QWORD PTR [r12+0x8],rdx
      ef:	mov    rbx,rdx
      f2:	mov    rsi,r14
      f5:	mov    rdi,r13
      f8:	call   fd <botlish_fn_1+0x55>
			f9: R_X86_64_PLT32	rt_str_len-0x4
      fd:	mov    rcx,rbx
     100:	and    rcx,rax
     103:	mov    rdx,rax
     106:	test   rcx,0x1
     10d:	jne    133 <botlish_fn_1+0x8b>
     113:	mov    rsi,rbx
     116:	mov    rdi,r13
     119:	call   11e <botlish_fn_1+0x76>
			11a: R_X86_64_PLT32	rt_int_cmp-0x4
     11e:	mov    ecx,0x2
     123:	test   rax,rax
     126:	cmovge rcx,QWORD PTR [rip+0x112]        # 240 <botlish_fn_1+0x198>
     12e:	jmp    143 <botlish_fn_1+0x9b>
     133:	mov    ecx,0x2
     138:	cmp    rbx,rdx
     13b:	cmovge rcx,QWORD PTR [rip+0xfd]        # 240 <botlish_fn_1+0x198>
     143:	cmp    rcx,0x6
     147:	je     1eb <botlish_fn_1+0x143>
     14d:	mov    QWORD PTR [r12+0x10],0x3
     156:	test   rbx,0x1
     15d:	je     175 <botlish_fn_1+0xcd>
     163:	mov    rcx,rbx
     166:	add    rcx,0x2
     16a:	seto   al
     16d:	test   al,al
     16f:	je     188 <botlish_fn_1+0xe0>
     175:	mov    edx,0x3
     17a:	mov    rsi,rbx
     17d:	mov    rdi,r13
     180:	call   185 <botlish_fn_1+0xdd>
			181: R_X86_64_PLT32	rt_int_add-0x4
     185:	mov    rcx,rax
     188:	mov    QWORD PTR [r12+0x10],rcx
     18d:	mov    rdx,rbx
     190:	mov    rsi,r14
     193:	mov    rdi,r13
     196:	call   19b <botlish_fn_1+0xf3>
			197: R_X86_64_PLT32	rt_substr-0x4
     19b:	test   rax,rax
     19e:	jne    1c9 <botlish_fn_1+0x121>
     1a4:	mov    rdi,r13
     1a7:	mov    QWORD PTR [rdi],r12
     1aa:	xor    rax,rax
     1ad:	mov    rbx,QWORD PTR [rsp]
     1b1:	mov    r12,QWORD PTR [rsp+0x8]
     1b6:	mov    r13,QWORD PTR [rsp+0x10]
     1bb:	mov    r14,QWORD PTR [rsp+0x18]
     1c0:	add    rsp,0x20
     1c4:	mov    rsp,rbp
     1c7:	pop    rbp
     1c8:	ret
     1c9:	mov    rdi,r13
     1cc:	mov    QWORD PTR [rdi],r12
     1cf:	mov    rbx,QWORD PTR [rsp]
     1d3:	mov    r12,QWORD PTR [rsp+0x8]
     1d8:	mov    r13,QWORD PTR [rsp+0x10]
     1dd:	mov    r14,QWORD PTR [rsp+0x18]
     1e2:	add    rsp,0x20
     1e6:	mov    rsp,rbp
     1e9:	pop    rbp
     1ea:	ret
     1eb:	mov    rdi,r13
     1ee:	mov    rax,QWORD PTR [rdi+0x10]
     1f2:	mov    rax,QWORD PTR [rax+0x8]
     1f6:	mov    QWORD PTR [rdi],r12
     1f9:	mov    rbx,QWORD PTR [rsp]
     1fd:	mov    r12,QWORD PTR [rsp+0x8]
     202:	mov    r13,QWORD PTR [rsp+0x10]
     207:	mov    r14,QWORD PTR [rsp+0x18]
     20c:	add    rsp,0x20
     210:	mov    rsp,rbp
     213:	pop    rbp
     214:	ret
     215:	mov    r13,rdi
     218:	call   21d <botlish_fn_1+0x175>
			219: R_X86_64_PLT32	rt_stack_overflow-0x4
     21d:	xor    rax,rax
     220:	mov    rbx,QWORD PTR [rsp]
     224:	mov    r12,QWORD PTR [rsp+0x8]
     229:	mov    r13,QWORD PTR [rsp+0x10]
     22e:	mov    r14,QWORD PTR [rsp+0x18]
     233:	add    rsp,0x20
     237:	mov    rsp,rbp
     23a:	pop    rbp
     23b:	ret
     23c:	add    BYTE PTR [rax],al
     23e:	add    BYTE PTR [rax],al
     240:	(bad)
     241:	add    BYTE PTR [rax],al
     243:	add    BYTE PTR [rax],al
     245:	add    BYTE PTR [rax],al
	...

0000000000000248 <botlish_entry_1: peek<str, int>>:
     248:	push   rbp
     249:	mov    rbp,rsp
     24c:	mov    rsi,QWORD PTR [rdx]
     24f:	mov    rdx,QWORD PTR [rdx+0x8]
     253:	call   258 <botlish_entry_1+0x10>
			254: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     258:	mov    rsp,rbp
     25b:	pop    rbp
     25c:	ret
     25d:	add    BYTE PTR [rax],al
	...

0000000000000260 <botlish_fn_2: peek<str, int>>:
     260:	push   rbp
     261:	mov    rbp,rsp
     264:	sub    rsp,0x40
     268:	mov    QWORD PTR [rsp+0x10],rbx
     26d:	mov    QWORD PTR [rsp+0x18],r12
     272:	mov    QWORD PTR [rsp+0x20],r13
     277:	mov    QWORD PTR [rsp+0x28],r14
     27c:	mov    QWORD PTR [rsp+0x30],r15
     281:	mov    r13,rcx
     284:	mov    r12,QWORD PTR [rdi]
     287:	mov    rax,QWORD PTR [rdi+0x8]
     28b:	lea    rcx,[r12+0x18]
     290:	cmp    rcx,rax
     293:	ja     414 <botlish_fn_2+0x1b4>
     299:	lea    rax,[r12+0x18]
     29e:	mov    QWORD PTR [rdi],rax
     2a1:	mov    r15,rdi
     2a4:	mov    QWORD PTR [r12],rsi
     2a8:	mov    r14,rsi
     2ab:	mov    QWORD PTR [r12+0x8],rdx
     2b0:	mov    rbx,rdx
     2b3:	mov    rsi,r14
     2b6:	mov    rdi,r15
     2b9:	call   2be <botlish_fn_2+0x5e>
			2ba: R_X86_64_PLT32	rt_str_len-0x4
     2be:	mov    rcx,rbx
     2c1:	and    rcx,rax
     2c4:	mov    rdx,rax
     2c7:	test   rcx,0x1
     2ce:	jne    2f4 <botlish_fn_2+0x94>
     2d4:	mov    rsi,rbx
     2d7:	mov    rdi,r15
     2da:	call   2df <botlish_fn_2+0x7f>
			2db: R_X86_64_PLT32	rt_int_cmp-0x4
     2df:	mov    ecx,0x2
     2e4:	test   rax,rax
     2e7:	cmovge rcx,QWORD PTR [rip+0x159]        # 448 <botlish_fn_2+0x1e8>
     2ef:	jmp    304 <botlish_fn_2+0xa4>
     2f4:	mov    ecx,0x2
     2f9:	cmp    rbx,rdx
     2fc:	cmovge rcx,QWORD PTR [rip+0x144]        # 448 <botlish_fn_2+0x1e8>
     304:	cmp    rcx,0x6
     308:	je     3d2 <botlish_fn_2+0x172>
     30e:	mov    QWORD PTR [r12+0x10],0x3
     317:	test   rbx,0x1
     31e:	je     33f <botlish_fn_2+0xdf>
     324:	mov    rax,rbx
     327:	add    rax,0x2
     32b:	seto   cl
     32e:	test   cl,cl
     330:	jne    33f <botlish_fn_2+0xdf>
     336:	mov    QWORD PTR [rsp],rax
     33a:	jmp    353 <botlish_fn_2+0xf3>
     33f:	mov    edx,0x3
     344:	mov    rsi,rbx
     347:	mov    rdi,r15
     34a:	call   34f <botlish_fn_2+0xef>
			34b: R_X86_64_PLT32	rt_int_add-0x4
     34f:	mov    QWORD PTR [rsp],rax
     353:	mov    rcx,QWORD PTR [rsp]
     357:	mov    rdx,rbx
     35a:	mov    rsi,r14
     35d:	mov    rdi,r15
     360:	call   365 <botlish_fn_2+0x105>
			361: R_X86_64_PLT32	rt_str_region_check-0x4
     365:	test   rax,rax
     368:	jne    399 <botlish_fn_2+0x139>
     36e:	mov    rdi,r15
     371:	mov    QWORD PTR [rdi],r12
     374:	xor    rax,rax
     377:	mov    rbx,QWORD PTR [rsp+0x10]
     37c:	mov    r12,QWORD PTR [rsp+0x18]
     381:	mov    r13,QWORD PTR [rsp+0x20]
     386:	mov    r14,QWORD PTR [rsp+0x28]
     38b:	mov    r15,QWORD PTR [rsp+0x30]
     390:	add    rsp,0x40
     394:	mov    rsp,rbp
     397:	pop    rbp
     398:	ret
     399:	mov    rdi,r15
     39c:	mov    QWORD PTR [rdi],r12
     39f:	mov    rcx,r13
     3a2:	mov    QWORD PTR [rcx],rbx
     3a5:	mov    rax,QWORD PTR [rsp]
     3a9:	mov    QWORD PTR [rcx+0x8],rax
     3ad:	mov    rax,r14
     3b0:	mov    rbx,QWORD PTR [rsp+0x10]
     3b5:	mov    r12,QWORD PTR [rsp+0x18]
     3ba:	mov    r13,QWORD PTR [rsp+0x20]
     3bf:	mov    r14,QWORD PTR [rsp+0x28]
     3c4:	mov    r15,QWORD PTR [rsp+0x30]
     3c9:	add    rsp,0x40
     3cd:	mov    rsp,rbp
     3d0:	pop    rbp
     3d1:	ret
     3d2:	mov    rcx,r13
     3d5:	mov    rdi,r15
     3d8:	mov    rax,QWORD PTR [rdi+0x10]
     3dc:	mov    rax,QWORD PTR [rax+0x8]
     3e0:	mov    QWORD PTR [rdi],r12
     3e3:	mov    QWORD PTR [rcx],0x1
     3ea:	mov    QWORD PTR [rcx+0x8],0x1
     3f2:	mov    rbx,QWORD PTR [rsp+0x10]
     3f7:	mov    r12,QWORD PTR [rsp+0x18]
     3fc:	mov    r13,QWORD PTR [rsp+0x20]
     401:	mov    r14,QWORD PTR [rsp+0x28]
     406:	mov    r15,QWORD PTR [rsp+0x30]
     40b:	add    rsp,0x40
     40f:	mov    rsp,rbp
     412:	pop    rbp
     413:	ret
     414:	mov    r15,rdi
     417:	call   41c <botlish_fn_2+0x1bc>
			418: R_X86_64_PLT32	rt_stack_overflow-0x4
     41c:	xor    rax,rax
     41f:	mov    rbx,QWORD PTR [rsp+0x10]
     424:	mov    r12,QWORD PTR [rsp+0x18]
     429:	mov    r13,QWORD PTR [rsp+0x20]
     42e:	mov    r14,QWORD PTR [rsp+0x28]
     433:	mov    r15,QWORD PTR [rsp+0x30]
     438:	add    rsp,0x40
     43c:	mov    rsp,rbp
     43f:	pop    rbp
     440:	ret
     441:	add    BYTE PTR [rax],al
     443:	add    BYTE PTR [rax],al
     445:	add    BYTE PTR [rax],al
     447:	add    BYTE PTR [rsi],al
     449:	add    BYTE PTR [rax],al
     44b:	add    BYTE PTR [rax],al
     44d:	add    BYTE PTR [rax],al
	...

0000000000000450 <botlish_entry_2: peek<str, int>>:
     450:	push   rbp
     451:	mov    rbp,rsp
     454:	ud2

0000000000000456 <botlish_fn_3: scan_unquoted<str, int, int>>:
     456:	push   rbp
     457:	mov    rbp,rsp
     45a:	sub    rsp,0x60
     45e:	mov    QWORD PTR [rsp+0x30],rbx
     463:	mov    QWORD PTR [rsp+0x38],r12
     468:	mov    QWORD PTR [rsp+0x40],r13
     46d:	mov    QWORD PTR [rsp+0x48],r14
     472:	mov    QWORD PTR [rsp+0x50],r15
     477:	mov    r14,QWORD PTR [rdi]
     47a:	mov    rax,QWORD PTR [rdi+0x8]
     47e:	lea    r8,[r14+0x20]
     482:	cmp    r8,rax
     485:	ja     696 <botlish_fn_3+0x240>
     48b:	lea    rax,[r14+0x20]
     48f:	mov    QWORD PTR [rdi],rax
     492:	mov    r15,rdi
     495:	mov    QWORD PTR [r14+0x18],0x0
     49d:	mov    QWORD PTR [r14],rsi
     4a0:	mov    QWORD PTR [rsp+0x10],rsi
     4a5:	mov    QWORD PTR [r14+0x8],rdx
     4a9:	mov    QWORD PTR [rsp+0x18],rdx
     4ae:	mov    QWORD PTR [r14+0x10],rcx
     4b2:	lea    rbx,[rsp]
     4b6:	mov    QWORD PTR [rsp+0x20],rcx
     4bb:	mov    rcx,rbx
     4be:	mov    rdx,QWORD PTR [rsp+0x20]
     4c3:	mov    rsi,QWORD PTR [rsp+0x10]
     4c8:	mov    rdi,r15
     4cb:	call   4d0 <botlish_fn_3+0x7a>
			4cc: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     4d0:	mov    rcx,rax
     4d3:	mov    QWORD PTR [rsp+0x28],rax
     4d8:	test   rax,rcx
     4db:	jne    4e9 <botlish_fn_3+0x93>
     4e1:	mov    rdi,r15
     4e4:	jmp    63b <botlish_fn_3+0x1e5>
     4e9:	mov    r12,QWORD PTR [rsp]
     4ed:	mov    r13,QWORD PTR [rsp+0x8]
     4f2:	mov    rdi,r15
     4f5:	mov    rcx,QWORD PTR [rdi+0x10]
     4f9:	mov    r8,QWORD PTR [rcx+0x8]
     4fd:	mov    rcx,r13
     500:	mov    rdx,r12
     503:	mov    rsi,QWORD PTR [rsp+0x28]
     508:	call   50d <botlish_fn_3+0xb7>
			509: R_X86_64_PLT32	rt_str_region_eq-0x4
     50d:	cmp    rax,0x6
     511:	je     550 <botlish_fn_3+0xfa>
     517:	mov    rdi,r15
     51a:	mov    rax,QWORD PTR [rdi+0x10]
     51e:	mov    r8,QWORD PTR [rax+0x10]
     522:	mov    rcx,r13
     525:	mov    rdx,r12
     528:	mov    rsi,QWORD PTR [rsp+0x28]
     52d:	call   532 <botlish_fn_3+0xdc>
			52e: R_X86_64_PLT32	rt_str_region_eq-0x4
     532:	cmp    rax,0x6
     536:	je     546 <botlish_fn_3+0xf0>
     53c:	mov    eax,0x2
     541:	jmp    555 <botlish_fn_3+0xff>
     546:	mov    eax,0x6
     54b:	jmp    555 <botlish_fn_3+0xff>
     550:	mov    eax,0x6
     555:	cmp    rax,0x6
     559:	je     598 <botlish_fn_3+0x142>
     55f:	mov    rdi,r15
     562:	mov    rcx,QWORD PTR [rdi+0x10]
     566:	mov    r8,QWORD PTR [rcx+0x18]
     56a:	mov    rcx,r13
     56d:	mov    rdx,r12
     570:	mov    rsi,QWORD PTR [rsp+0x28]
     575:	call   57a <botlish_fn_3+0x124>
			576: R_X86_64_PLT32	rt_str_region_eq-0x4
     57a:	cmp    rax,0x6
     57e:	je     58e <botlish_fn_3+0x138>
     584:	mov    eax,0x2
     589:	jmp    59d <botlish_fn_3+0x147>
     58e:	mov    eax,0x6
     593:	jmp    59d <botlish_fn_3+0x147>
     598:	mov    eax,0x6
     59d:	cmp    rax,0x6
     5a1:	je     618 <botlish_fn_3+0x1c2>
     5a7:	mov    QWORD PTR [r14+0x18],0x3
     5af:	mov    rsi,QWORD PTR [rsp+0x20]
     5b4:	test   rsi,0x1
     5bb:	je     5e2 <botlish_fn_3+0x18c>
     5c1:	mov    rsi,QWORD PTR [rsp+0x20]
     5c6:	mov    rax,rsi
     5c9:	add    rax,0x2
     5cd:	seto   cl
     5d0:	test   cl,cl
     5d2:	jne    5e2 <botlish_fn_3+0x18c>
     5d8:	mov    rsi,QWORD PTR [rsp+0x10]
     5dd:	jmp    5f9 <botlish_fn_3+0x1a3>
     5e2:	mov    edx,0x3
     5e7:	mov    rsi,QWORD PTR [rsp+0x20]
     5ec:	mov    rdi,r15
     5ef:	call   5f4 <botlish_fn_3+0x19e>
			5f0: R_X86_64_PLT32	rt_int_add-0x4
     5f4:	mov    rsi,QWORD PTR [rsp+0x10]
     5f9:	mov    QWORD PTR [r14],rsi
     5fc:	mov    rdx,QWORD PTR [rsp+0x18]
     601:	mov    QWORD PTR [r14+0x8],rdx
     605:	mov    QWORD PTR [r14+0x10],rax
     609:	mov    QWORD PTR [rsp+0x10],rsi
     60e:	mov    QWORD PTR [rsp+0x20],rax
     613:	jmp    4bb <botlish_fn_3+0x65>
     618:	mov    rdx,QWORD PTR [rsp+0x18]
     61d:	mov    rsi,QWORD PTR [rsp+0x10]
     622:	mov    rcx,QWORD PTR [rsp+0x20]
     627:	mov    rdi,r15
     62a:	call   62f <botlish_fn_3+0x1d9>
			62b: R_X86_64_PLT32	rt_substr-0x4
     62f:	test   rax,rax
     632:	jne    669 <botlish_fn_3+0x213>
     638:	mov    rdi,r15
     63b:	mov    rdi,r15
     63e:	mov    QWORD PTR [rdi],r14
     641:	xor    rdx,rdx
     644:	mov    rax,rdx
     647:	mov    rbx,QWORD PTR [rsp+0x30]
     64c:	mov    r12,QWORD PTR [rsp+0x38]
     651:	mov    r13,QWORD PTR [rsp+0x40]
     656:	mov    r14,QWORD PTR [rsp+0x48]
     65b:	mov    r15,QWORD PTR [rsp+0x50]
     660:	add    rsp,0x60
     664:	mov    rsp,rbp
     667:	pop    rbp
     668:	ret
     669:	mov    rdi,r15
     66c:	mov    QWORD PTR [rdi],r14
     66f:	mov    rdx,QWORD PTR [rsp+0x20]
     674:	mov    rbx,QWORD PTR [rsp+0x30]
     679:	mov    r12,QWORD PTR [rsp+0x38]
     67e:	mov    r13,QWORD PTR [rsp+0x40]
     683:	mov    r14,QWORD PTR [rsp+0x48]
     688:	mov    r15,QWORD PTR [rsp+0x50]
     68d:	add    rsp,0x60
     691:	mov    rsp,rbp
     694:	pop    rbp
     695:	ret
     696:	mov    r15,rdi
     699:	call   69e <botlish_fn_3+0x248>
			69a: R_X86_64_PLT32	rt_stack_overflow-0x4
     69e:	xor    rdx,rdx
     6a1:	mov    rax,rdx
     6a4:	mov    rbx,QWORD PTR [rsp+0x30]
     6a9:	mov    r12,QWORD PTR [rsp+0x38]
     6ae:	mov    r13,QWORD PTR [rsp+0x40]
     6b3:	mov    r14,QWORD PTR [rsp+0x48]
     6b8:	mov    r15,QWORD PTR [rsp+0x50]
     6bd:	add    rsp,0x60
     6c1:	mov    rsp,rbp
     6c4:	pop    rbp
     6c5:	ret

00000000000006c6 <botlish_entry_3: scan_unquoted<str, int, int>>:
     6c6:	push   rbp
     6c7:	mov    rbp,rsp
     6ca:	ud2

00000000000006cc <botlish_fn_4: scan_quoted<str, int, str>>:
     6cc:	push   rbp
     6cd:	mov    rbp,rsp
     6d0:	sub    rsp,0x50
     6d4:	mov    QWORD PTR [rsp+0x20],rbx
     6d9:	mov    QWORD PTR [rsp+0x28],r12
     6de:	mov    QWORD PTR [rsp+0x30],r13
     6e3:	mov    QWORD PTR [rsp+0x38],r14
     6e8:	mov    QWORD PTR [rsp+0x40],r15
     6ed:	mov    r13,QWORD PTR [rdi]
     6f0:	mov    rax,QWORD PTR [rdi+0x8]
     6f4:	lea    r8,[r13+0x28]
     6f8:	cmp    r8,rax
     6fb:	ja     9cd <botlish_fn_4+0x301>
     701:	lea    rax,[r13+0x28]
     705:	mov    QWORD PTR [rdi],rax
     708:	mov    r14,rdi
     70b:	mov    QWORD PTR [r13+0x18],0x0
     713:	mov    QWORD PTR [r13+0x20],0x0
     71b:	mov    QWORD PTR [r13+0x0],rsi
     71f:	mov    QWORD PTR [r13+0x8],rdx
     723:	mov    QWORD PTR [r13+0x10],rcx
     727:	lea    rbx,[rsp]
     72b:	mov    r12,rsi
     72e:	mov    r15,rdx
     731:	mov    QWORD PTR [rsp+0x10],rcx
     736:	mov    rdx,r15
     739:	mov    rsi,r12
     73c:	mov    rdi,r14
     73f:	call   744 <botlish_fn_4+0x78>
			740: R_X86_64_PLT32	botlish_fn_1-0x4 ; peek<str, int>
     744:	test   rax,rax
     747:	jne    755 <botlish_fn_4+0x89>
     74d:	mov    rdi,r14
     750:	jmp    986 <botlish_fn_4+0x2ba>
     755:	mov    QWORD PTR [r13+0x18],rax
     759:	mov    rdi,r14
     75c:	mov    QWORD PTR [rsp+0x18],rax
     761:	mov    rdx,QWORD PTR [rdi+0x10]
     765:	mov    rsi,QWORD PTR [rdx+0x20]
     769:	mov    edx,0x1
     76e:	mov    ecx,0x3
     773:	mov    r8,QWORD PTR [rsp+0x18]
     778:	call   77d <botlish_fn_4+0xb1>
			779: R_X86_64_PLT32	rt_str_region_eq-0x4
     77d:	cmp    rax,0x6
     781:	je     80e <botlish_fn_4+0x142>
     787:	mov    QWORD PTR [r13+0x20],0x3
     78f:	mov    rsi,r15
     792:	test   rsi,0x1
     799:	je     7bb <botlish_fn_4+0xef>
     79f:	mov    r8,rsi
     7a2:	add    r8,0x2
     7a6:	seto   r10b
     7aa:	test   r10b,r10b
     7ad:	jne    7bb <botlish_fn_4+0xef>
     7b3:	mov    rsi,r8
     7b6:	jmp    7cb <botlish_fn_4+0xff>
     7bb:	mov    edx,0x3
     7c0:	mov    rdi,r14
     7c3:	call   7c8 <botlish_fn_4+0xfc>
			7c4: R_X86_64_PLT32	rt_int_add-0x4
     7c8:	mov    rsi,rax
     7cb:	mov    QWORD PTR [r13+0x8],rsi
     7cf:	mov    r15,rsi
     7d2:	mov    rsi,QWORD PTR [rsp+0x10]
     7d7:	mov    rdx,QWORD PTR [rsp+0x18]
     7dc:	mov    rdi,r14
     7df:	call   7e4 <botlish_fn_4+0x118>
			7e0: R_X86_64_PLT32	rt_str_cat-0x4
     7e4:	test   rax,rax
     7e7:	jne    7f5 <botlish_fn_4+0x129>
     7ed:	mov    rdi,r14
     7f0:	jmp    986 <botlish_fn_4+0x2ba>
     7f5:	mov    QWORD PTR [r13+0x0],r12
     7f9:	mov    rsi,r15
     7fc:	mov    QWORD PTR [r13+0x8],rsi
     800:	mov    QWORD PTR [r13+0x10],rax
     804:	mov    QWORD PTR [rsp+0x10],rax
     809:	jmp    736 <botlish_fn_4+0x6a>
     80e:	mov    QWORD PTR [r13+0x18],0x3
     816:	mov    rsi,r15
     819:	test   rsi,0x1
     820:	je     83b <botlish_fn_4+0x16f>
     826:	mov    rsi,r15
     829:	mov    rdx,rsi
     82c:	add    rdx,0x2
     830:	seto   al
     833:	test   al,al
     835:	je     84e <botlish_fn_4+0x182>
     83b:	mov    edx,0x3
     840:	mov    rsi,r15
     843:	mov    rdi,r14
     846:	call   84b <botlish_fn_4+0x17f>
			847: R_X86_64_PLT32	rt_int_add-0x4
     84b:	mov    rdx,rax
     84e:	mov    QWORD PTR [r13+0x18],rdx
     852:	mov    rcx,rbx
     855:	mov    rsi,r12
     858:	mov    rdi,r14
     85b:	call   860 <botlish_fn_4+0x194>
			85c: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     860:	test   rax,rax
     863:	mov    rsi,rax
     866:	jne    874 <botlish_fn_4+0x1a8>
     86c:	mov    rdi,r14
     86f:	jmp    986 <botlish_fn_4+0x2ba>
     874:	mov    rdx,QWORD PTR [rsp]
     878:	mov    rcx,QWORD PTR [rsp+0x8]
     87d:	mov    rdi,r14
     880:	mov    rax,QWORD PTR [rdi+0x10]
     884:	mov    r8,QWORD PTR [rax+0x20]
     888:	call   88d <botlish_fn_4+0x1c1>
			889: R_X86_64_PLT32	rt_str_region_eq-0x4
     88d:	cmp    rax,0x6
     891:	je     90f <botlish_fn_4+0x243>
     897:	mov    QWORD PTR [r13+0x0],0x3
     89f:	mov    rsi,r15
     8a2:	test   rsi,0x1
     8a9:	je     8cc <botlish_fn_4+0x200>
     8af:	mov    rsi,r15
     8b2:	mov    rdx,rsi
     8b5:	add    rdx,0x2
     8b9:	seto   al
     8bc:	test   al,al
     8be:	jne    8cc <botlish_fn_4+0x200>
     8c4:	mov    rdi,r14
     8c7:	jmp    8e2 <botlish_fn_4+0x216>
     8cc:	mov    edx,0x3
     8d1:	mov    rsi,r15
     8d4:	mov    rdi,r14
     8d7:	call   8dc <botlish_fn_4+0x210>
			8d8: R_X86_64_PLT32	rt_int_add-0x4
     8dc:	mov    rdx,rax
     8df:	mov    rdi,r14
     8e2:	mov    rdi,r14
     8e5:	mov    QWORD PTR [rdi],r13
     8e8:	mov    rax,QWORD PTR [rsp+0x10]
     8ed:	mov    rbx,QWORD PTR [rsp+0x20]
     8f2:	mov    r12,QWORD PTR [rsp+0x28]
     8f7:	mov    r13,QWORD PTR [rsp+0x30]
     8fc:	mov    r14,QWORD PTR [rsp+0x38]
     901:	mov    r15,QWORD PTR [rsp+0x40]
     906:	add    rsp,0x50
     90a:	mov    rsp,rbp
     90d:	pop    rbp
     90e:	ret
     90f:	mov    QWORD PTR [r13+0x18],0x5
     917:	mov    rsi,r15
     91a:	test   rsi,0x1
     921:	je     947 <botlish_fn_4+0x27b>
     927:	mov    rsi,r15
     92a:	mov    rax,rsi
     92d:	add    rax,0x4
     931:	seto   cl
     934:	test   cl,cl
     936:	jne    947 <botlish_fn_4+0x27b>
     93c:	mov    rsi,rax
     93f:	mov    r15,rax
     942:	jmp    95d <botlish_fn_4+0x291>
     947:	mov    edx,0x5
     94c:	mov    rsi,r15
     94f:	mov    rdi,r14
     952:	call   957 <botlish_fn_4+0x28b>
			953: R_X86_64_PLT32	rt_int_add-0x4
     957:	mov    rsi,rax
     95a:	mov    r15,rax
     95d:	mov    QWORD PTR [r13+0x8],rsi
     961:	mov    rdi,r14
     964:	mov    rax,QWORD PTR [rdi+0x10]
     968:	mov    rdx,QWORD PTR [rax+0x20]
     96c:	mov    QWORD PTR [r13+0x18],rdx
     970:	mov    rsi,QWORD PTR [rsp+0x10]
     975:	call   97a <botlish_fn_4+0x2ae>
			976: R_X86_64_PLT32	rt_str_cat-0x4
     97a:	test   rax,rax
     97d:	jne    9b4 <botlish_fn_4+0x2e8>
     983:	mov    rdi,r14
     986:	mov    rdi,r14
     989:	mov    QWORD PTR [rdi],r13
     98c:	xor    rdx,rdx
     98f:	mov    rax,rdx
     992:	mov    rbx,QWORD PTR [rsp+0x20]
     997:	mov    r12,QWORD PTR [rsp+0x28]
     99c:	mov    r13,QWORD PTR [rsp+0x30]
     9a1:	mov    r14,QWORD PTR [rsp+0x38]
     9a6:	mov    r15,QWORD PTR [rsp+0x40]
     9ab:	add    rsp,0x50
     9af:	mov    rsp,rbp
     9b2:	pop    rbp
     9b3:	ret
     9b4:	mov    QWORD PTR [r13+0x0],r12
     9b8:	mov    rsi,r15
     9bb:	mov    QWORD PTR [r13+0x8],rsi
     9bf:	mov    QWORD PTR [r13+0x10],rax
     9c3:	mov    QWORD PTR [rsp+0x10],rax
     9c8:	jmp    736 <botlish_fn_4+0x6a>
     9cd:	mov    r14,rdi
     9d0:	call   9d5 <botlish_fn_4+0x309>
			9d1: R_X86_64_PLT32	rt_stack_overflow-0x4
     9d5:	xor    rdx,rdx
     9d8:	mov    rax,rdx
     9db:	mov    rbx,QWORD PTR [rsp+0x20]
     9e0:	mov    r12,QWORD PTR [rsp+0x28]
     9e5:	mov    r13,QWORD PTR [rsp+0x30]
     9ea:	mov    r14,QWORD PTR [rsp+0x38]
     9ef:	mov    r15,QWORD PTR [rsp+0x40]
     9f4:	add    rsp,0x50
     9f8:	mov    rsp,rbp
     9fb:	pop    rbp
     9fc:	ret

00000000000009fd <botlish_entry_4: scan_quoted<str, int, str>>:
     9fd:	push   rbp
     9fe:	mov    rbp,rsp
     a01:	ud2

0000000000000a03 <botlish_fn_5: scan_field<str, int>>:
     a03:	push   rbp
     a04:	mov    rbp,rsp
     a07:	sub    rsp,0x30
     a0b:	mov    QWORD PTR [rsp+0x10],rbx
     a10:	mov    QWORD PTR [rsp+0x18],r12
     a15:	mov    QWORD PTR [rsp+0x20],r13
     a1a:	mov    QWORD PTR [rsp+0x28],r14
     a1f:	mov    rbx,QWORD PTR [rdi]
     a22:	mov    rax,QWORD PTR [rdi+0x8]
     a26:	lea    rcx,[rbx+0x18]
     a2a:	cmp    rcx,rax
     a2d:	ja     b90 <botlish_fn_5+0x18d>
     a33:	lea    rax,[rbx+0x18]
     a37:	mov    QWORD PTR [rdi],rax
     a3a:	mov    r12,rdi
     a3d:	mov    QWORD PTR [rbx+0x10],0x0
     a45:	mov    QWORD PTR [rbx],rsi
     a48:	mov    r13,rsi
     a4b:	mov    QWORD PTR [rbx+0x8],rdx
     a4f:	mov    r14,rdx
     a52:	lea    rcx,[rsp]
     a56:	mov    rdx,r14
     a59:	mov    rsi,r13
     a5c:	mov    rdi,r12
     a5f:	call   a64 <botlish_fn_5+0x61>
			a60: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     a64:	test   rax,rax
     a67:	mov    rsi,rax
     a6a:	jne    a78 <botlish_fn_5+0x75>
     a70:	mov    rdi,r12
     a73:	jmp    b44 <botlish_fn_5+0x141>
     a78:	mov    rdx,QWORD PTR [rsp]
     a7c:	mov    rcx,QWORD PTR [rsp+0x8]
     a81:	mov    rdi,r12
     a84:	mov    rax,QWORD PTR [rdi+0x10]
     a88:	mov    r8,QWORD PTR [rax+0x20]
     a8c:	call   a91 <botlish_fn_5+0x8e>
			a8d: R_X86_64_PLT32	rt_str_region_eq-0x4
     a91:	cmp    rax,0x6
     a95:	je     ae0 <botlish_fn_5+0xdd>
     a9b:	mov    rcx,r14
     a9e:	mov    rsi,r13
     aa1:	mov    rdi,r12
     aa4:	mov    rdx,rcx
     aa7:	call   aac <botlish_fn_5+0xa9>
			aa8: R_X86_64_PLT32	botlish_fn_3-0x4 ; scan_unquoted<str, int, int>
     aac:	test   rax,rax
     aaf:	jne    abd <botlish_fn_5+0xba>
     ab5:	mov    rdi,r12
     ab8:	jmp    b44 <botlish_fn_5+0x141>
     abd:	mov    rdi,r12
     ac0:	mov    QWORD PTR [rdi],rbx
     ac3:	mov    rbx,QWORD PTR [rsp+0x10]
     ac8:	mov    r12,QWORD PTR [rsp+0x18]
     acd:	mov    r13,QWORD PTR [rsp+0x20]
     ad2:	mov    r14,QWORD PTR [rsp+0x28]
     ad7:	add    rsp,0x30
     adb:	mov    rsp,rbp
     ade:	pop    rbp
     adf:	ret
     ae0:	mov    QWORD PTR [rbx+0x10],0x3
     ae8:	mov    rdx,r14
     aeb:	test   rdx,0x1
     af2:	je     b0a <botlish_fn_5+0x107>
     af8:	mov    rdx,r14
     afb:	add    rdx,0x2
     aff:	seto   al
     b02:	test   al,al
     b04:	je     b1d <botlish_fn_5+0x11a>
     b0a:	mov    edx,0x3
     b0f:	mov    rsi,r14
     b12:	mov    rdi,r12
     b15:	call   b1a <botlish_fn_5+0x117>
			b16: R_X86_64_PLT32	rt_int_add-0x4
     b1a:	mov    rdx,rax
     b1d:	mov    QWORD PTR [rbx+0x8],rdx
     b21:	mov    rdi,r12
     b24:	mov    rax,QWORD PTR [rdi+0x10]
     b28:	mov    rcx,QWORD PTR [rax+0x8]
     b2c:	mov    QWORD PTR [rbx+0x10],rcx
     b30:	mov    rsi,r13
     b33:	call   b38 <botlish_fn_5+0x135>
			b34: R_X86_64_PLT32	botlish_fn_4-0x4 ; scan_quoted<str, int, str>
     b38:	test   rax,rax
     b3b:	jne    b6d <botlish_fn_5+0x16a>
     b41:	mov    rdi,r12
     b44:	mov    rdi,r12
     b47:	mov    QWORD PTR [rdi],rbx
     b4a:	xor    rdx,rdx
     b4d:	mov    rax,rdx
     b50:	mov    rbx,QWORD PTR [rsp+0x10]
     b55:	mov    r12,QWORD PTR [rsp+0x18]
     b5a:	mov    r13,QWORD PTR [rsp+0x20]
     b5f:	mov    r14,QWORD PTR [rsp+0x28]
     b64:	add    rsp,0x30
     b68:	mov    rsp,rbp
     b6b:	pop    rbp
     b6c:	ret
     b6d:	mov    rdi,r12
     b70:	mov    QWORD PTR [rdi],rbx
     b73:	mov    rbx,QWORD PTR [rsp+0x10]
     b78:	mov    r12,QWORD PTR [rsp+0x18]
     b7d:	mov    r13,QWORD PTR [rsp+0x20]
     b82:	mov    r14,QWORD PTR [rsp+0x28]
     b87:	add    rsp,0x30
     b8b:	mov    rsp,rbp
     b8e:	pop    rbp
     b8f:	ret
     b90:	mov    r12,rdi
     b93:	call   b98 <botlish_fn_5+0x195>
			b94: R_X86_64_PLT32	rt_stack_overflow-0x4
     b98:	xor    rdx,rdx
     b9b:	mov    rax,rdx
     b9e:	mov    rbx,QWORD PTR [rsp+0x10]
     ba3:	mov    r12,QWORD PTR [rsp+0x18]
     ba8:	mov    r13,QWORD PTR [rsp+0x20]
     bad:	mov    r14,QWORD PTR [rsp+0x28]
     bb2:	add    rsp,0x30
     bb6:	mov    rsp,rbp
     bb9:	pop    rbp
     bba:	ret

0000000000000bbb <botlish_entry_5: scan_field<str, int>>:
     bbb:	push   rbp
     bbc:	mov    rbp,rsp
     bbf:	ud2

0000000000000bc1 <botlish_fn_6: scan_record<str, int, list<never>>>:
     bc1:	push   rbp
     bc2:	mov    rbp,rsp
     bc5:	sub    rsp,0x60
     bc9:	mov    QWORD PTR [rsp+0x30],rbx
     bce:	mov    QWORD PTR [rsp+0x38],r12
     bd3:	mov    QWORD PTR [rsp+0x40],r13
     bd8:	mov    QWORD PTR [rsp+0x48],r14
     bdd:	mov    QWORD PTR [rsp+0x50],r15
     be2:	mov    r13,QWORD PTR [rdi]
     be5:	mov    rax,QWORD PTR [rdi+0x8]
     be9:	lea    r8,[r13+0x20]
     bed:	cmp    r8,rax
     bf0:	ja     e5d <botlish_fn_6+0x29c>
     bf6:	lea    rax,[r13+0x20]
     bfa:	mov    QWORD PTR [rdi],rax
     bfd:	mov    r14,rdi
     c00:	mov    QWORD PTR [r13+0x18],0x0
     c08:	mov    QWORD PTR [r13+0x0],rsi
     c0c:	mov    QWORD PTR [rsp+0x10],rsi
     c11:	mov    QWORD PTR [r13+0x8],rdx
     c15:	mov    QWORD PTR [r13+0x10],rcx
     c19:	mov    r12,rcx
     c1c:	mov    rsi,QWORD PTR [rsp+0x10]
     c21:	mov    rdi,r14
     c24:	call   c29 <botlish_fn_6+0x68>
			c25: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     c29:	test   rax,rax
     c2c:	jne    c3a <botlish_fn_6+0x79>
     c32:	mov    rdi,r14
     c35:	jmp    e07 <botlish_fn_6+0x246>
     c3a:	mov    QWORD PTR [r13+0x8],rax
     c3e:	mov    QWORD PTR [r13+0x18],rdx
     c42:	mov    QWORD PTR [rsp+0x20],rdx
     c47:	mov    rsi,r12
     c4a:	mov    rdx,rax
     c4d:	mov    rdi,r14
     c50:	call   c55 <botlish_fn_6+0x94>
			c51: R_X86_64_PLT32	rt_list_append-0x4
     c55:	mov    rcx,rax
     c58:	mov    r15,rax
     c5b:	test   rax,rcx
     c5e:	jne    c6c <botlish_fn_6+0xab>
     c64:	mov    rdi,r14
     c67:	jmp    e07 <botlish_fn_6+0x246>
     c6c:	mov    rax,r15
     c6f:	mov    QWORD PTR [r13+0x8],rax
     c73:	lea    rcx,[rsp]
     c77:	mov    rdx,QWORD PTR [rsp+0x20]
     c7c:	mov    rsi,QWORD PTR [rsp+0x10]
     c81:	mov    rdi,r14
     c84:	call   c89 <botlish_fn_6+0xc8>
			c85: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     c89:	test   rax,rax
     c8c:	mov    QWORD PTR [rsp+0x18],rax
     c91:	jne    c9f <botlish_fn_6+0xde>
     c97:	mov    rdi,r14
     c9a:	jmp    e07 <botlish_fn_6+0x246>
     c9f:	mov    rbx,QWORD PTR [rsp]
     ca3:	mov    r12,QWORD PTR [rsp+0x8]
     ca8:	mov    rdi,r14
     cab:	mov    rcx,QWORD PTR [rdi+0x10]
     caf:	mov    r8,QWORD PTR [rcx+0x10]
     cb3:	mov    rcx,r12
     cb6:	mov    rdx,rbx
     cb9:	mov    rsi,QWORD PTR [rsp+0x18]
     cbe:	call   cc3 <botlish_fn_6+0x102>
			cbf: R_X86_64_PLT32	rt_str_region_eq-0x4
     cc3:	cmp    rax,0x6
     cc7:	je     d9d <botlish_fn_6+0x1dc>
     ccd:	mov    rdi,r14
     cd0:	mov    rax,QWORD PTR [rdi+0x10]
     cd4:	mov    r8,QWORD PTR [rax+0x18]
     cd8:	mov    rcx,r12
     cdb:	mov    rdx,rbx
     cde:	mov    rsi,QWORD PTR [rsp+0x18]
     ce3:	call   ce8 <botlish_fn_6+0x127>
			ce4: R_X86_64_PLT32	rt_str_region_eq-0x4
     ce8:	cmp    rax,0x6
     cec:	je     d22 <botlish_fn_6+0x161>
     cf2:	mov    rdi,r14
     cf5:	mov    QWORD PTR [rdi],r13
     cf8:	mov    rax,r15
     cfb:	mov    rdx,QWORD PTR [rsp+0x20]
     d00:	mov    rbx,QWORD PTR [rsp+0x30]
     d05:	mov    r12,QWORD PTR [rsp+0x38]
     d0a:	mov    r13,QWORD PTR [rsp+0x40]
     d0f:	mov    r14,QWORD PTR [rsp+0x48]
     d14:	mov    r15,QWORD PTR [rsp+0x50]
     d19:	add    rsp,0x60
     d1d:	mov    rsp,rbp
     d20:	pop    rbp
     d21:	ret
     d22:	mov    QWORD PTR [r13+0x0],0x3
     d2a:	mov    rdx,QWORD PTR [rsp+0x20]
     d2f:	test   rdx,0x1
     d36:	je     d5a <botlish_fn_6+0x199>
     d3c:	mov    rdx,QWORD PTR [rsp+0x20]
     d41:	add    rdx,0x2
     d45:	seto   dil
     d49:	test   dil,dil
     d4c:	jne    d5a <botlish_fn_6+0x199>
     d52:	mov    rdi,r14
     d55:	jmp    d72 <botlish_fn_6+0x1b1>
     d5a:	mov    edx,0x3
     d5f:	mov    rsi,QWORD PTR [rsp+0x20]
     d64:	mov    rdi,r14
     d67:	call   d6c <botlish_fn_6+0x1ab>
			d68: R_X86_64_PLT32	rt_int_add-0x4
     d6c:	mov    rdx,rax
     d6f:	mov    rdi,r14
     d72:	mov    rdi,r14
     d75:	mov    QWORD PTR [rdi],r13
     d78:	mov    rax,r15
     d7b:	mov    rbx,QWORD PTR [rsp+0x30]
     d80:	mov    r12,QWORD PTR [rsp+0x38]
     d85:	mov    r13,QWORD PTR [rsp+0x40]
     d8a:	mov    r14,QWORD PTR [rsp+0x48]
     d8f:	mov    r15,QWORD PTR [rsp+0x50]
     d94:	add    rsp,0x60
     d98:	mov    rsp,rbp
     d9b:	pop    rbp
     d9c:	ret
     d9d:	mov    rsi,QWORD PTR [rsp+0x20]
     da2:	mov    edx,0x3
     da7:	mov    r10,rdx
     daa:	mov    QWORD PTR [r13+0x10],0x3
     db2:	test   rsi,0x1
     db9:	jne    dc7 <botlish_fn_6+0x206>
     dbf:	mov    rdx,r10
     dc2:	jmp    ddc <botlish_fn_6+0x21b>
     dc7:	mov    rdx,rsi
     dca:	add    rdx,0x2
     dce:	seto   al
     dd1:	test   al,al
     dd3:	je     de7 <botlish_fn_6+0x226>
     dd9:	mov    rdx,r10
     ddc:	mov    rdi,r14
     ddf:	call   de4 <botlish_fn_6+0x223>
			de0: R_X86_64_PLT32	rt_int_add-0x4
     de4:	mov    rdx,rax
     de7:	mov    QWORD PTR [r13+0x10],rdx
     deb:	mov    rcx,r15
     dee:	mov    rsi,QWORD PTR [rsp+0x10]
     df3:	mov    rdi,r14
     df6:	call   dfb <botlish_fn_6+0x23a>
			df7: R_X86_64_PLT32	botlish_fn_7-0x4 ; scan_record<str, int, list<str>>
     dfb:	test   rax,rax
     dfe:	jne    e35 <botlish_fn_6+0x274>
     e04:	mov    rdi,r14
     e07:	mov    rdi,r14
     e0a:	mov    QWORD PTR [rdi],r13
     e0d:	xor    rdx,rdx
     e10:	mov    rax,rdx
     e13:	mov    rbx,QWORD PTR [rsp+0x30]
     e18:	mov    r12,QWORD PTR [rsp+0x38]
     e1d:	mov    r13,QWORD PTR [rsp+0x40]
     e22:	mov    r14,QWORD PTR [rsp+0x48]
     e27:	mov    r15,QWORD PTR [rsp+0x50]
     e2c:	add    rsp,0x60
     e30:	mov    rsp,rbp
     e33:	pop    rbp
     e34:	ret
     e35:	mov    rdi,r14
     e38:	mov    QWORD PTR [rdi],r13
     e3b:	mov    rbx,QWORD PTR [rsp+0x30]
     e40:	mov    r12,QWORD PTR [rsp+0x38]
     e45:	mov    r13,QWORD PTR [rsp+0x40]
     e4a:	mov    r14,QWORD PTR [rsp+0x48]
     e4f:	mov    r15,QWORD PTR [rsp+0x50]
     e54:	add    rsp,0x60
     e58:	mov    rsp,rbp
     e5b:	pop    rbp
     e5c:	ret
     e5d:	mov    r14,rdi
     e60:	call   e65 <botlish_fn_6+0x2a4>
			e61: R_X86_64_PLT32	rt_stack_overflow-0x4
     e65:	xor    rdx,rdx
     e68:	mov    rax,rdx
     e6b:	mov    rbx,QWORD PTR [rsp+0x30]
     e70:	mov    r12,QWORD PTR [rsp+0x38]
     e75:	mov    r13,QWORD PTR [rsp+0x40]
     e7a:	mov    r14,QWORD PTR [rsp+0x48]
     e7f:	mov    r15,QWORD PTR [rsp+0x50]
     e84:	add    rsp,0x60
     e88:	mov    rsp,rbp
     e8b:	pop    rbp
     e8c:	ret

0000000000000e8d <botlish_entry_6: scan_record<str, int, list<never>>>:
     e8d:	push   rbp
     e8e:	mov    rbp,rsp
     e91:	ud2

0000000000000e93 <botlish_fn_7: scan_record<str, int, list<str>>>:
     e93:	push   rbp
     e94:	mov    rbp,rsp
     e97:	sub    rsp,0x60
     e9b:	mov    QWORD PTR [rsp+0x30],rbx
     ea0:	mov    QWORD PTR [rsp+0x38],r12
     ea5:	mov    QWORD PTR [rsp+0x40],r13
     eaa:	mov    QWORD PTR [rsp+0x48],r14
     eaf:	mov    QWORD PTR [rsp+0x50],r15
     eb4:	mov    r15,QWORD PTR [rdi]
     eb7:	mov    rax,QWORD PTR [rdi+0x8]
     ebb:	lea    r8,[r15+0x20]
     ebf:	cmp    r8,rax
     ec2:	ja     111f <botlish_fn_7+0x28c>
     ec8:	lea    rax,[r15+0x20]
     ecc:	mov    QWORD PTR [rdi],rax
     ecf:	mov    QWORD PTR [rsp+0x10],rdi
     ed4:	mov    QWORD PTR [r15+0x18],0x0
     edc:	mov    QWORD PTR [r15],rsi
     edf:	mov    QWORD PTR [r15+0x8],rdx
     ee3:	mov    QWORD PTR [r15+0x10],rcx
     ee7:	lea    rbx,[rsp]
     eeb:	mov    r12,rsi
     eee:	mov    r13,rcx
     ef1:	mov    rsi,r12
     ef4:	mov    rdi,QWORD PTR [rsp+0x10]
     ef9:	call   efe <botlish_fn_7+0x6b>
			efa: R_X86_64_PLT32	botlish_fn_5-0x4 ; scan_field<str, int>
     efe:	test   rax,rax
     f01:	jne    f11 <botlish_fn_7+0x7e>
     f07:	mov    rdi,QWORD PTR [rsp+0x10]
     f0c:	jmp    f7a <botlish_fn_7+0xe7>
     f11:	mov    QWORD PTR [r15+0x8],rax
     f15:	mov    r8,rax
     f18:	mov    QWORD PTR [r15+0x18],rdx
     f1c:	mov    QWORD PTR [rsp+0x28],rdx
     f21:	mov    rsi,r13
     f24:	mov    rdx,r8
     f27:	mov    rdi,QWORD PTR [rsp+0x10]
     f2c:	call   f31 <botlish_fn_7+0x9e>
			f2d: R_X86_64_PLT32	rt_list_append-0x4
     f31:	test   rax,rax
     f34:	mov    QWORD PTR [rsp+0x20],rax
     f39:	jne    f49 <botlish_fn_7+0xb6>
     f3f:	mov    rdi,QWORD PTR [rsp+0x10]
     f44:	jmp    f7a <botlish_fn_7+0xe7>
     f49:	mov    rax,QWORD PTR [rsp+0x20]
     f4e:	mov    QWORD PTR [r15+0x8],rax
     f52:	mov    rcx,rbx
     f55:	mov    rdx,QWORD PTR [rsp+0x28]
     f5a:	mov    rsi,r12
     f5d:	mov    rdi,QWORD PTR [rsp+0x10]
     f62:	call   f67 <botlish_fn_7+0xd4>
			f63: R_X86_64_PLT32	botlish_fn_2-0x4 ; peek<str, int>
     f67:	test   rax,rax
     f6a:	mov    QWORD PTR [rsp+0x18],rax
     f6f:	jne    faa <botlish_fn_7+0x117>
     f75:	mov    rdi,QWORD PTR [rsp+0x10]
     f7a:	mov    rdi,QWORD PTR [rsp+0x10]
     f7f:	mov    QWORD PTR [rdi],r15
     f82:	xor    rdx,rdx
     f85:	mov    rax,rdx
     f88:	mov    rbx,QWORD PTR [rsp+0x30]
     f8d:	mov    r12,QWORD PTR [rsp+0x38]
     f92:	mov    r13,QWORD PTR [rsp+0x40]
     f97:	mov    r14,QWORD PTR [rsp+0x48]
     f9c:	mov    r15,QWORD PTR [rsp+0x50]
     fa1:	add    rsp,0x60
     fa5:	mov    rsp,rbp
     fa8:	pop    rbp
     fa9:	ret
     faa:	mov    r13,QWORD PTR [rsp]
     fae:	mov    r14,QWORD PTR [rsp+0x8]
     fb3:	mov    rdi,QWORD PTR [rsp+0x10]
     fb8:	mov    rcx,QWORD PTR [rdi+0x10]
     fbc:	mov    r8,QWORD PTR [rcx+0x10]
     fc0:	mov    rcx,r14
     fc3:	mov    rdx,r13
     fc6:	mov    rsi,QWORD PTR [rsp+0x18]
     fcb:	call   fd0 <botlish_fn_7+0x13d>
			fcc: R_X86_64_PLT32	rt_str_region_eq-0x4
     fd0:	cmp    rax,0x6
     fd4:	je     10b9 <botlish_fn_7+0x226>
     fda:	mov    rdi,QWORD PTR [rsp+0x10]
     fdf:	mov    rax,QWORD PTR [rdi+0x10]
     fe3:	mov    r8,QWORD PTR [rax+0x18]
     fe7:	mov    rcx,r14
     fea:	mov    rdx,r13
     fed:	mov    rsi,QWORD PTR [rsp+0x18]
     ff2:	call   ff7 <botlish_fn_7+0x164>
			ff3: R_X86_64_PLT32	rt_str_region_eq-0x4
     ff7:	cmp    rax,0x6
     ffb:	je     1035 <botlish_fn_7+0x1a2>
    1001:	mov    rdi,QWORD PTR [rsp+0x10]
    1006:	mov    QWORD PTR [rdi],r15
    1009:	mov    rax,QWORD PTR [rsp+0x20]
    100e:	mov    rdx,QWORD PTR [rsp+0x28]
    1013:	mov    rbx,QWORD PTR [rsp+0x30]
    1018:	mov    r12,QWORD PTR [rsp+0x38]
    101d:	mov    r13,QWORD PTR [rsp+0x40]
    1022:	mov    r14,QWORD PTR [rsp+0x48]
    1027:	mov    r15,QWORD PTR [rsp+0x50]
    102c:	add    rsp,0x60
    1030:	mov    rsp,rbp
    1033:	pop    rbp
    1034:	ret
    1035:	mov    QWORD PTR [r15],0x3
    103c:	mov    rdx,QWORD PTR [rsp+0x28]
    1041:	test   rdx,0x1
    1048:	je     106e <botlish_fn_7+0x1db>
    104e:	mov    rdx,QWORD PTR [rsp+0x28]
    1053:	add    rdx,0x2
    1057:	seto   r9b
    105b:	test   r9b,r9b
    105e:	jne    106e <botlish_fn_7+0x1db>
    1064:	mov    rdi,QWORD PTR [rsp+0x10]
    1069:	jmp    108a <botlish_fn_7+0x1f7>
    106e:	mov    edx,0x3
    1073:	mov    rsi,QWORD PTR [rsp+0x28]
    1078:	mov    rdi,QWORD PTR [rsp+0x10]
    107d:	call   1082 <botlish_fn_7+0x1ef>
			107e: R_X86_64_PLT32	rt_int_add-0x4
    1082:	mov    rdx,rax
    1085:	mov    rdi,QWORD PTR [rsp+0x10]
    108a:	mov    rdi,QWORD PTR [rsp+0x10]
    108f:	mov    QWORD PTR [rdi],r15
    1092:	mov    rax,QWORD PTR [rsp+0x20]
    1097:	mov    rbx,QWORD PTR [rsp+0x30]
    109c:	mov    r12,QWORD PTR [rsp+0x38]
    10a1:	mov    r13,QWORD PTR [rsp+0x40]
    10a6:	mov    r14,QWORD PTR [rsp+0x48]
    10ab:	mov    r15,QWORD PTR [rsp+0x50]
    10b0:	add    rsp,0x60
    10b4:	mov    rsp,rbp
    10b7:	pop    rbp
    10b8:	ret
    10b9:	mov    rsi,QWORD PTR [rsp+0x28]
    10be:	mov    edx,0x3
    10c3:	mov    rdi,rdx
    10c6:	mov    QWORD PTR [r15+0x10],0x3
    10ce:	test   rsi,0x1
    10d5:	jne    10e3 <botlish_fn_7+0x250>
    10db:	mov    rdx,rdi
    10de:	jmp    10f8 <botlish_fn_7+0x265>
    10e3:	mov    rdx,rsi
    10e6:	add    rdx,0x2
    10ea:	seto   al
    10ed:	test   al,al
    10ef:	je     1105 <botlish_fn_7+0x272>
    10f5:	mov    rdx,rdi
    10f8:	mov    rdi,QWORD PTR [rsp+0x10]
    10fd:	call   1102 <botlish_fn_7+0x26f>
			10fe: R_X86_64_PLT32	rt_int_add-0x4
    1102:	mov    rdx,rax
    1105:	mov    QWORD PTR [r15],r12
    1108:	mov    QWORD PTR [r15+0x8],rdx
    110c:	mov    rax,QWORD PTR [rsp+0x20]
    1111:	mov    QWORD PTR [r15+0x10],rax
    1115:	mov    r13,QWORD PTR [rsp+0x20]
    111a:	jmp    ef1 <botlish_fn_7+0x5e>
    111f:	mov    QWORD PTR [rsp+0x10],rdi
    1124:	call   1129 <botlish_fn_7+0x296>
			1125: R_X86_64_PLT32	rt_stack_overflow-0x4
    1129:	xor    rdx,rdx
    112c:	mov    rax,rdx
    112f:	mov    rbx,QWORD PTR [rsp+0x30]
    1134:	mov    r12,QWORD PTR [rsp+0x38]
    1139:	mov    r13,QWORD PTR [rsp+0x40]
    113e:	mov    r14,QWORD PTR [rsp+0x48]
    1143:	mov    r15,QWORD PTR [rsp+0x50]
    1148:	add    rsp,0x60
    114c:	mov    rsp,rbp
    114f:	pop    rbp
    1150:	ret

0000000000001151 <botlish_entry_7: scan_record<str, int, list<str>>>:
    1151:	push   rbp
    1152:	mov    rbp,rsp
    1155:	ud2

0000000000001157 <botlish_fn_8: scan_records<str, int, list<never>>>:
    1157:	push   rbp
    1158:	mov    rbp,rsp
    115b:	sub    rsp,0x30
    115f:	mov    QWORD PTR [rsp],rbx
    1163:	mov    QWORD PTR [rsp+0x8],r12
    1168:	mov    QWORD PTR [rsp+0x10],r13
    116d:	mov    QWORD PTR [rsp+0x18],r14
    1172:	mov    QWORD PTR [rsp+0x20],r15
    1177:	mov    rbx,QWORD PTR [rdi]
    117a:	mov    rax,QWORD PTR [rdi+0x8]
    117e:	lea    r8,[rbx+0x20]
    1182:	cmp    r8,rax
    1185:	ja     12dc <botlish_fn_8+0x185>
    118b:	lea    rax,[rbx+0x20]
    118f:	mov    QWORD PTR [rdi],rax
    1192:	mov    r12,rdi
    1195:	mov    QWORD PTR [rbx+0x18],0x0
    119d:	mov    QWORD PTR [rbx],rsi
    11a0:	mov    r13,rsi
    11a3:	mov    QWORD PTR [rbx+0x8],rdx
    11a7:	mov    r15,rdx
    11aa:	mov    QWORD PTR [rbx+0x10],rcx
    11ae:	mov    r14,rcx
    11b1:	mov    rsi,r13
    11b4:	mov    rdi,r12
    11b7:	call   11bc <botlish_fn_8+0x65>
			11b8: R_X86_64_PLT32	rt_str_len-0x4
    11bc:	mov    rdx,r15
    11bf:	mov    rcx,rdx
    11c2:	sar    rcx,1
    11c5:	sar    rax,1
    11c8:	cmp    rcx,rax
    11cb:	jge    12b2 <botlish_fn_8+0x15b>
    11d1:	xor    rdx,rdx
    11d4:	mov    rdi,r12
    11d7:	mov    rsi,rdx
    11da:	call   11df <botlish_fn_8+0x88>
			11db: R_X86_64_PLT32	rt_list_new-0x4
    11df:	test   rax,rax
    11e2:	jne    11f0 <botlish_fn_8+0x99>
    11e8:	mov    rdi,r12
    11eb:	jmp    1261 <botlish_fn_8+0x10a>
    11f0:	mov    QWORD PTR [rbx+0x18],rax
    11f4:	mov    rcx,rax
    11f7:	mov    rdx,r15
    11fa:	mov    rsi,r13
    11fd:	mov    rdi,r12
    1200:	call   1205 <botlish_fn_8+0xae>
			1201: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, list<never>>
    1205:	test   rax,rax
    1208:	jne    1216 <botlish_fn_8+0xbf>
    120e:	mov    rdi,r12
    1211:	jmp    1261 <botlish_fn_8+0x10a>
    1216:	mov    QWORD PTR [rbx+0x8],rax
    121a:	mov    QWORD PTR [rbx+0x18],rdx
    121e:	mov    rsi,r14
    1221:	mov    r14,rdx
    1224:	mov    rdx,rax
    1227:	mov    rdi,r12
    122a:	call   122f <botlish_fn_8+0xd8>
			122b: R_X86_64_PLT32	rt_list_append-0x4
    122f:	test   rax,rax
    1232:	jne    1240 <botlish_fn_8+0xe9>
    1238:	mov    rdi,r12
    123b:	jmp    1261 <botlish_fn_8+0x10a>
    1240:	mov    QWORD PTR [rbx+0x8],rax
    1244:	mov    rcx,rax
    1247:	mov    rdx,r14
    124a:	mov    rsi,r13
    124d:	mov    rdi,r12
    1250:	call   1255 <botlish_fn_8+0xfe>
			1251: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, list<list<str>>>
    1255:	test   rax,rax
    1258:	jne    128b <botlish_fn_8+0x134>
    125e:	mov    rdi,r12
    1261:	mov    rdi,r12
    1264:	mov    QWORD PTR [rdi],rbx
    1267:	xor    rax,rax
    126a:	mov    rbx,QWORD PTR [rsp]
    126e:	mov    r12,QWORD PTR [rsp+0x8]
    1273:	mov    r13,QWORD PTR [rsp+0x10]
    1278:	mov    r14,QWORD PTR [rsp+0x18]
    127d:	mov    r15,QWORD PTR [rsp+0x20]
    1282:	add    rsp,0x30
    1286:	mov    rsp,rbp
    1289:	pop    rbp
    128a:	ret
    128b:	mov    rdi,r12
    128e:	mov    QWORD PTR [rdi],rbx
    1291:	mov    rbx,QWORD PTR [rsp]
    1295:	mov    r12,QWORD PTR [rsp+0x8]
    129a:	mov    r13,QWORD PTR [rsp+0x10]
    129f:	mov    r14,QWORD PTR [rsp+0x18]
    12a4:	mov    r15,QWORD PTR [rsp+0x20]
    12a9:	add    rsp,0x30
    12ad:	mov    rsp,rbp
    12b0:	pop    rbp
    12b1:	ret
    12b2:	mov    rdi,r12
    12b5:	mov    QWORD PTR [rdi],rbx
    12b8:	mov    rax,r14
    12bb:	mov    rbx,QWORD PTR [rsp]
    12bf:	mov    r12,QWORD PTR [rsp+0x8]
    12c4:	mov    r13,QWORD PTR [rsp+0x10]
    12c9:	mov    r14,QWORD PTR [rsp+0x18]
    12ce:	mov    r15,QWORD PTR [rsp+0x20]
    12d3:	add    rsp,0x30
    12d7:	mov    rsp,rbp
    12da:	pop    rbp
    12db:	ret
    12dc:	mov    r12,rdi
    12df:	call   12e4 <botlish_fn_8+0x18d>
			12e0: R_X86_64_PLT32	rt_stack_overflow-0x4
    12e4:	xor    rax,rax
    12e7:	mov    rbx,QWORD PTR [rsp]
    12eb:	mov    r12,QWORD PTR [rsp+0x8]
    12f0:	mov    r13,QWORD PTR [rsp+0x10]
    12f5:	mov    r14,QWORD PTR [rsp+0x18]
    12fa:	mov    r15,QWORD PTR [rsp+0x20]
    12ff:	add    rsp,0x30
    1303:	mov    rsp,rbp
    1306:	pop    rbp
    1307:	ret

0000000000001308 <botlish_entry_8: scan_records<str, int, list<never>>>:
    1308:	push   rbp
    1309:	mov    rbp,rsp
    130c:	mov    rsi,QWORD PTR [rdx]
    130f:	mov    r8,QWORD PTR [rdx+0x8]
    1313:	mov    rcx,QWORD PTR [rdx+0x10]
    1317:	mov    rdx,r8
    131a:	call   131f <botlish_entry_8+0x17>
			131b: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, list<never>>
    131f:	mov    rsp,rbp
    1322:	pop    rbp
    1323:	ret
    1324:	add    BYTE PTR [rax],al
	...

0000000000001328 <botlish_fn_9: scan_records<str, int, list<list<str>>>>:
    1328:	push   rbp
    1329:	mov    rbp,rsp
    132c:	sub    rsp,0x30
    1330:	mov    QWORD PTR [rsp],rbx
    1334:	mov    QWORD PTR [rsp+0x8],r12
    1339:	mov    QWORD PTR [rsp+0x10],r13
    133e:	mov    QWORD PTR [rsp+0x18],r14
    1343:	mov    QWORD PTR [rsp+0x20],r15
    1348:	mov    r12,QWORD PTR [rdi]
    134b:	mov    rax,QWORD PTR [rdi+0x8]
    134f:	lea    r8,[r12+0x20]
    1354:	cmp    r8,rax
    1357:	ja     14c0 <botlish_fn_9+0x198>
    135d:	lea    rax,[r12+0x20]
    1362:	mov    QWORD PTR [rdi],rax
    1365:	mov    r14,rdi
    1368:	mov    QWORD PTR [r12+0x18],0x0
    1371:	mov    QWORD PTR [r12],rsi
    1375:	mov    QWORD PTR [r12+0x8],rdx
    137a:	mov    r13,rdx
    137d:	mov    QWORD PTR [r12+0x10],rcx
    1382:	mov    rbx,rsi
    1385:	mov    r15,rcx
    1388:	mov    rsi,rbx
    138b:	mov    rdi,r14
    138e:	call   1393 <botlish_fn_9+0x6b>
			138f: R_X86_64_PLT32	rt_str_len-0x4
    1393:	mov    rcx,r13
    1396:	and    rcx,rax
    1399:	mov    rdx,rax
    139c:	test   rcx,0x1
    13a3:	jne    13c9 <botlish_fn_9+0xa1>
    13a9:	mov    rsi,r13
    13ac:	mov    rdi,r14
    13af:	call   13b4 <botlish_fn_9+0x8c>
			13b0: R_X86_64_PLT32	rt_int_cmp-0x4
    13b4:	mov    ecx,0x2
    13b9:	test   rax,rax
    13bc:	cmovge rcx,QWORD PTR [rip+0x12c]        # 14f0 <botlish_fn_9+0x1c8>
    13c4:	jmp    13dc <botlish_fn_9+0xb4>
    13c9:	mov    ecx,0x2
    13ce:	mov    rsi,r13
    13d1:	cmp    rsi,rdx
    13d4:	cmovge rcx,QWORD PTR [rip+0x114]        # 14f0 <botlish_fn_9+0x1c8>
    13dc:	cmp    rcx,0x6
    13e0:	je     1496 <botlish_fn_9+0x16e>
    13e6:	xor    rdx,rdx
    13e9:	mov    rdi,r14
    13ec:	mov    rsi,rdx
    13ef:	call   13f4 <botlish_fn_9+0xcc>
			13f0: R_X86_64_PLT32	rt_list_new-0x4
    13f4:	test   rax,rax
    13f7:	jne    1405 <botlish_fn_9+0xdd>
    13fd:	mov    rdi,r14
    1400:	jmp    1453 <botlish_fn_9+0x12b>
    1405:	mov    QWORD PTR [r12+0x18],rax
    140a:	mov    rcx,rax
    140d:	mov    rdx,r13
    1410:	mov    rsi,rbx
    1413:	mov    rdi,r14
    1416:	call   141b <botlish_fn_9+0xf3>
			1417: R_X86_64_PLT32	botlish_fn_6-0x4 ; scan_record<str, int, list<never>>
    141b:	test   rax,rax
    141e:	jne    142c <botlish_fn_9+0x104>
    1424:	mov    rdi,r14
    1427:	jmp    1453 <botlish_fn_9+0x12b>
    142c:	mov    QWORD PTR [r12+0x8],rax
    1431:	mov    QWORD PTR [r12+0x18],rdx
    1436:	mov    r13,rdx
    1439:	mov    rsi,r15
    143c:	mov    rdx,rax
    143f:	mov    rdi,r14
    1442:	call   1447 <botlish_fn_9+0x11f>
			1443: R_X86_64_PLT32	rt_list_append-0x4
    1447:	test   rax,rax
    144a:	jne    147d <botlish_fn_9+0x155>
    1450:	mov    rdi,r14
    1453:	mov    rdi,r14
    1456:	mov    QWORD PTR [rdi],r12
    1459:	xor    rax,rax
    145c:	mov    rbx,QWORD PTR [rsp]
    1460:	mov    r12,QWORD PTR [rsp+0x8]
    1465:	mov    r13,QWORD PTR [rsp+0x10]
    146a:	mov    r14,QWORD PTR [rsp+0x18]
    146f:	mov    r15,QWORD PTR [rsp+0x20]
    1474:	add    rsp,0x30
    1478:	mov    rsp,rbp
    147b:	pop    rbp
    147c:	ret
    147d:	mov    QWORD PTR [r12],rbx
    1481:	mov    rdx,r13
    1484:	mov    QWORD PTR [r12+0x8],rdx
    1489:	mov    QWORD PTR [r12+0x10],rax
    148e:	mov    r15,rax
    1491:	jmp    1388 <botlish_fn_9+0x60>
    1496:	mov    rdi,r14
    1499:	mov    QWORD PTR [rdi],r12
    149c:	mov    rax,r15
    149f:	mov    rbx,QWORD PTR [rsp]
    14a3:	mov    r12,QWORD PTR [rsp+0x8]
    14a8:	mov    r13,QWORD PTR [rsp+0x10]
    14ad:	mov    r14,QWORD PTR [rsp+0x18]
    14b2:	mov    r15,QWORD PTR [rsp+0x20]
    14b7:	add    rsp,0x30
    14bb:	mov    rsp,rbp
    14be:	pop    rbp
    14bf:	ret
    14c0:	mov    r14,rdi
    14c3:	call   14c8 <botlish_fn_9+0x1a0>
			14c4: R_X86_64_PLT32	rt_stack_overflow-0x4
    14c8:	xor    rax,rax
    14cb:	mov    rbx,QWORD PTR [rsp]
    14cf:	mov    r12,QWORD PTR [rsp+0x8]
    14d4:	mov    r13,QWORD PTR [rsp+0x10]
    14d9:	mov    r14,QWORD PTR [rsp+0x18]
    14de:	mov    r15,QWORD PTR [rsp+0x20]
    14e3:	add    rsp,0x30
    14e7:	mov    rsp,rbp
    14ea:	pop    rbp
    14eb:	ret
    14ec:	add    BYTE PTR [rax],al
    14ee:	add    BYTE PTR [rax],al
    14f0:	(bad)
    14f1:	add    BYTE PTR [rax],al
    14f3:	add    BYTE PTR [rax],al
    14f5:	add    BYTE PTR [rax],al
	...

00000000000014f8 <botlish_entry_9: scan_records<str, int, list<list<str>>>>:
    14f8:	push   rbp
    14f9:	mov    rbp,rsp
    14fc:	mov    rsi,QWORD PTR [rdx]
    14ff:	mov    r8,QWORD PTR [rdx+0x8]
    1503:	mov    rcx,QWORD PTR [rdx+0x10]
    1507:	mov    rdx,r8
    150a:	call   150f <botlish_entry_9+0x17>
			150b: R_X86_64_PLT32	botlish_fn_9-0x4 ; scan_records<str, int, list<list<str>>>
    150f:	mov    rsp,rbp
    1512:	pop    rbp
    1513:	ret

0000000000001514 <botlish_fn_10: csv_parse<str>>:
    1514:	push   rbp
    1515:	mov    rbp,rsp
    1518:	sub    rsp,0x20
    151c:	mov    QWORD PTR [rsp],rbx
    1520:	mov    QWORD PTR [rsp+0x8],r12
    1525:	mov    QWORD PTR [rsp+0x10],r13
    152a:	mov    rbx,QWORD PTR [rdi]
    152d:	mov    rax,QWORD PTR [rdi+0x8]
    1531:	lea    rcx,[rbx+0x18]
    1535:	cmp    rcx,rax
    1538:	ja     15dd <botlish_fn_10+0xc9>
    153e:	lea    rax,[rbx+0x18]
    1542:	mov    QWORD PTR [rdi],rax
    1545:	mov    r12,rdi
    1548:	mov    QWORD PTR [rbx+0x10],0x0
    1550:	mov    QWORD PTR [rbx],rsi
    1553:	mov    r13,rsi
    1556:	mov    QWORD PTR [rbx+0x8],0x1
    155e:	xor    rdx,rdx
    1561:	mov    rdi,r12
    1564:	mov    rsi,rdx
    1567:	call   156c <botlish_fn_10+0x58>
			1568: R_X86_64_PLT32	rt_list_new-0x4
    156c:	test   rax,rax
    156f:	jne    157d <botlish_fn_10+0x69>
    1575:	mov    rdi,r12
    1578:	jmp    15a0 <botlish_fn_10+0x8c>
    157d:	mov    QWORD PTR [rbx+0x10],rax
    1581:	mov    rcx,rax
    1584:	mov    edx,0x1
    1589:	mov    rsi,r13
    158c:	mov    rdi,r12
    158f:	call   1594 <botlish_fn_10+0x80>
			1590: R_X86_64_PLT32	botlish_fn_8-0x4 ; scan_records<str, int, list<never>>
    1594:	test   rax,rax
    1597:	jne    15c0 <botlish_fn_10+0xac>
    159d:	mov    rdi,r12
    15a0:	mov    rdi,r12
    15a3:	mov    QWORD PTR [rdi],rbx
    15a6:	xor    rax,rax
    15a9:	mov    rbx,QWORD PTR [rsp]
    15ad:	mov    r12,QWORD PTR [rsp+0x8]
    15b2:	mov    r13,QWORD PTR [rsp+0x10]
    15b7:	add    rsp,0x20
    15bb:	mov    rsp,rbp
    15be:	pop    rbp
    15bf:	ret
    15c0:	mov    rdi,r12
    15c3:	mov    QWORD PTR [rdi],rbx
    15c6:	mov    rbx,QWORD PTR [rsp]
    15ca:	mov    r12,QWORD PTR [rsp+0x8]
    15cf:	mov    r13,QWORD PTR [rsp+0x10]
    15d4:	add    rsp,0x20
    15d8:	mov    rsp,rbp
    15db:	pop    rbp
    15dc:	ret
    15dd:	mov    r12,rdi
    15e0:	call   15e5 <botlish_fn_10+0xd1>
			15e1: R_X86_64_PLT32	rt_stack_overflow-0x4
    15e5:	xor    rax,rax
    15e8:	mov    rbx,QWORD PTR [rsp]
    15ec:	mov    r12,QWORD PTR [rsp+0x8]
    15f1:	mov    r13,QWORD PTR [rsp+0x10]
    15f6:	add    rsp,0x20
    15fa:	mov    rsp,rbp
    15fd:	pop    rbp
    15fe:	ret

00000000000015ff <botlish_entry_10: csv_parse<str>>:
    15ff:	push   rbp
    1600:	mov    rbp,rsp
    1603:	mov    rsi,QWORD PTR [rdx]
    1606:	call   160b <botlish_entry_10+0xc>
			1607: R_X86_64_PLT32	botlish_fn_10-0x4 ; csv_parse<str>
    160b:	mov    rsp,rbp
    160e:	pop    rbp
    160f:	ret
