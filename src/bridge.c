#include "blik.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <lkl.h>
#include <lkl_host.h>

int blik_init(const char *config_path) {
    printf("[blik] loading configuration from: %s\n", config_path);

    FILE *f = fopen(config_path, "r");
    if (!f) {
        fprintf(stderr, "[blik] failed to open config file: %s\n", config_path);
        return -1;
    }

    fseek(f, 0, SEEK_END);
    long len = ftell(f);
    fseek(f, 0, SEEK_SET);

    char *buf = malloc(len + 1);
    if (!buf) {
        fclose(f);
        return -1;
    }

    fread(buf, 1, len, f);
    buf[len] = '\0';
    fclose(f);

    printf("[blik] config loaded (%ld bytes)\n", len);
    free(buf);

    if (lkl_host_mem_init(128 * 1024 * 1024) < 0) {
        fprintf(stderr, "[blik] failed to initialize lkl memory\n");
        return -1;
    }

    return 0;
}

void blik_run(void) {
    printf("[blik] starting lkl kernel instance...\n");

    long ret = lkl_start_kernel(&lkl_host_ops, "mem=128M loglevel=8 ip=dhcp");
    if (ret < 0) {
        fprintf(stderr, "[blik] failed to start lkl kernel: %ld\n", ret);
        return;
    }

    printf("[blik] lkl kernel started successfully\n");

    struct lkl_netdev *nd = lkl_netdev_tap_create("tap0");
    if (!nd) {
        fprintf(stderr, "[blik] failed to create tap netdev\n");
    } else {
        int id = lkl_netdev_add(nd);
        if (id < 0) {
            fprintf(stderr, "[blik] failed to add netdev to lkl: %d\n", id);
        } else {
            printf("[blik] netdev tap0 added successfully with id: %d\n", id);
        }
    }

    while (1) {
        lkl_sys_pause();
    }
}
