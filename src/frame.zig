const version = @import("core/version.zig");
pub const Version = version.Version;

pub const api = @import("core/api.zig");

const moduleRegistry = @import("core/moduleRegistry.zig");
pub var ModuleRegistry = moduleRegistry.ModuleRegistry{};
