CC ?= gcc
ARCH ?= x86_64
CROSS_COMPILE ?=

LKL_DIR = lkl-cache
LKL_LIB = $(LKL_DIR)/tools/lkl/lib/lkl.o

CFLAGS = -O2 -Wall -Iinclude -I$(LKL_DIR)/tools/lkl/include
LDFLAGS = -lpthread -ldl

TARGET = blik
SRCS = src/main.c src/bridge.c
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

$(LKL_LIB):
	@if [ ! -f "$(LKL_LIB)" ]; then \
		$(MAKE) -C $(LKL_DIR)/tools/lkl ARCH=$(ARCH) CROSS_COMPILE="$(CROSS_COMPILE)"; \
	fi

$(OBJS): $(LKL_LIB)

$(TARGET): $(OBJS) $(LKL_LIB)
	$(CC) $(OBJS) $(LKL_LIB) $(LDFLAGS) -o $(TARGET)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: all clean
