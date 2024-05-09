/*
 * Copyright (C) 2024 Rockchip Electronics Co., Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "ASL"
#include <utils/Log.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <binder/IPCThreadState.h>

#define UNUSED(x) (void)(x)

void usage() {
    printf("Usage:\n");
    printf(" asl\n");
    printf(" asl <linux-bin>\n");
    printf(" asl -s <linux-bin>\n");
    printf("Arguments:\n");
    printf(" -s : android server mode.\n");
    printf(" linux-bin : abs path in linux root.\n");
}

void setenvs() {
    const char *PATH = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
    const char *HOME = "/root";
    const char *DISPLAY=":0";
    const char *PULSE_SERVER="tcp:127.0.0.1:4713";

    if (setenv("PATH", PATH, 1) == -1) {
        perror("setenv");
        exit(EXIT_FAILURE);
    }

    if (setenv("HOME", HOME, 1) == -1) {
        perror("setenv");
        exit(EXIT_FAILURE);
    }

    if (setenv("DISPLAY", DISPLAY, 1) == -1) {
        perror("setenv");
        exit(EXIT_FAILURE);
    }

    if (setenv("PULSE_SERVER", PULSE_SERVER, 1) == -1) {
        perror("setenv");
        exit(EXIT_FAILURE);
    }
}

void execute(int size, char *argv[]) {
    const char *BASH = "/bin/bash";

    char *args[size + 4];
    int cst = 0;
    args[cst++] = (char*)"bash";
    args[cst++] = (char*)"--rcfile";
    args[cst++] = (char*)"~/.bashrc";
    args[cst++] = (char*)"-c";
    for (int i = 1; i < size; ++i) {
        args[cst + i - 1] = argv[i];
    }
    args[size + cst] = NULL;

    /*for (int i = 0; i < size + cst; ++i) {
        printf("[%d] %s\n", i, args[i]);
    }*/

    if (size == 1) {
        execl(BASH, "bash", NULL);
    } else {
        execvp(BASH, args);
    }
}

int main(int argc, char *argv[]) {
    if (getuid() != 0) {
        fprintf(stderr, "Permission Denied.\n");
        exit(EXIT_FAILURE);
    }

    bool bAndroidServerMode = false;
    char *process_name = NULL;
    if (argc > 1) {
        if (std::string(argv[1]) == std::string("-s")) {
            bAndroidServerMode = true;
            process_name = argv[2];
        } else if (std::string(argv[1]) == std::string("-h")) {
            usage();
            exit(EXIT_SUCCESS);
        }
        process_name = argv[1];
    }
    printf("Running asl as server=%d\n", bAndroidServerMode);

    const char *new_root = "/mnt/linux";
    if (chroot(new_root) == -1) {
        perror("chroot");
        exit(EXIT_FAILURE);
    }

    if (chdir("/") == -1) {
        perror("chdir");
        exit(EXIT_FAILURE);
    }

    pid_t pid = fork();
    if (pid == -1) {
        perror("fork");
        exit(EXIT_FAILURE);
    } else if (pid == 0) { // sub process
        setenvs();
        execute(
            bAndroidServerMode? argc - 1 : argc, 
            bAndroidServerMode? argv + 1 : argv);
        perror("exec");
        exit(EXIT_FAILURE);
    } else { // father process
        int status;
        pid_t wpid = waitpid(pid, &status, 0);
        if (WIFEXITED(status)) {
            ALOGI("process exited with status %d, pid=%d\n", WEXITSTATUS(status), wpid);
        }
    }

    if (bAndroidServerMode) {
        android::IPCThreadState::self()->joinThreadPool();
        ALOGI("ASL shutting down");
    }

    exit(EXIT_SUCCESS);
}