fn getFuncType(impl: anytype, func: []const u8) type {
    if (!@hasDecl(impl, func)) {
        @compileError("Implementation '" ++ @typeName(impl) ++ "' does not provide requested function '" ++ func ++ "'");
    }
    return @TypeOf(@field(impl, func));
}

pub fn getFunc(impl: anytype, func: []const u8) getFuncType(impl, func) {
    return @field(impl, func);
}
