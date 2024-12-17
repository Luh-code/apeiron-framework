const std = @import("std");
const log = @import("apeiron-logger");
const Properties = log.Properties;
const LevelProperties = log.LevelProperties;
const Color = log.Color;
const print = std.debug.print;
const Scope = log.Scope;

const frame = @import("apeiron-framework");
const api = frame.api;

const testImpl = struct {
    pub fn a(v: i32) i32 {
        return v * v;
    }
};

pub fn main() void {
    const allocator = std.heap.page_allocator;

    var args = try std.process.argsWithAllocator(allocator);
    log.init(allocator, &args) catch |err| {
        std.debug.print("error: {}\n", .{err});
        return;
    };
    defer log.deinit();

    const func = comptime api.getFunc(testImpl, "abasd");

    log.lerror("test value: {d}", null, .{func(2)});
}
