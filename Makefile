CC ?= gcc
ARCH ?= x86_64
CROSS_COMPILE ?=

LKL_DIR ?= lkl-cache
LKL_LIB_DIR ?= $(LKL_DIR)/tools/lkl/lib

LDFLAGS ?= -Wl,--start-group \
           $(LKL_LIB_DIR)/lkl.o \
           $(LKL_LIB_DIR)/hijack/liblkl-hijack.a \
           -Wl,--end-group \
           -lpthread -ldl -lrt

CFLAGS ?= -O2 -Wall -Iinclude -I$(LKL_DIR)/tools/lkl/include -I$(LKL_DIR)/tools/lkl/include/lkl

TARGET = blik
SRCS = src/main.c src/bridge.c
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $(TARGET)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: all clean
