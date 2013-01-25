#include <stdio.h>
#include <ucontext.h>
#include <time.h>
#include <unistd.h>
#include <sys/time.h>
#include <stdlib.h>
#include <signal.h>
#include <poll.h>




struct thread_param 	{
	int ID;
	int sleep_flag;
	//int priority;
	int  sleep_while;
	char stack[1000000];
	char exit_stack[1000000];
	ucontext_t context;
	ucontext_t exit_context;
} ARRAY[100];

ucontext_t main_context;
int cur_context_ID = 0;


//int context_id=0;
//int sleeping_guys=0;


void kb_back() {
	ARRAY[cur_context_ID].sleep_flag = 0;
}

int kbthread(void(*func)(),int k,int l, int m) {
	int thread_id;
	for(thread_id = 1; thread_id < 100; ++thread_id) {
		if (ARRAY[thread_id].sleep_flag == 0) {
			ARRAY[thread_id].ID = thread_id;
			ARRAY[thread_id].sleep_flag = 1;
			ARRAY[thread_id].sleep_while = 0;
			break;
		}
	}

	getcontext(&ARRAY[thread_id].exit_context);
	ARRAY[thread_id].exit_context.uc_stack.ss_sp = ARRAY[thread_id].exit_stack;
	ARRAY[thread_id].exit_context.uc_stack.ss_size = sizeof(ARRAY[thread_id].exit_stack);
	ARRAY[thread_id].exit_context.uc_link = &main_context;
	makecontext(&ARRAY[thread_id].exit_context, kb_back, 0);


	getcontext(&ARRAY[thread_id].context);
	ARRAY[thread_id].context.uc_stack.ss_sp = ARRAY[thread_id].stack;
	ARRAY[thread_id].context.uc_stack.ss_size = sizeof(ARRAY[thread_id].stack);
	ARRAY[thread_id].context.uc_link = &ARRAY[thread_id].exit_context;
	makecontext(&ARRAY[thread_id].context, func, 3, k,	 l, m);

	return thread_id;
}


void kbexit(int thread_id) {
	struct timespec time;
	time.tv_sec = 0;
	time.tv_nsec = 10000000;
	while (ARRAY[thread_id].sleep_flag != 0) {
		nanosleep(&time, 0);
	}
}

void my_thread_sleep(int ticks) {
	ARRAY[cur_context_ID].sleep_flag = 2;
	ARRAY[cur_context_ID].sleep_while = ticks;
	int temp_v = cur_context_ID;
	cur_context_ID = 0;
	swapcontext(&ARRAY[temp_v].context, &main_context);
}

void scheduler(int signal) {
	int thread_id, next_thread_id = 0;

	for (thread_id = 1; thread_id < 100; ++thread_id) {
		if (ARRAY[thread_id].sleep_flag == 2) {
			ARRAY[thread_id].sleep_while -= 1;
			if (ARRAY[thread_id].sleep_while == 0) {
				ARRAY[thread_id].sleep_flag = 1;
			}
		}
	}

	for (thread_id = 1; thread_id < 100; ++thread_id) {
		if (ARRAY[thread_id].sleep_flag == 1 && cur_context_ID != thread_id) {
			next_thread_id = thread_id;
			break;
		}
	}

	if (next_thread_id != 0) {
		cur_context_ID = next_thread_id;
		swapcontext(&main_context, &ARRAY[cur_context_ID].context);
	}
}






void func(int k, int l, int m){
	k++;
	int i;
	for(i=0;i<l;i++){
		printf("i'm %d:      %d\n",k,i);	
	
	  my_thread_sleep(m);
	}
}

int main(){
  	int i;
	for (i = 1; i < 100; ++i) {
		ARRAY[i].sleep_flag = 0;
	}

	int k=0;
	int just_another_array[100];
	int l[100];
	int m[100];
	
	puts("Input how much threads you want to start(100>X>0)");
	scanf("%d",&k);
	if(k>100 || k<=0){printf("wrong input");return 0;}
	for (i=0;i<k;i++){
	    printf("\nInput how much cycles you want do with thread %d, and what priority should it have\n", i+1);
	    scanf("%d %d",&l[i],&m[i]);
	}
	
	struct itimerval alarm_interval;

	alarm_interval.it_interval.tv_sec = 0;
	alarm_interval.it_interval.tv_usec = 100000;
	alarm_interval.it_value.tv_sec = 0;
	alarm_interval.it_value.tv_usec = 100000;
	setitimer(ITIMER_REAL, &alarm_interval, 0);
	signal(SIGALRM, scheduler); 
	
	
	int z;
	for (i=0;i<k;i++){
	just_another_array[i]=kbthread(func, i, l[i], m[i]);  
	  z=i+1;  
	  printf("\nTHREAD %d CREATED\n", z);
	}
	
	for (i=0;i<k;i++){
	  z=i+1;
	  kbexit(just_another_array[i]);
	  printf("\nThread %d have been finished\n",z);
	}
	return 0;

}