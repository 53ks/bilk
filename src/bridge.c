#include "blik.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
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

    long mnt_ret = lkl_sys_mount("hostfs", "/", "hostfs", 0, NULL);
    if (mnt_ret < 0) {
        fprintf(stderr, "[blik] warning: failed to mount hostfs: %ld\n", mnt_ret);
    } else {
        printf("[blik] host filesystem mounted successfully to /\n");
    }

    printf("[blik] spawning initial init process inside lkl...\n");

    char *const argv[] = { "/bin/sh", NULL };
    char *const envp[] = { "PATH=/bin:/usr/bin:/sbin:/usr/sbin", "TERM=linux", NULL };

    long pid = lkl_sys_clone(LKL_CLONE_VM | LKL_CLONE_FS | LKL_CLONE_FILES | LKL_CLONE_SIGHAND, 0);
    if (pid == 0) {
        lkl_sys_execve("/bin/sh", argv, envp);
        lkl_sys_exit(1);
    } else if (pid < 0) {
        fprintf(stderr, "[blik] failed to clone process: %ld\n", pid);
    } else {
        printf("[blik] spawned init process with pid: %ld\n", pid);
        int status;
        lkl_sys_wait4(pid, &status, 0, NULL);
        printf("[blik] init process exited with status: %d\n", status);
    }

    printf("[blik] shutting down lkl kernel...\n");
    lkl_sys_sync();
}
