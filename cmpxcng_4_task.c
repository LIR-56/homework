#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>

int cas(int *ptr,int old, int new){
  int ret_val;
  asm volatile("lock\n\tcmpxchg %1,%2":"=a"(ret_val):"r"(new),"m"(*ptr),"0"(old):"memory");
  return ret_val;
}


int a = 0;
int mutex=0; 
void *mythread(void *dummy)
{
    pthread_t mythid;
    mythid = pthread_self();
    int i=0;
    while(i<50000000){
     if(!cas(&mutex,0,1)){
      a++;
      i++;
      mutex=0;}
    }
    return NULL;
}

int main()
{
    pthread_t thid, mythid;
    int result;
    
    result = pthread_create( &thid,(pthread_attr_t *)NULL, mythread, NULL);
    if(result != 0){
      printf ("Error on thread create,return value = %d\n", result);
      exit(-1);
    }
    mythid = pthread_self();
    int i;
    while(i<50000000){
      if(!cas(&mutex,0,1)){
      a--;
      i++;
      mutex=0;}
    }
    pthread_join(thid, (void **)NULL);
    printf("%d\n",a);
    
    return 0;
}