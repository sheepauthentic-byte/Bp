# Tên file dylib đầu ra
TARGET = libAOVMod.dylib

# Trình biên dịch và các cờ tối ưu cho iOS arm64
CC = clang++
CFLAGS = -std=c++11 -arch arm64 -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path) -miphoneos-version-min=11.0 -fobjc-arc
LDFLAGS = -dynamiclib -undefined dynamic_lookup -framework Foundation -framework UIKit

# Thư mục chứa mã nguồn (nếu file Main.mm nằm chung thư mục gốc thì để trống)
SRC = Main.mm

all: $(TARGET)

$(TARGET): $(SRC)
	@echo "Đang biên dịch $(TARGET)..."
	$(CC) $(CFLAGS) $(LDFLAGS) $(SRC) -o $(TARGET)
	@echo "Biên dịch thành công!"

clean:
	@echo "Đang dọn dẹp file cũ..."
	rm -f $(TARGET)
