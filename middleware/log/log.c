#include "log.h"
#include <time.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

static void (*_log_process)(const char*, uint16_t) = NULL;
static time_t (*_rtc_get)(void) = NULL;

void Log_Init(void (*log_process)(const char*, uint16_t), time_t (*rtc_get)(void)){
	_log_process = log_process;
    _rtc_get = rtc_get;

	return;
}

#ifdef LOG_FULL
void Log_Put(const char* function_name, const uint8_t level, int line, const char* fmt, ...) {
    static char buffer[512];
    struct tm timeinfo;
    char time_str[32];
    time_t now = 0;

    if (_rtc_get != NULL)
        now = _rtc_get();

    localtime_r(&now, &timeinfo);
    strftime(time_str, sizeof(time_str), "[%d/%m/%Y %H:%M:%S]", &timeinfo);

    const char* level_str;
    switch(level) {
        case 0: level_str = "INFO "; break;
        case 1: level_str = "WARN "; break;
        default: level_str = "ERROR"; break;
    }

    int header_len = snprintf(buffer, sizeof(buffer),
                              "%s %s: %s().%d: ", time_str, level_str, function_name, line);
    if (header_len < 0 || header_len >= (int)sizeof(buffer))
        return;

    va_list args;
    va_start(args, fmt);
    int content_len = vsnprintf(buffer + header_len, sizeof(buffer) - (size_t)header_len, fmt, args);
    va_end(args);

    if (content_len < 0)
        return;

    int total = header_len + content_len;
    if (total + 2 < (int)sizeof(buffer)) {
        buffer[total]     = '\r';
        buffer[total + 1] = '\n';
        total += 2;
    }

    if (_log_process != NULL)
        _log_process(buffer, (uint16_t)total);
}
#else
void Log_Put(const uint8_t level, const char* fmt, ...) {
    va_list args;
    time_t now;
    struct tm *timeinfo;
    static char tmp[2048];
    char time_str[32];

    time(&now);
    timeinfo = localtime(&now);
    strftime(time_str, sizeof(time_str), "[%d/%m/%Y %H:%M:%S]", timeinfo);

    const char *level_str = (level == 0 ? "INFO" : level == 1 ? "WARN" : "ERROR");

    va_start(args, fmt);
    vsnprintf((char*)tmp, 2048, fmt, args);
    va_end(args);

    printf("%s %s: %s\r\n", time_str, level_str, tmp);

    return;
}
#endif