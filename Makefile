CC = clang
CFLAGS = -fobjc-arc -framework Foundation -framework IOKit
TARGET = mac-temp
SOURCE = mac-temp.m
PREFIX = /usr/local/bin

.PHONY: all install uninstall clean release

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)

install: $(TARGET)
	sudo cp $(TARGET) $(PREFIX)/$(TARGET)
	@echo "Installed to $(PREFIX)/$(TARGET)"

uninstall:
	sudo rm -f $(PREFIX)/$(TARGET)
	@echo "Uninstalled $(TARGET)"

clean:
	rm -f $(TARGET) $(TARGET)-arm64 $(TARGET)-x86_64

release: $(SOURCE)
	$(CC) $(CFLAGS) -target arm64-apple-macos12 -o $(TARGET)-arm64 $(SOURCE)
	$(CC) $(CFLAGS) -target x86_64-apple-macos12 -o $(TARGET)-x86_64 $(SOURCE)
	lipo -create -output $(TARGET) $(TARGET)-arm64 $(TARGET)-x86_64
	@echo "Universal binary ready: $(TARGET)"
	@lipo -info $(TARGET)
