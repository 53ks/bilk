CC ?= gcc
ARCH ?= x86_64
CROSS_COMPILE ?=

LKL_DIR ?= lkl-cache
LKL_LIB ?= $(LKL_DIR)/tools/lkl/lib/lkl.o

CFLAGS ?= -O2 -Wall -Iinclude -I$(LKL_DIR)/tools/lkl/include
LDFLAGS ?= -lpthread -ldl

TARGET = blik
SRCS = src/main.c src/bridge.c
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

$(LKL_LIB):
	mkdir -p $(LKL_DIR)
	if [ ! -d "$(LKL_DIR)/tools/lkl" ]; then \
		git clone --depth 1 https://github.com/lkl/linux.git temp_lkl; \
		mkdir -p $(LKL_DIR)/tools; \
		mv temp_lkl/tools/lkl $(LKL_DIR)/tools/lkl; \
		rm -rf temp_lkl; \
	fi
	$(MAKE) -C $(LKL_DIR)/tools/lkl ARCH=$(ARCH) CROSS_COMPILE="$(CROSS_COMPILE)"

$(OBJS): $(LKL_LIB)

$(TARGET): $(OBJS) $(LKL_LIB)
	$(CC) $(OBJS) $(LKL_LIB) $(LDFLAGS) -o $(TARGET)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: all clean
