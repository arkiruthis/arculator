# Arculator

Arculator is an Acorn Archimedes emulator originally written by [Sarah Walker](https://github.com/sarah-walker-pcem). It emulates the Acorn Archimedes series of computers, including models like the A3000, A3010, A3020, A4000, A5000, and more.

⚠️ **This is a fork of the original project but using CMake instead of automake to assist with cross-platform development. <u>It is currently heavily in progress!</u>** ⚠️

## Building

Arculator uses CMake as its build system. Dependencies (SDL2, wxWidgets, zlib) are automatically fetched during configuration.

### Prerequisites

- CMake 3.20 or later
- A C/C++ compiler:
  - **Linux/macOS**: GCC or Clang
  - **Windows**: MSYS2 with MinGW64 or UCRT64 toolchain (MSVC is **not** supported)
- Ninja (recommended) or Make

### Quick Start

```bash
# Configure with default preset (Release build with Ninja)
cmake --preset default

# Build and install
cmake --build build --target install
```

The executable will be installed into an `install` in the root of this project, with the roms, and podules copied in.

### Platform-Specific Build Guides

- **[Building on macOS/Linux](docs/Building-macOS-Linux.md)** - Guide for building on Unix-like systems
- **[Building on Windows (MSYS2)](docs/Building-Windows-MSYS2.md)** - Guide for building with MinGW64 or UCRT64 toolchains

### Available Presets

| Preset | Description |
|--------|-------------|
| `default` | Release build using Ninja generator |
| `debug` | Debug build with symbols and debug logging |
| `no-podules` | Build without podule plugins |
| `msys2-mingw64` | Build using MSYS2 MINGW64 toolchain (Windows) |
| `msys2-ucrt64` | Build using MSYS2 UCRT64 toolchain (Windows) |

### Build Options

| Option | Default | Description |
|--------|---------|-------------|
| `ARCULATOR_BUILD_PODULES` | ON | Build expansion podule plugins |

## Running

Before running Arculator, you'll need appropriate ROM files placed in the `roms/` directory. See the `roms/` subdirectories for details on which ROM files are expected.

## License

See [COPYING](COPYING) for license information.
