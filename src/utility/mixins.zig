inline fn GetFieldType(comptime T: type, comptime name: []const u8) type {
    const PtrT = if (@typeInfo(T) == .pointer) @typeInfo(T).pointer.child else T;

    if (@hasField(PtrT, name)) {
        return @TypeOf(@field(@as(PtrT, undefined), name));
    }

    // Match your struct's field name: "base"
    if (@hasField(PtrT, "base")) {
        const BaseType = @TypeOf(@field(@as(PtrT, undefined), "base"));
        return GetFieldType(BaseType, name);
    }

    @compileError("Field '" ++ name ++ "' not found.");
}

pub inline fn recGet(self: anytype, comptime field_name: []const u8) GetFieldType(@TypeOf(self), field_name) {
    const T = @TypeOf(self);
    const PtrT = @typeInfo(T).pointer.child;

    if (@hasField(PtrT, field_name)) {
        return @field(self, field_name);
    }

    if (@hasField(PtrT, "base")) {
        return recGet(self.base, field_name);
    }

    unreachable;
}

pub inline fn recGetPtr(self: anytype, comptime field_name: []const u8) *GetFieldType(@TypeOf(self), field_name) {
    const T = @TypeOf(self);
    const PtrT = @typeInfo(T).pointer.child;

    if (@hasField(PtrT, field_name)) {
        return &@field(self, field_name);
    }

    if (@hasField(PtrT, "base")) {
        return recGetPtr(&self.base, field_name);
    }

    unreachable;
}

pub inline fn get(self: anytype, comptime field_name: []const u8) GetFieldType(@TypeOf(self), field_name) {
    return @field(self, field_name);
}

pub inline fn getPtr(self: anytype, comptime field_name: []const u8) *GetFieldType(@TypeOf(self), field_name) {
    return &@field(self, field_name);
}

pub inline fn set(self: anytype, comptime field_name: []const u8, value: anytype) void {
    @field(self, field_name) = value;
}

pub inline fn call(
    self: anytype, 
    comptime method_name: []const u8, 
    args: anytype
) GetMethodReturnType(@TypeOf(self), method_name) {
    const func = @field(@TypeOf(self), method_name);
    return @call(.auto, func, .{self} ++ args);
}

pub inline fn recSet(self: anytype, comptime field_name: []const u8, value: anytype) void {
    const T = @TypeOf(self);
    const PtrT = @typeInfo(T).pointer.child;

    if (@hasField(PtrT, field_name)) {
        @field(self, field_name) = value;
        return;
    }

    if (@hasField(PtrT, "base_class")) {
        return recSet(&self.base, field_name, value);
    }

    @compileError("Field '" ++ field_name ++ "' not found in hierarchy.");
}

inline fn GetMethodReturnType(comptime T: type, comptime name: []const u8) type {
    const PtrT = if (@typeInfo(T) == .pointer) @typeInfo(T).pointer.child else T;

    if (@hasDecl(PtrT, name)) {
        const func = @field(PtrT, name);
        const FnInfo = @typeInfo(@TypeOf(func)).@"fn";
        
        // Return the specific return type of the function
        return FnInfo.return_type.?;
    }

    if (@hasField(PtrT, "base")) {
        const BaseType = @TypeOf(@field(@as(PtrT, undefined), "base"));
        return GetMethodReturnType(BaseType, name);
    }

    @compileError("Method '" ++ name ++ "' not found.");
}

pub inline fn recCall(
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

    if (@hasField(PtrT, "base")) {
        // Recurse into base. Use & if base is a struct, or just self.base if it's already a ptr
        return recCall(&self.base, method_name, args);
    }

    unreachable;
}