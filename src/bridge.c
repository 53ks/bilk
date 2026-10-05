#include "blik.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int blik_init(const char *config_path) {
    printf("[blik] initializing platform bridge with config: %s\n", config_path ? config_path : "default");
    return 0;
}

void blik_run(void) {
    printf("[blik] running kernel environment...\n");
}
