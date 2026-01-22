# Building Arculator on macOS and Linux

This guide covers building Arculator on macOS and Linux systems.

## Prerequisites

### macOS

Install Xcode Command Line Tools and CMake:

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install CMake and Ninja via Homebrew
brew install cmake ninja
```

### Linux (Debian/Ubuntu)

```bash
sudo apt update
sudo apt install build-essential cmake ninja-build git \
    libgtk-3-dev libx11-dev libasound2-dev
```

### Linux (Fedora)

```bash
sudo dnf install gcc gcc-c++ cmake ninja-build git \
    gtk3-devel libX11-devel alsa-lib-devel
```

### Linux (Arch)

```bash
sudo pacman -S base-devel cmake ninja git gtk3 libx11 alsa-lib
```

## Building

### Clone the Repository

```bash
git clone https://github.com/your-repo/arculator.git
cd arculator
```

### Configure with CMake

Use the default preset for a standard release build:

```bash
cmake --preset default
```

This will:
- Use the Ninja generator for fast builds
- Configure a Release build with optimizations
- Set up the install directory at `install/`

### Build

```bash
cmake --build build
```

### Install

The install step is **required** to set up Arculator correctly. It copies the executable along with all required ROMs, podules, and configuration files to the install directory.

```bash
cmake --install build
```

By default, this installs to the `install/` directory in the project root.

### One-Line Build and Install

You can combine the build and install steps:

```bash
cmake --build build --target install
```

## Running Arculator

After installation, navigate to the `install/` directory and run:

```bash
cd install
./arculator
```

## Debug Builds

For development or debugging:

```bash
cmake --preset debug
cmake --build build-debug --target install
```

This enables:
- Debug symbols (`-g`)
- No optimization (`-O0`)
- Debug logging (`DEBUG_LOG` define)

## Manual CMake Configuration

If you prefer not to use presets, you can configure manually:

```bash
# Create build directory
mkdir build && cd build

# Configure
cmake .. \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=../install

# Build
cmake --build .

# Install
cmake --install .
```

## Build Options

| Option | Default | Description |
|--------|---------|-------------|
| `CMAKE_BUILD_TYPE` | Release | Build type: Debug, Release, RelWithDebInfo, MinSizeRel |
| `ARCULATOR_BUILD_PODULES` | ON | Build expansion podule plugins |
| `CMAKE_INSTALL_PREFIX` | install/ | Installation directory |

Example with custom options:

```bash
cmake --preset default -DARCULATOR_BUILD_PODULES=OFF
cmake --build build --target install
```

## Troubleshooting

### Missing dependencies
The build system will attempt to fetch SDL2, wxWidgets, and zlib automatically if they're not found. This requires an internet connection during the first build.

### wxWidgets build fails on Linux
Ensure you have GTK3 development headers installed:
```bash
# Debian/Ubuntu
sudo apt install libgtk-3-dev

# Fedora
sudo dnf install gtk3-devel
```

### Permission denied when running
Make sure the executable has execute permissions:
```bash
chmod +x install/arculator
```
