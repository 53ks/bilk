CC ?= gcc
ARCH ?= x86_64
CROSS_COMPILE ?=

LKL_DIR ?= lkl-cache
LKL_LIB ?= $(LKL_DIR)/tools/lkl/lib/liblkl.a

CFLAGS ?= -O2 -Wall -Iinclude -I$(LKL_DIR)/tools/lkl/include
LDFLAGS ?= -lpthread -ldl

TARGET = blik
SRCS = src/main.c src/bridge.c
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

# すべてのオブジェクトファイルのコンパイル前に、必ずLKL（liblkl.aおよび自動生成ヘッダー）のビルドを完了させる
$(OBJS): $(LKL_LIB)

$(LKL_LIB):
	$(MAKE) -C $(LKL_DIR)/tools/lkl ARCH=$(ARCH) CROSS_COMPILE="$(CROSS_COMPILE)"

$(TARGET): $(OBJS) $(LKL_LIB)
	$(CC) $(OBJS) $(LKL_LIB) $(LDFLAGS) -o $(TARGET)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)
	$(MAKE) -C $(LKL_DIR)/tools/lkl clean

.PHONY: all clean
