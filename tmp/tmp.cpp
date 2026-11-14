#include <bits/stdc++.h>

long long f(long long x) {
    return -x;
}

int main() {
    // int num = 0xfffffea6;
    // int now = 0x00401ad1;
    // std::cout << num << ' ' << now << ' ' << now + num << '\n';
    // std::cout << std::hex << num << ' ' << now << ' ' << now + num << '\n';
    // printf("%lld", f(123456789012345LL));

    long long tg = 0x7fffffffe188;
    long long now = 0x7fffffffe060;
    now = now + 128;

    std::cout << std::hex << (tg - now) << '\n';

}