const microzig = @import("microzig");
const rp2xxx = microzig.hal;
const key_count = @import("keymap").key_count;

// Pinout of the Leonardo Keycaprio 0.7.
// Compared to 0.6 the thumb keys sit on their own row and the halves are
// swapped: the pins named ...R scan the left half and vice versa.
// zig fmt: off
pub const pin_config = rp2xxx.pins.GlobalConfiguration{
    .GPIO17 = .{ .name = "led", .direction = .out },

    .GPIO2 = .{ .name = "colPinkyL", .direction = .out },
    .GPIO3 = .{ .name = "colRingL", .direction = .out },
    .GPIO4 = .{ .name = "colMidL", .direction = .out },
    .GPIO8 = .{ .name = "colIndexL", .direction = .out },
    .GPIO9 = .{ .name = "colInnerL", .direction = .out },

    .GPIO7 = .{ .name = "rowTopL", .direction = .in },
    .GPIO12= .{ .name = "rowHomeL", .direction = .in },
    .GPIO6 = .{ .name = "rowBottomL", .direction = .in },

    .GPIO29 = .{ .name = "colPinkyR", .direction = .out },
    .GPIO28 = .{ .name = "colRingR", .direction = .out },
    .GPIO27 = .{ .name = "colMidR", .direction = .out },
    .GPIO23 = .{ .name = "colIndexR", .direction = .out },
    .GPIO21 = .{ .name = "colInnerR", .direction = .out },

    .GPIO20 = .{ .name = "rowTopR", .direction = .in },
    .GPIO16= .{ .name = "rowHomeR", .direction = .in },
    .GPIO22 = .{ .name = "rowBottomR", .direction = .in },

    .GPIO5 = .{ .name = "thumbRowL", .direction = .in },
    .GPIO26= .{ .name = "thumbRowR", .direction = .in },
};
pub const p = blk: {
    @setEvalBranchQuota(10_000);
    break :blk pin_config.pins();
};
pub const pin_mappings = [key_count]?[2]usize{
  .{0,0}, .{1,0}, .{2,0}, .{3,0}, .{4,0},  .{9,4},.{8,4},.{7,4},.{6,4},.{5,4},
  .{0,1}, .{1,1}, .{2,1}, .{3,1}, .{4,1},    .{9,5},.{8,5},.{7,5},.{6,5},.{5,5},
  .{0,2}, .{1,2}, .{2,2}, .{3,2}, .{4,2},    .{9,6},.{8,6},.{7,6},.{6,6},.{5,6},
                          .{1, 3},.{2, 3},   .{7, 7},.{6, 7}
};
// zig fmt: on

pub const pin_cols = [_]rp2xxx.gpio.Pin{
    //0         1           2           3           4
    p.colPinkyR, p.colRingR, p.colMidR, p.colIndexR, p.colInnerR,
    //5         6           7           8            9
    p.colPinkyL, p.colRingL, p.colMidL, p.colIndexL, p.colInnerL,
};

pub const pin_rows = [_]rp2xxx.gpio.Pin{
    //0        1           2             3
    p.rowTopR, p.rowHomeR, p.rowBottomR, p.thumbRowR,
    //4        5           6             7
    p.rowTopL, p.rowHomeL, p.rowBottomL, p.thumbRowL,
};
