# Arculator

Arculator is an Acorn Archimedes emulator originally written by [Sarah Walker](https://github.com/sarah-walker-pcem). It emulates the Acorn Archimedes series of computers, including models like the A3000, A3010, A3020, A4000, A5000, and more.

⚠️ **This is a fork of the original project but using CMake instead of automake to assist with cross-platform development. <u>It is currently heavily in progress!</u>** ⚠️

The emulator supports:
- Multiple Archimedes machine types
- Various ARM processor variants (ARM2, ARM250, ARM3)
- RISC OS versions from Arthur to RISC OS 3.19
- Floppy and hard disc support
- Expansion podules
- Sound and joystick emulation

## Building

Arculator uses CMake as its build system. Dependencies (SDL2, wxWidgets, zlib) are automatically fetched during configuration if not found on your system.

### Prerequisites

- CMake 3.20 or later
- A C/C++ compiler (GCC, Clang, or MSVC)
- Ninja (recommended) or Make

### Quick Start

```bash
# Configure with default preset (Release build with Ninja)
cmake --preset default

# Build
cmake --build build
```

The executable will be placed in `build/bin/arculator` and automatically copied to the project root as `./arculator` for convenience.

### Available Presets

| Preset | Description |
|--------|-------------|
| `default` | Release build using Ninja generator |
| `debug` | Debug build with symbols and debug logging |
| `release` | Optimized release build for distribution |
| `no-podules` | Build without podule plugins |
| `xcode` | Build using Xcode generator (macOS) |
| `vs2022` | Build using Visual Studio 2022 (Windows) |

### Examples

```bash
# Debug build
cmake --preset debug
cmake --build build-debug

# Release build
cmake --preset release
cmake --build build-release

# Build with Xcode on macOS
cmake --preset xcode
cmake --build build-xcode --config Release

# Build with Visual Studio on Windows
cmake --preset vs2022
cmake --build build-vs2022 --config Release
```

### Build Options

| Option | Default | Description |
|--------|---------|-------------|
| `ARCULATOR_BUILD_PODULES` | ON | Build expansion podule plugins |
| `ARCULATOR_ENABLE_DEBUG` | OFF | Enable debug logging |
| `ARCULATOR_RELEASE_BUILD` | OFF | Enable release build optimizations |

## Running

Before running Arculator, you'll need appropriate ROM files placed in the `roms/` directory. See the `roms/` subdirectories for details on which ROM files are expected.

## License

See [COPYING](COPYING) for license information.
