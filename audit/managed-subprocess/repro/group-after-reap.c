/* group-after-reap.c -- reproducer (MANAGED-SUBPROCESS-AND-EVENT-LOOP-CENSUS-
 * MILESTONE-1.md, section 6): a process group outlives its leader's reaping
 * while any member lives, and a group signal through the reaped leader's
 * pidfd (PIDFD_SIGNAL_PROCESS_GROUP, Linux 6.9) still reaches it -- the
 * pidfd names the group by the leader's struct pid, never by a number a new
 * process could reuse. A process signal through the same pidfd is ESRCH.
 *
 *   cc -O2 group-after-reap.c -o grp && ./grp
 *
 * Found by the mutant c-wnowait: with the adapter's status check reaping at
 * once, the reap-order scenario's group signal was still delivered (the
 * scenario died of its bookkeeping instead). The adapter refuses every
 * signal after the reap anyway (conservative: the eager-reap control). */
#define _GNU_SOURCE
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/pidfd.h>
#include <sys/wait.h>
#include <sys/syscall.h>
#ifndef PIDFD_SIGNAL_PROCESS_GROUP
#define PIDFD_SIGNAL_PROCESS_GROUP (1UL << 2)
#endif
int main(void){
  int p[2]; pipe(p);
  pid_t leader=fork();
  if(leader==0){ setpgid(0,0); pid_t d=fork(); if(d==0){ close(p[0]); sleep(30); _exit(0);} write(p[1],&d,sizeof d); _exit(0);}
  pid_t desc; read(p[0],&desc,sizeof desc);
  int fd=(int)syscall(SYS_pidfd_open,leader,0);
  siginfo_t si; memset(&si,0,sizeof si); waitid(P_PIDFD,fd,&si,WEXITED); /* reap the leader */
  printf("leader %d reaped; descendant %d in group %d\n",leader,desc,getpgid(desc));
  int r=pidfd_send_signal(fd,0,NULL,PIDFD_SIGNAL_PROCESS_GROUP); printf("group signal 0 after reap: r=%d %s\n",r,r?strerror(errno):"");
  r=kill(-leader,0); printf("kill(-pgid,0) after reap: r=%d %s\n",r,r?strerror(errno):"");
  r=pidfd_send_signal(fd,SIGKILL,NULL,0); printf("process signal after reap: r=%d %s\n",r,r?strerror(errno):"");
  r=pidfd_send_signal(fd,SIGKILL,NULL,PIDFD_SIGNAL_PROCESS_GROUP); printf("group SIGKILL after reap: r=%d %s\n",r,r?strerror(errno):"");
  usleep(100000);
  char path[64]; snprintf(path,64,"/proc/%d/stat",desc); FILE*f=fopen(path,"r"); char st[256]={0}; if(f){fgets(st,256,f);fclose(f);} printf("descendant: %s\n", f? strrchr(st,')')+1 : " gone");
  r=pidfd_send_signal(fd,0,NULL,PIDFD_SIGNAL_PROCESS_GROUP); printf("group signal once the group is empty: r=%d %s\n",r,r?strerror(errno):"");
  return 0;}
