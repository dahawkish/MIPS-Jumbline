#include <stdio.h>
#include <stdlib.h>

#include "common.h"

typedef int (*ExchangeMethod)(char);

#define MARKTWO '1'
#define MARKINSERT '2'

char buffer[16];
int numChars = 6;

int mark = -1;
int mark2 = -1;


// compare the buffer with dictionary
int compare() {
    return 1;
}

// clear inout status
int clearInput() {
    mark = -1;
    mark2 = -1;

    return 1;
}

// echange the char between first and second chars
int exchange(int first, int second) {
    if(0 > first || 0 > second || numChars <= first || numChars <= second) {
	return 0; // fail to exchange
    }

    char tmp = buffer[first];
    buffer[first] = buffer[second];
    buffer[second] = tmp;

    return 1; // succeed
}

// mark the two chars to be exchanged
int markTwo(char input) {
     int tmpMark = input - '0';
     if(tmpMark == mark) { // if same, cancel first mark
	 mark = -1;
	 return 0;
     }

     if(-1 == mark) { // first char from unmark to mark
	 mark = tmpMark;
	 return 0;
     }
     // second
     mark2 = tmpMark;
     	    
     int ret = exchange(mark, mark2);
     mark = -1;
     mark2 = -1;
     if(0 == ret) {
	 INFO("Invalid input for exchanging\n");
     }
    
    return 0;
}

// mark one char, then insert to the position before the numeric input
int markInsert(char input) {
    int tmpMark = input - '0';
    if(tmpMark == mark) { // if same, cancel first mark
	mark = -1;
	return 0;
    } 

    if(-1 == mark) {
	mark = tmpMark;
	return 0;
    }

    char tmp;
    int i;
    if(mark < mark2) {
	for (i = mark; i < mark2 - 1; i++) {
	    tmp = buffer[i];
	    buffer[i] = buffer[i + 1];
	    buffer[i + 1] = buffer[i];
	}
    } else {
	for (i = mark; i > mark2; i--) {
	    tmp = buffer[i];
	    buffer[i] = buffer[i - 1];
	    buffer[i - 1] = tmp;
	}
    }
    
    mark = -1;
    mark2 = -1;
    return 0;
}

ExchangeMethod exchangeFunc = markTwo;

int chooseExchangeMethod(int method) {

    int ret = getchar();
    if(EOF == ret) {
	return -1;
    }

    char cmd = (char)ret;
    if('1' > cmd || '9' < cmd) {
	INFO("%d unsupported\n", ret);
	return -1;
    }
    
    switch (method) {
    case MARKTWO:
	exchangeFunc = &markTwo;
	break;
    case MARKINSERT:
	exchangeFunc = &markInsert;
	break;
    default:
	
    }

    return 0;
}


int rearrange(char* str, int n) {
    //printf("This is a line need to be erased\n");
    //printf("This is the second line");
	//printf("%c[2K", 27);
	//printf("\r                                        \r");
	//printf("After overwritting\n");	
	//printf("%s\n",str);	

    char cmd = -1;
    int intCmd = -1;

    if(7 < n || 3 > n) {
	ERROR("Invalid string length\n");
    }

    memset(buffer, 0, sizeof(buffer));
    strncpy(buffer, str, n);
    
    while (1) {
	intCmd = getchar();
	if(EOF == intCmd) {
	    ERROR("Internal error, read an invalid char from input\n");
	}

	cmd = (char)intCmd;

	if('0' <= cmd && '9' >= cmd) {
	    exchangeFunc(cmd);
	    continue;
	}

	switch (cmd) {
	case 'c': /*commit to compare*/
	    compare();
	    break;
	case 'e': /*exit*/
	    return 1;
	    break;
	case 'g':
	    
	    break;
	case 'm': /*choose exchange method*/
	    chooseExchangeMethod(0);
	    break;
	case 'x': /*exit*/
	    return 0;
	    break;
	}

    }


    return 0;
}


int main(int argc, char** argv) {
	if(argc < 2) {
		ERROR("Input format: ./rearrange {WORD}\n");	
	}	

	char *str = argv[1];
	int n = strlen(str) - 1;
	n++;

	rearrange(str,n);	

	return 0;
}
