# libstring

A modest String library written in Zig 

## Installation

### 1. Setup `build.zig.zon`

If you don't already have a `build.zig.zon` file next to your `build.zig`, create one with a basic configuration:

```zig
.{
    .name = .your_project_name,
    .fingerprint = 0x000000000, // Replace with the unique fingerprint given by zig build command
    .version = "0.1.0",
    .paths = .{
        "build.zig",
        "build.zig.zon",
        "src",
    },
}
```

### 2. Fetch the dependency

Execute the following command in your terminal to download the library:

```bash
zig fetch --save git+https://github.com/YetAnotherMechanicusEnjoyer/libstring
```

> [!NOTE]
>
> This command will automatically fetch the latest commit, calculate the correct hash, and add it to your `build.zig.zon` dependencies.

### 3. Update `build.zig`

Lastly, link the dependency to your project in your `build.zig` file. Here is a complete example for a binary executable:

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 1. Setup your main module
    const module = b.createModule(.{
        .root_source_file = b.path("src/example.zig"), // Replace with your source file
        .target = target,
        .optimize = optimize,
    });

    // 2. Fetch libstring and add it as an import
    const libstring = b.dependency("string", .{ 
        .target = target, 
        .optimize = optimize 
    });
    module.addImport("string", libstring.module("string"));

    // 3. Build your artifact
    const exe = b.addExecutable(.{
        .name = "example", // Replace with your binary name
        .root_module = module,
    });

    b.installArtifact(exe);
}
```

## Usage

```zig
const string = @import("string");

// Optionnal
const String = string.String;
const StringError = string.StringError;
```
