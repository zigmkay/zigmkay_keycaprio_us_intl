const std = @import("std");
const builtin = @import("builtin");

const microzig = @import("microzig");

const MicroBuild = microzig.MicroBuild(.{
    .rp2xxx = true,
});

pub const KeycaprioVersion = enum { @"0.6", @"0.7" };

pub fn build(b: *std.Build) void {
    const mz_dep = b.dependency("microzig", .{});
    const mb = MicroBuild.init(b, mz_dep) orelse return;

    const target = mb.ports.rp2xxx.boards.raspberrypi.pico.*;
    const optimize: std.builtin.OptimizeMode = .ReleaseSafe;

    const firmware_dep = b.dependency("zigmkay_firmware", .{});
    const zigmkay_mod = firmware_dep.module("zigmkay");
    const zkeycodes_mod = b.createModule(.{
        .root_source_file = firmware_dep.path("zkeycodes/root.zig"),
        .imports = &.{.{ .name = "zigmkay", .module = zigmkay_mod }},
    });

    const keymap_mod = b.addModule("keymap", .{
        .root_source_file = b.path("src/keymap.zig"),
        .imports = &.{
            .{ .name = "zigmkay", .module = zigmkay_mod },
            .{ .name = "zkeycodes", .module = zkeycodes_mod },
        },
    });

    const keycaprio = b.option(KeycaprioVersion, "keycaprio", "Keycaprio PCB revision (default: 0.7)") orelse .@"0.7";
    const build_options = b.addOptions();
    build_options.addOption(KeycaprioVersion, "keycaprio", keycaprio);

    const firmware = mb.add_firmware(.{
        .name = "zigmkay",
        .target = &target,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
    });

    firmware.add_app_import("zigmkay", zigmkay_mod, .{ .depend_on_microzig = true });
    firmware.add_app_import("zkeycodes", zkeycodes_mod, .{ .depend_on_microzig = true });
    firmware.add_app_import("keymap", keymap_mod, .{ .depend_on_microzig = true });
    firmware.add_app_import("build_options", build_options.createModule(), .{});
    mb.install_firmware(firmware, .{});

    const firmware_uf2 = firmware.get_emitted_bin(.{ .uf2 = .{ .family_id = .RP2040 } });
    b.addNamedLazyPath("firmware_uf2", firmware_uf2);

    const flash_mount_step = b.step("flash_mount", "Build and flash through a mounted RP2 bootloader volume");
    const flash_mount_command = b.addSystemCommand(&.{ "sh", "-c", "until diskutil info \"$2\" >/dev/null 2>&1; do sleep 0.2; done; sleep 0.5; cp \"$1\" \"$2/firmware.uf2\" && sync", "sh" });
    flash_mount_command.addFileArg(firmware_uf2);
    flash_mount_command.addArg(b.option([]const u8, "flash-mount", "Mounted RP2 bootloader volume") orelse "/Volumes/RPI-RP2");
    flash_mount_command.has_side_effects = true;
    flash_mount_step.dependOn(&flash_mount_command.step);

    const flash_pt_step = b.step("flash_pt", "Build and flash with picotool");
    const flash_pt_command = @import("zigmkay_firmware").addPicotoolFlash(b, firmware_dep, firmware_uf2);
    flash_pt_step.dependOn(&flash_pt_command.step);

    const flash_step = b.step("flash", "Build and flash using the host default");
    if (builtin.os.tag == .macos) {
        flash_step.dependOn(&flash_pt_command.step);
    } else {
        flash_step.dependOn(&flash_mount_command.step);
    }
}
