/* pidfd-spawn-leak.c -- reproducer (MANAGED-SUBPROCESS-AND-EVENT-LOOP-CENSUS-
 * MILESTONE-1.md, section 13): glibc 2.39's pidfd_spawn leaves the pidfd it
 * made open when exec fails (the executable is missing), and returns no
 * descriptor to close; posix_spawn of the same executable leaks nothing.
 * Observed on Ubuntu GLIBC 2.39-0ubuntu8.9, Linux 6.18:
 *
 *   cc -O2 pidfd-spawn-leak.c -o leak && ./leak
 *   before 3 / r=2 pidfd=-77 fds=4 / ... fds=5 / ... fds=6 / posix_spawn ... fds=6
 *
 * The census's adapter therefore spawns with posix_spawn and opens the pidfd
 * of the unreaped child at once (pidfd_open: race-free, the PID cannot be
 * reused before the parent reaps it). */
#define _GNU_SOURCE
#include <stdlib.h>
#include <spawn.h>
#include <sys/pidfd.h>
#include <stdio.h>
#include <dirent.h>
#include <sys/wait.h>
#include <string.h>
#include <unistd.h>
extern char **environ;
static int nfds(void){DIR*d=opendir("/proc/self/fd");int n=0;struct dirent*e;while((e=readdir(d)))if(e->d_name[0]!='.')n++;closedir(d);return n-1;}
int main(void){
  char *argv[]={"/nonexistent",NULL};
  printf("before %d\n",nfds());
  for(int i=0;i<3;i++){int pidfd=-77; int r=pidfd_spawn(&pidfd,"/nonexistent",NULL,NULL,argv,environ); printf("r=%d pidfd=%d fds=%d\n",r,pidfd,nfds());}
  for(int i=0;i<3;i++){pid_t pid; int r=posix_spawn(&pid,"/nonexistent",NULL,NULL,argv,environ); printf("posix_spawn r=%d fds=%d\n",r,nfds());}
  siginfo_t si; memset(&si,0,sizeof si); int w=waitid(P_ALL,0,&si,WEXITED|WNOHANG); printf("waitable child after failures: w=%d pid=%d\n",w,si.si_pid);
  for(int fd=3;fd<16;fd++){char l[64],t[256];snprintf(l,sizeof l,"/proc/self/fd/%d",fd);ssize_t n=readlink(l,t,sizeof t-1);if(n>0){t[n]=0;printf("fd %d -> %s\n",fd,t);}}
  return 0;}
