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
#include <vector>
#include <sstream>
#include <fstream>

#define ROOTDIR "/mnt/linux"
#define UNUSED(x) (void)(x)
#define DEBUG 0


struct args_t {
    bool bPrintUsage;
    bool bAndroidServerMode;
    bool bHasCommands;
    std::string sPidFile;
    std::string sCommandName;
    std::vector<std::string> vCommandArgs; 
};

void usage() {
    printf("Usage:\n");
    printf(" asl\n");
    printf(" asl <linux-bin>\n");
    printf(" asl -s -p <pid_file> <linux-bin>\n");
    printf("Arguments:\n");
    printf(" -s : android server mode.\n");
    printf(" -p : linux pid file path.\n");
    printf(" linux-bin : abs path in linux root.\n");
}

args_t parse(int argc, char *argv[]) {
    args_t args = {};
    for (int i = 1; i < argc; ++i) {
        if (std::string(argv[i]) == std::string("-h")) {
            args.bPrintUsage = true;
            return std::move(args);
        } else if (std::string(argv[i]) == std::string("-s")) {
            args.bAndroidServerMode = true;
        } else if (std::string(argv[i]) == std::string("-p")) {
            if (i + 1 >= argc) {    // ERR
                args.bPrintUsage = true;
                return std::move(args);
            }
            args.sPidFile = argv[++i];
        } else {  /** Command In Chroot **/
            args.bHasCommands = true;
            args.sCommandName = argv[i++];
            for (; i < argc ; ++i) {
                args.vCommandArgs.push_back(argv[i]);
            }
        }
    }
    return std::move(args);
}

int readpid(const std::string &pid_file) {
    std::ifstream file(pid_file);
    int pid = -1;
    if (!file.good()) {
        ALOGE("pid file %s is not exsited!", pid_file.c_str());
    } else if (file.is_open()) {
        file >> pid;
        file.close();
        ALOGI("pid file %s is opened! pid=%d", pid_file.c_str(), pid);
        return pid;
    }
    return pid;
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

void execute(bool bHasCommands, const std::string &commands, const std::vector<std::string> &parms) {
    const char *BASH = "/bin/bash";

    char *args[6];
    int cst = 0;
    args[cst++] = (char*)"bash";
    args[cst++] = (char*)"--rcfile";
    args[cst++] = (char*)"~/.bashrc";
    args[cst++] = (char*)"-c";
    std::stringstream ss;
    ss << commands;
    for (int i = 0; i < parms.size(); ++i) {
        ss << " " << parms[i];
    }
    args[cst++] = (char*)ss.str().c_str();
    args[cst++] = NULL;

#if DEBUG
    printf("--- linux command ---\n");
    for (int i = 0; i < cst; ++i) {
        printf("[%d] %s\n", i, args[i]);
    }
#endif

    if (!bHasCommands) {
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

    args_t args = parse(argc, argv);
#if DEBUG
    printf("* print usage: %d\n", args.bPrintUsage);
    printf("* android server mode: %d\n", args.bAndroidServerMode);
    printf("* has linux command: %d\n", args.bHasCommands);
    printf("* linux pid file path: %s\n", args.sPidFile.c_str());
    printf("* linux command: %s\n", args.sCommandName.c_str());
#endif
    if (args.bPrintUsage) {
        usage();
        exit(EXIT_SUCCESS);
    }

    if (chroot(ROOTDIR) == -1) {
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
        execute(args.bHasCommands, args.sCommandName, args.vCommandArgs);
        perror("exec");
        exit(EXIT_FAILURE);
    } else { // father process
        int status;
        pid_t wpid = waitpid(pid, &status, 0);
        if (WIFEXITED(status)) {
            ALOGI("process exited with status %d, pid=%d\n", WEXITSTATUS(status), wpid);
        }
    }

    if (args.bAndroidServerMode) {
        sleep(1);
        int fpid = readpid(args.sPidFile);
        while (1) {
            if (kill(fpid, 0) == -1) {
                if (errno == ESRCH) {
                    ALOGI("server exited %d\n", fpid);
                    break;
                } else {
                    perror("kill");
                    exit(EXIT_FAILURE);
                }
            }
            sleep(1);
        }
    }

    exit(EXIT_SUCCESS);
}