inline fn GetFieldType(comptime T: type, comptime name: []const u8) type {
    const PtrT = if (@typeInfo(T) == .pointer) @typeInfo(T).pointer.child else T;

    if (@hasField(PtrT, name)) {
        return @TypeOf(@field(@as(PtrT, undefined), name));
    }
    @compileError("Field '" ++ name ++ "' not found in class" ++ @typeName(T));
}

pub inline fn get(self: anytype, comptime field_name: []const u8) GetFieldType(@TypeOf(self), field_name) {
    const T = @TypeOf(self);
    const PtrT = @typeInfo(T).pointer.child;

    if (@hasField(PtrT, field_name)) {
        return @field(self, field_name);
    }

    unreachable;
}

pub inline fn getPtr(self: anytype, comptime field_name: []const u8) *GetFieldType(@TypeOf(self), field_name) {
    const T = @TypeOf(self);
    const PtrT = @typeInfo(T).pointer.child;

    if (@hasField(PtrT, field_name)) {
        return &@field(self, field_name);
    }

    unreachable;
}

pub inline fn set(self: anytype, comptime field_name: []const u8, value: anytype) void {
    const T = @TypeOf(self);
    const PtrT = @typeInfo(T).pointer.child;

    if (@hasField(PtrT, field_name)) {
        @field(self, field_name) = value;
        return;
    }

    @compileError("Field '" ++ field_name ++ "' not found in class" ++ @typeName(T));
}

inline fn GetMethodReturnType(comptime T: type, comptime name: []const u8) type {
    const PtrT = if (@typeInfo(T) == .pointer) @typeInfo(T).pointer.child else T;

    if (@hasDecl(PtrT, name)) {
        const func = @field(PtrT, name);
        const FnInfo = @typeInfo(@TypeOf(func)).@"fn";
        
        // Return the specific return type of the function
        return FnInfo.return_type.?;
    }

    @compileError("Method '" ++ name ++ "' not found in class " ++ @typeName(T));
}

pub inline fn call(
    self: anytype, 
    comptime method_name: []const u8, 
    args: anytype
) GetMethodReturnType(@TypeOf(self), method_name) {
    const T = @TypeOf(self);
    const PtrT = @typeInfo(T).pointer.child;

    if (@hasDecl(PtrT, method_name)) {
        const func = @field(PtrT, method_name);
        return @call(.auto, func, .{self} ++ args);
    }

    unreachable;
}
