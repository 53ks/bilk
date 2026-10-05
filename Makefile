CC ?= gcc
ARCH ?= x86_64
CROSS_COMPILE ?=

LKL_DIR ?= lkl-cache
LKL_LIB ?= $(LKL_DIR)/tools/lkl/lib/liblkl.a

CFLAGS ?= -O2 -Wall -Iinclude -I$(LKL_DIR)/tools/lkl/include
LDFLAGS ?= $(LKL_LIB) -lpthread -ldl -lrt

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
