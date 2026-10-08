const microzig = @import("microzig");
const rp2xxx = microzig.hal;
const key_count = @import("keymap").key_count;

// Pinout of the Leonardo Keycaprio 0.6.
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

    .GPIO5 = .{ .name = "thumbCol1L", .direction = .out },
    .GPIO13= .{ .name = "thumbCol2L", .direction = .out },
    .GPIO26 = .{ .name = "thumbCol1R", .direction = .out },
    .GPIO15 = .{ .name = "thumbCol2R", .direction = .out },
};
pub const p = blk: {
    @setEvalBranchQuota(10_000);
    break :blk pin_config.pins();
};
pub const pin_mappings = [key_count]?[2]usize{
  .{0,0}, .{1,0}, .{2,0}, .{3,0}, .{4,0},  .{11,3},.{10,3},.{9,3},.{8,3},.{7,3},
  .{0,1}, .{1,1}, .{2,1}, .{3,1}, .{4,1},    .{11,4},.{10,4},.{9,4},.{8,4},.{7,4},
  .{0,2}, .{1,2}, .{2,2}, .{3,2}, .{4,2},    .{11,5},.{10,5},.{9,5},.{8,5},.{7,5},
                          .{6, 2},.{5, 2},   .{12, 5},.{13, 5}
};
// zig fmt: on

pub const pin_cols = [_]rp2xxx.gpio.Pin{
    //0         1           2           3           4           5               6
    p.colPinkyL, p.colRingL, p.colMidL, p.colIndexL, p.colInnerL, p.thumbCol1L, p.thumbCol2L,
    //7         8           9           10           11          12             13
    p.colPinkyR, p.colRingR, p.colMidR, p.colIndexR, p.colInnerR, p.thumbCol1R, p.thumbCol2R,
};

pub const pin_rows = [_]rp2xxx.gpio.Pin{
    //0        1           2
    p.rowTopL, p.rowHomeL, p.rowBottomL,
    //3        4           5
    p.rowTopR, p.rowHomeR, p.rowBottomR,
};
