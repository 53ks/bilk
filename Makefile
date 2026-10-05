CC ?= gcc
CFLAGS ?= -O2 -Wall -Iinclude -I$(LKL_DIR)/tools/lkl/include
LDFLAGS ?= -lpthread -ldl

LKL_DIR ?= lkl
LKL_LIB ?= $(LKL_DIR)/tools/lkl/lib/liblkl.a

TARGET = blik
SRCS = src/main.c src/bridge.c
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

$(LKL_LIB):
	$(MAKE) -C $(LKL_DIR)/tools/lkl

$(TARGET): $(OBJS) $(LKL_LIB)
	$(CC) $(OBJS) $(LKL_LIB) $(LDFLAGS) -o $(TARGET)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)
	$(MAKE) -C $(LKL_DIR)/tools/lkl clean

.PHONY: all clean
