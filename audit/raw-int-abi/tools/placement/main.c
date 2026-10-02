#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <x86intrin.h>
extern long drive_A_0(long vm,long n,long tot);
#define DECL(v,k) extern long drive_##v##_##k(long,long,long);
#define K(X) X(0) X(1) X(2) X(3) X(4) X(5) X(6) X(7) X(8) X(9) X(10) X(11) X(12) X(13) X(14) X(15) X(16) X(17) X(18) X(19) X(20) X(21) X(22) X(23) X(24) X(25) X(26) X(27) X(28) X(29) X(30) X(31) X(32) X(33) X(34) X(35) X(36) X(37) X(38) X(39) X(40) X(41) X(42) X(43) X(44) X(45) X(46) X(47) X(48) X(49) X(50) X(51) X(52) X(53) X(54) X(55) X(56) X(57) X(58) X(59) X(60) X(61) X(62) X(63)
#define DV(k) DECL(A,k) DECL(B,k) DECL(D,k)
K(DV)
typedef long (*fn)(long,long,long);
static double now(){struct timespec t;clock_gettime(CLOCK_MONOTONIC,&t);return t.tv_sec*1e9+t.tv_nsec;}
static double bench(fn f,int tagged,int reps,int iters){
  double best=1e18;
  for(int r=0;r<9;r++){
    double t0=now();
    for(int i=0;i<reps;i++){ long n=tagged?(iters<<1|1):iters; long res=f(0,n,1); if(res!=1+14L*iters) {printf("bad %ld\n",res);exit(1);} }
    double t=(now()-t0)/reps; if(t<best)best=t;
  }
  return best;
}
int main(int argc,char**argv){
  int reps=20000,iters=500;
#define ROW(k) { printf("%3d  A %7.1f  B %7.1f  D %7.1f\n",k,bench(drive_A_##k,1,reps,iters),bench(drive_B_##k,0,reps,iters),bench(drive_D_##k,0,reps,iters)); }
  printf("shift  ns per 500-iteration call (best of 9)\n");
#define RW(k) ROW(k)
  K(RW)
  return 0;
}
