#include <iostream>
#include <cmath>
using namespace std;
int length = 4;
int msgLength = 16;
char msg[] = "Geeks for Geeks ";
char encryptedMgs[16];
char decryptedMgs[16];
int row = msgLength/length;
int code[] = {3,1,2,4};
int encryptCode[10];
int decryptCode[10];

bool linear_search(char arr1[],char arr2[],int length)
{
    for(int i = 0 ;i<length;++i)
        if(arr1[i]!=arr2[i])
            return 0;
    return 1;
}

void restore(int arr[])
{
    for(int i = 0;i<length;++i)
        arr[i]+=10;
}

void encrypt(int r,int code)
{
    for(int i = 0;i<row;++i)
        encryptedMgs[r++] = msg[i*length+code];
}

void decrypt(int r,int code)
{
    for(int i = 0; i< row;++i)
        decryptedMgs[i*length+r]  =encryptedMgs[code++];
}

int getMin(int arr[])
{
    int min = 0;
    for(int i = 0;i<length;++i)
        if(arr[min]>arr[i])
            min = i;
    arr[min]+=10;
    return min;
}

void generateKey(int arr[],int keyLength)
{
    for(int i = 0;i<keyLength;++i)
        arr[i] = rand()%10;
}

int main(int argc, char *argv[])
{
    srand(time(0));
    for(int i = 0;i<length;++i)
        encryptCode[i] = getMin(code);

    for(int i = 0;i<length;++i)
        encrypt(i*row,encryptCode[i]);

    for(int i = 0 ;i<length;++i)
        decryptCode[i] = getMin(encryptCode);

    int counter = 0;
    decryptedMgs[0] = ' ';
    while(!linear_search(msg,decryptedMgs,msgLength))
    {
        generateKey(code,length);
        for(int i = 0;i<length;++i)
            encryptCode[i] = getMin(code);
        for(int i = 0 ;i<length;++i)
            decryptCode[i] = getMin(encryptCode);
        for(int i = 0;i<length;++i)
            decrypt(i,length*decryptCode[i]);
        for(char c : decryptedMgs)
            cout<<c;
        cout<<endl;
        counter++;
    }
    cout<<counter<<endl;
}
