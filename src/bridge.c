#include "blik.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <lkl.h>
#include <lkl_host.h>

static void *lkl_mem_alloc(size_t size) {
    return malloc(size);
}

static void lkl_mem_free(void *ptr) {
    free(ptr);
}

int blik_init(const char *config_path) {
    printf("[blik] parsing configuration from: %s\n", config_path ? config_path : "default");

    if (lkl_host_mem_init(128 * 1024 * 1024) < 0) {
        fprintf(stderr, "[blik] failed to initialize lkl memory\n");
        return -1;
    }

    return 0;
}

void blik_run(void) {
    printf("[blik] starting lkl kernel instance...\n");

    long ret = lkl_start_kernel(&lkl_host_ops, "mem=128M loglevel=8");
    if (ret < 0) {
        fprintf(stderr, "[blik] failed to start lkl kernel: %ld\n", ret);
        return;
    }

    printf("[blik] lkl kernel started successfully\n");

    while (1) {
        lkl_sys_pause();
    }
}
