import sys
# Variants reproduce the JIT'd work+drive of loop-count exactly (Intel syntax), with the JIT's relative layout.
work_body = {
 'A': ["push rbp","mov rbp,rsp","mov eax,0xf","mov rsp,rbp","pop rbp","ret"],
 'B': ["push rbp","mov rbp,rsp","mov eax,0x7","mov rsp,rbp","pop rbp","ret"],
 'D': ["push rbp","mov rbp,rsp","mov eax,0xf","mov rsp,rbp","pop rbp","ret"],
}
def drive(v, callee):
    cnt, vm, tot = {'A':('rbx','r12','r13'), 'B':('r15','rbx','r12'), 'D':('r15','rbx','r12')}[v]
    save = {'A':('rbx','r12','r13'),'B':('rbx','r12','r15'),'D':('rbx','r12','r15')}[v]
    L=[ "push rbp","mov rbp,rsp","sub rsp,0x30",
        f"mov QWORD PTR [rsp+0x10],{save[0]}", f"mov QWORD PTR [rsp+0x18],{save[1]}", f"mov QWORD PTR [rsp+0x20],{save[2]}"]
    if v=='A':
        L+=["mov r12,rdi","mov QWORD PTR [rsp],rdx","sar rsi,1","mov rbx,rsi","mov r13,rdx"]
    else:
        L+=["mov rbx,rdi","mov QWORD PTR [rsp],rdx","mov r12,rdx","mov r15,rsi"]
    L+=[f".Ltop_{v}_%(k)d:", f"test {cnt},{cnt}", f"jle .Lend_{v}_%(k)d"]
    if v=='A':
        L+=[f"mov rsi,{cnt}","shl rsi,1","or rsi,0x1",f"mov rdi,{vm}"]
    else:
        L+=[f"mov rsi,{cnt}",f"mov rdi,{vm}"]
    L+=[f"call {callee}","mov QWORD PTR [rsp+0x8],0xf",f"mov rsi,{tot}","test rsi,0x1",f"je .Lslow_{v}_%(k)d",
        "mov rax,rsi","add rax,0xe","seto cl","test cl,cl",f"je .Lok_{v}_%(k)d",
        f".Lslow_{v}_%(k)d:","mov edx,0xf",f"mov rdi,{vm}","call rt_stub",
        f".Lok_{v}_%(k)d:","mov QWORD PTR [rsp],rax",f"sub {cnt},0x1",f"mov {tot},rax",f"jmp .Ltop_{v}_%(k)d",
        f".Lend_{v}_%(k)d:",f"mov rax,{tot}",f"mov rbx,QWORD PTR [rsp+0x10]",f"mov r12,QWORD PTR [rsp+0x18]",f"mov {save[2]},QWORD PTR [rsp+0x20]" ,
        "add rsp,0x30","mov rsp,rbp","pop rbp","ret"]
    return L
# JIT layout: work at w, drive at d (offsets from blob start), gap filled with the entry wrapper stub of ~ the same size
layout = {'A':(0x3f,0x5e),'B':(0x36,0x5f),'D':(0x36,0x58)}
out=[".intel_syntax noprefix",".text","rt_stub: ud2"]
shifts=[int(x) for x in sys.argv[1].split(',')]
for v in 'ABD':
    for k in shifts:
        w,d=layout[v]
        out+=[".balign 64",f".skip {k}",f".Lblob_{v}_{k}:"]
        out+=[f".skip {w}"]   # blob starts at 0; work at w (program fn occupies the head)
        out+=[f"work_{v}_{k}:"]+work_body[v]
        cur=w+{ 'A':0x0e,'B':0x0e,'D':0x0e}[v]  # work is 14 bytes (push1+mov3+mov5+mov3+pop1+ret1)
        out+=[f".skip {d-cur}"]
        out+=[f".globl drive_{v}_{k}",f"drive_{v}_{k}:"]
        out+=[x%{'k':k} for x in drive(v,f"work_{v}_{k}")]
open("mb.S","w").write("\n".join(out)+"\n")
