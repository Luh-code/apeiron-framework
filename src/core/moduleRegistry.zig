const std = @import("std");
const version = @import("version.zig");
const Version = version.Version;

//const RegistryData = struct { comptime interfaces: []const type = &[_]type{}, modules: []const ?type };

/// Registry for interfaces and their modules
pub const ModuleRegistry = struct {
    pub var interfaces = [_]type{};
    pub var modules = [_]?type{};
    //var registryData = RegistryData{};
    //pub var registryData = RegistryData{ .interfaces = &[_]type{}, .modules = &[_]?type{} };

    /// Add an interface to the Registry
    pub fn registerInterface(self: *ModuleRegistry, t: type) void {
        inline for (self.interfaces) |value| {
            if (value == t) @compileError("Interface '" ++ @typeName(t) ++ "' already registered!");
        }
        self.interfaces = self.interfaces ++ [_]type{t};
        self.modules = self.modules ++ [_]?type{null};
    }

    fn getProvides(t: type) type {
        if (!@hasDecl(t, "Provides")) @compileError("Module '" ++ @typeName(t) ++ "' is not implementing any interface!");
        return t.Provides;
    }

    fn getVersion(t: type) *const Version {
        if (!@hasDecl(t, "Version")) @compileError("'" ++ @typeName(t) ++ "' is not versioned!");
        return &t.Version;
    }

    /// Validates version compatibility between the given interface and module
    fn validateCompatibility(interface: type, module: type) void {
        const iVersion = getVersion(interface);
        const mVersion = getVersion(module);

        if (!iVersion.isCompatible(mVersion))
            @compileError("Version mismatch between interface '" ++ @typeName(interface) ++ "' (" ++ iVersion.toString() ++ ") and module '" ++ @typeName(module) ++ "' (" ++ mVersion.toString() ++ ")!");
    }

    /// Validates the interface contract between the given interface and module
    fn validateContract(interface: type, module: type) void {
        const fields = std.meta.fields(type);

        for (fields) |field| {
            if (!field.is_fn) continue;

            if (!@hasDecl(module, field.name))
                @compileError("Module '" ++ @typeName(module) ++ "' broke interface contract defined by '" ++ @typeName(interface) ++ "' as function '" ++ field.name ++ "' is undefined");
        }
    }

    /// Registers a module to an according interface
    /// Checks compatibility and validates contract
    pub fn registerModule(self: *ModuleRegistry, t: type) void {
        const Provides = getProvides(t);

        inline for (self.interfaces, 0..) |value, i| {
            if (value != Provides) continue;

            if (self.modules[i] != null) @compileError("Implementation for '" ++ @typeName(value) ++ "' is already registered!");

            validateCompatibility(value, t);
            validateContract(value, t);

            self.modules[i] = t;
            return;
        }

        @compileError("Interface '" ++ @typeName(Provides) ++ "' implemented by module '" ++ @typeName(t) ++ "' is not registered!");
    }

    /// Get a module from the Registry given the Interface type
    pub fn getAssociatedModule(self: *ModuleRegistry, t: type) type {
        inline for (self.interfaces, 0..) |value, i| {
            if (value.Provides == t) {
                if (self.modules[i] != null) return self.modules[i];

                @compileError("No implementation for '" ++ @typeName(t) ++ "' found!");
            }
        }
        @compileError("Interface '" ++ @typeName(t) ++ "' not found!");
    }
};
