const keymap = @import("keymap");
const zigmkay = @import("zigmkay");
const microzig = @import("microzig");
comptime {
    microzig.export_startup();
}
pub const std_options = microzig.std_options(.{});
const time = microzig.hal.time;

// Pinout of the selected Keycaprio revision, chosen with `zig build -Dkeycaprio=...`.
const board = switch (@import("build_options").keycaprio) {
    .@"0.6" => @import("boards/keycaprio_0_6.zig"),
    .@"0.7" => @import("boards/keycaprio_0_7.zig"),
};
const p = board.p;

pub fn main() !void {
    @setEvalBranchQuota(10_000);
    _ = board.pin_config.apply();
    blink_led(1, 300); // Show the user that the keyboard has actually booted up.

    comptime var config = zigmkay.loops.GetUnibodyConfigType(&keymap.dimensions){
        .config = .{
            .keymap = &keymap.keymap,
            .custom_functions = &keymap.custom_functions,
            .side_definition = &keymap.sides,
            .combos = keymap.combos[0..],
            .scanner_settings = &.{
                .matrix = .{
                    .debounce = .{ .ms = 50 },
                    .pins_to_keys_mapping = &board.pin_mappings,
                    .pin_cols = board.pin_cols[0..],
                    .pin_rows = board.pin_rows[0..],
                    .direction = .col2row,
                },
            },
        },
    };

    comptime var runner = config.build();
    runner.run_unibody() catch {
        blink_led(10000000, 500); // in case of an error, let the keyboard start blinking
    };
}

fn blink_led(blink_count: u32, interval_ms: u32) void {
    var counter = blink_count;
    while (counter > 0) : (counter -= 1) {
        p.led.put(1);
        time.sleep_us(interval_ms * 1000);
        p.led.put(0);
        time.sleep_us(interval_ms * 1000);
    }
}
