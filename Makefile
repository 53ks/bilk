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

# lkl-libが存在しない（または手動で消された）場合のみLKLのビルドを実行する
$(LKL_LIB):
	@if [ ! -f "$(LKL_LIB)" ]; then \
		echo "Building LKL in $(LKL_DIR)..."; \
		$(MAKE) -C $(LKL_DIR)/tools/lkl ARCH=$(ARCH) CROSS_COMPILE="$(CROSS_COMPILE)"; \
	else \
		echo "Using existing LKL cache from $(LKL_DIR)."; \
	fi

$(OBJS): $(LKL_LIB)

$(TARGET): $(OBJS) $(LKL_LIB)
	$(CC) $(OBJS) $(LKL_LIB) $(LDFLAGS) -o $(TARGET)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)
	# lkl-cache自体は消さない（成果物を保持するため）

clean-all: clean
	$(MAKE) -C $(LKL_DIR)/tools/lkl clean

.PHONY: all clean clean-all
