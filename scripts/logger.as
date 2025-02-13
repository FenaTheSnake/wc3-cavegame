int __debug_depth = 0;

void __debug_section_start(const string &in s) {
    for(int i = 0; i < __debug_depth; i++) print("  ");
    print("[ " + s + " ] {\n");
    __debug_depth++;
}
void __debug(const string &in s) {
    for(int i = 0; i < __debug_depth; i++) print("  ");
    print(s + "\n");
}
void __debug_section_end() {
    __debug_depth--;
    for(int i = 0; i < __debug_depth; i++) print("  ");
    print("}\n");
}

//

// void __debug_section_start(const string &in s) {
//     // for(int i = 0; i < __debug_depth; i++) print("  ");
//     // print("[ " + s + " ] {\n");
//     // __debug_depth++;
// }
// void __debug(const string &in s) {
//     // for(int i = 0; i < __debug_depth; i++) print("  ");
//     // print(s + "\n");
// }
// void __debug_section_end() {
// //     __debug_depth--;
// //     for(int i = 0; i < __debug_depth; i++) print("  ");
// //     print("}\n");
//  }