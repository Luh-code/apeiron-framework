const std = @import("std");
const log = @import("apeiron-logger");
const Scope = log.Scope;

const frame = @import("apeiron-framework");
const api = frame.api;

const testInterface = struct {
    pub const Provider: ?type = null;
    pub const Version = frame.Version{
        .major = 1,
        .minor = 0,
        .patch = 1,
    };
    extern fn foo(v: u32) i32;
};

const testImpl = struct {
    pub const Provides = testInterface;
    pub const Version = frame.Version{
        .major = 1,
        .minor = 1,
        .patch = 3,
    };
    pub fn foo(v: u32) i32 {
        return v * v;
    }
};

comptime {
    testInterface.Provider = testImpl;
}

//comptime {
//    var ModuleRegistry = frame.ModuleRegistry;
//
//    ModuleRegistry.registerInterface(testInterface);
//    ModuleRegistry.registerModule(testImpl);
//}
//
//const t = frame.ModuleRegistry.getAssociatedModule(testInterface);

pub fn main() void {
    const allocator = std.heap.page_allocator;

    var args = try std.process.argsWithAllocator(allocator);
    log.init(allocator, &args) catch |err| {
        std.debug.print("error: {}\n", .{err});
        return;
    };
    defer log.deinit();

    const func = comptime api.getFunc(testImpl, "a");

    log.lerror("test value: {d}", null, .{func(2)});
}
