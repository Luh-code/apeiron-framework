pub const Version = struct {
    major: u16,
    minor: u16,
    patch: u16,

    /// create a new Version struct
    pub fn new(major: u16, minor: u16, patch: u16) Version {
        return Version{ .major = major, .minor = minor, .patch = patch };
    }

    /// Check if the version of a plugin is compatible with what's specified
    ///
    ///
    /// Here is a legend on the meaning of the versions in correspondance to API compatility:
    ///
    /// major version - shows the overall version of the API,
    ///  so any difference in major version is treated as breaking and will return false.
    /// minor version - is only allowed to be larger than the specified version,
    ///  as the minor version denotes only additions to the API, not breaking changes.
    /// patch version - is irrelevant for API compatility, as it only denotes internal changes.
    pub fn isCompatible(self: Version, other: Version) bool {
        return self.major == other.major and self.minor <= other.minor;
    }

    pub fn toString(self: *Version) []const u8 {
        return "" ++ self.major ++ "." ++ self.minor ++ "." ++ self.patch;
    }
};
