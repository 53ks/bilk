#include "blik.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    const char *config = "conf/default.json";
    if (argc > 1) {
        config = argv[1];
    }

    if (blik_init(config) != 0) {
        fprintf(stderr, "[blik] failed to initialize kernel bridge\n");
        return 1;
    }

    blik_run();
    return 0;
}
