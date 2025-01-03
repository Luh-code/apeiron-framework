const std = @import("std");
const log = @import("apeiron-logger");
const Properties = log.Properties;
const LevelProperties = log.LevelProperties;
const Color = log.Color;
const print = std.debug.print;
const Scope = log.Scope;

fn getSrc() std.builtin.SourceLocation {
    return @src();
}

pub fn main() void {
    const allocator = std.heap.page_allocator;
    const fileName = log.generate_log_file_name(allocator, "./logs") catch |err| {
        std.debug.print("12234{}", .{err});
        return;
    };
    _ = fileName;

    //log.init("./logs", fileName) catch |err| {
    //    std.debug.print("error: {}\n", .{err});
    //};
    var args = try std.process.argsWithAllocator(allocator);
    log.init(allocator, &args) catch |err| {
        std.debug.print("error: {}\n", .{err});
    };
    //log.init(".", "test") catch |err| {
    //    std.debug.print("error: {}\n", .{err});
    //};
    defer log.deinit();

    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();

    log.add_time(&list);
    log.add_thread(&list);
    log.name_thread("main");
    log.add_thread(&list);
    log.name_thread("test");
    log.add_thread(&list);
    log.add_source(&list, getSrc());
    log.add_level(&list, &log.props.a_levelProps[2], 2);

    //print("{s}\n", .{list.items});

    //log.log("debug", "testing logging function", .{});
    //log.log("error", "testing logging function", .{});
    //log.log("fatal", "testing logging function", .{});
    const scope0 = Scope{
        .name = "major",
        .major = null,
    };
    const scope = Scope{
        .name = "test",
        .major = &scope0,
    };

    log.ldebug("testing logging function", &scope, .{});
    log.log("info_low", "testing logging function", null, .{});
    log.linfo("testing logging function", null, .{});
    log.lwarn("testing logging function", null, .{});
    log.lerror("testing logging function", null, .{});
    log.lfatal("testing logging function", null, .{});
}
