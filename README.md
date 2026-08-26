# mac-temp

A lightweight CLI tool to read CPU and thermal sensor temperatures on Apple Silicon Macs directly from the PMU (Power Management Unit) via IOKit.

No dependencies. No Homebrew required to build. Native Objective-C.

## Requirements

- macOS 12+ (Monterey or later)
- Apple Silicon Mac (M1, M2, M3, M4 series)
- Xcode Command Line Tools (`xcode-select --install`) — only needed if building from source

## Installation

### Option 1 — Homebrew

```bash
brew install zackwag/tap/mac-temp
```

### Option 2 — Build from source

```bash
git clone https://github.com/zackwag/mac-temp.git
cd mac-temp
make install
```

### Option 3 — Download pre-built universal binary

Download the latest binary from [Releases](../../releases), then:

```bash
chmod +x mac-temp
sudo mv mac-temp /usr/local/bin/
```

The binary is code-signed with a Developer ID and notarized by Apple — no Gatekeeper warnings.

## Usage

```bash
mac-temp            # All sensors, human-readable
mac-temp --json     # JSON output
mac-temp --raw      # Single number (°C), pipe-friendly
mac-temp --help     # Show help message
```

### Example output

```plaintext
PMU tcal             51.9°C
PMU tdev1            49.2°C
PMU tdev2            48.7°C
PMU tdev3            47.1°C
```

### Piping examples

```bash
# Watch temps every 5 seconds
watch -n 5 'mac-temp'

# Capture raw CPU temp into a variable
TEMP=$(mac-temp --raw)
echo "CPU: ${TEMP}°C"

# Simple overheat alert
TEMP=$(mac-temp --raw)
if (( $(echo "$TEMP > 80" | bc -l) )); then
  osascript -e "display notification \"${TEMP}°C\" with title \"⚠️ High Temp\""
fi

# Log to a file
while true; do
  echo "$(date '+%Y-%m-%d %H:%M:%S') $(mac-temp --raw)°C" >> ~/temp-log.txt
  sleep 60
done
```

### JSON output (`mac-temp --json`)

```json
{
  "PMU tcal": 51.9,
  "PMU tdev1": 49.2,
  "PMU tdev2": 48.7,
  "PMU tdev3": 47.1
}
```

## Building a universal binary (for releases)

```bash
make release
```

This produces a single `mac-temp` binary that runs natively on both Apple Silicon and Intel Macs.

## How it works

Apple Silicon Macs expose thermal sensors as `AppleARMPMUTempSensor` services in the IORegistry. Each sensor is an `IOHIDEventService` that delivers temperature readings as HID events. This tool uses the private `IOHIDEventSystem` API to enumerate those services and read live temperature values directly — the same approach used by tools like `mactop` and `asitop`.

## License

MIT
