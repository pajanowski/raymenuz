const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const mi = @import("raymenuutils.zig");
const MenuItem = mi.MenuItem;
const ItemDef = mi.ItemDef;
const MenuItemType = mi.MenuItemType;
const MenuItemTypeError = mi.MenuItemTypeError;
const IntMenuItem = mi.IntMenuItem;
const FloatMenuItem = mi.FloatMenuItem;
const StringMenuItem = mi.StringMenuItem;

const Ymlz = @import("ymlz").Ymlz;
const Rectangle = rl.Rectangle;
const Vector2 = rl.Vector2;

pub const RayMenuError = error{
StateFieldNotFound
};

pub fn RayMenu(comptime T: type) type {
    return struct {
        const Self = @This();

        state: *T,
        menuItems: []*mi.MenuItem,
        allocator: std.mem.Allocator,
        filePath: []const u8,

        pub fn init(
            filePath: []const u8,
            state: *T,
            allocator: std.mem.Allocator
        ) Self {

            const menuItems = getMenuItemsFromFile(filePath, state, allocator) catch |err| {
                std.log.err("Failed getting menu items from file {s}: {any}", .{filePath, err});
                return Self{
                    .state = state,
                    .menuItems = &.{},
                    .allocator = allocator,
                    .filePath = filePath
                };
            };
            return Self{
                .state = state,
                .menuItems = menuItems,
                .allocator = allocator,
                .filePath = filePath
            };
        }

        pub fn reloadMenuItems(self: Self) !Self {
            for(self.menuItems) |menuItem| {
                self.allocator.destroy(menuItem);
            }
            self.allocator.free(self.menuItems);

            const menuItems = try getMenuItemsFromFile(self.filePath, self.state, self.allocator);

            return Self{
                .state = self.state,
                .menuItems = menuItems,
                .allocator = self.allocator,
                .filePath = self.filePath
            };

        }

        pub fn draw(self: Self) void {
            for (self.menuItems) |menuItem| {
                switch(menuItem.*) {
                    .float => |active| {
                        drawFloatElements(menuItem, active.valuePtr);
                    },
                    .int => |active| {
                        drawIntElements(menuItem, active.valuePtr);
                    },
                    .string => |active| {
                        drawStringElements(menuItem, active.valuePtr);
                    },
                }
            }
        }

        fn drawFloatElements(menuItem: *mi.MenuItem, valuePtr: anytype) void {
            const menuProperties = menuItem.getMenuProperties();
            switch(menuProperties.elementType.?) {
                .SLIDER => {
                    const range = menuItem.getRange();
                    drawSlideBar(menuProperties, range, valuePtr);
                },
                .LABEL => {
                    drawNumberLabel(menuProperties, valuePtr);
                },
                else => {}
            }
        }

        fn drawIntElements(menuItem: *mi.MenuItem, valuePtr: *i32) void {
            const menuProperties = menuItem.getMenuProperties();
            if (menuProperties.elementType) |elementType| {
                switch(elementType) {
                    .VALUE_BOX => {
                        const range = menuItem.getRange();
                        drawValueBox(menuProperties, range, valuePtr);
                    },
                    .LABEL => {
                        drawNumberLabel(menuProperties, valuePtr);
                    },
                    else => {}
                }
            }
        }

        fn drawStringElements(menuItem: *mi.MenuItem, valuePtr: *[]const u8) void {
            const menuProperties = menuItem.getMenuProperties();
            if (menuProperties.elementType) |elementType| {
                switch(elementType) {
                    .LABEL => {
                        drawStringLabel(menuProperties, valuePtr);
                    },
                    else => {}
                }
            }
        }

        fn formatNumberLabel(buf: []u8, value: anytype) [:0]const u8 {
            return std.fmt.bufPrintZ(buf, "{d:.5}", .{ value }) catch "0";
        }

        fn drawSlideBar(menuProperties: mi.MenuProperties, range: mi.Range, valuePtr: anytype) void {
            var textLabelBuf: [64]u8 = undefined;
            const text = formatNumberLabel(&textLabelBuf, valuePtr.*);
            var nameLabelBuf: [64]u8 = undefined;
            const name = std.fmt.bufPrintZ(&nameLabelBuf, "{s}", .{ menuProperties.name }) catch "";
            _ = rg.label(menuProperties.nameBounds, name);
            _ = rg.sliderBar(menuProperties.bounds, "",text, valuePtr, range.lower, range.upper);
        }

        fn drawValueBox(menuProperties: mi.MenuProperties, range: mi.Range, valuePtr: *i32) void {
            var label_buf: [64]u8 = undefined;
            const name = std.fmt.bufPrintZ(&label_buf, "{s}", .{ menuProperties.name }) catch "";
            _ = rg.label(menuProperties.nameBounds, name);
            _ = rg.valueBox(menuProperties.bounds, "", valuePtr, @intFromFloat(range.lower), @intFromFloat(range.upper), true);
        }

        fn drawStringLabel(menuProperties: mi.MenuProperties, valuePtr: *[]const u8) void {
            var label_buf: [64]u8 = undefined;
            const prefix = menuProperties.name;
            const text = std.fmt.bufPrintZ(&label_buf, "{s} {s}", .{ prefix, valuePtr.* }) catch "";
            _ = rg.label(menuProperties.bounds, text);
        }

        fn drawNumberLabel(menuProperties: mi.MenuProperties, valuePtr: anytype) void {
            var label_buf: [64]u8 = undefined;
            const text = formatNumberLabel(&label_buf, valuePtr.*);
            _ = rg.label(menuProperties.bounds, text);
        }

        pub fn deinit(self: *Self) void {
            for (self.menuItems) |menuItem| {
                menuItem.deinit(self.allocator);
            }
            self.allocator.free(self.menuItems);
        }

        fn getMenuItem(
            itemDef: mi.YamlItemDef,
            bounds: Rectangle,
            nameBounds: Rectangle,
            state: *T,
            allocator: std.mem.Allocator
        ) !*MenuItem {
            const menuItemTypeString = itemDef.menuItemType;
            const statePath = itemDef.statePath;

            const menuItemType = std.meta.stringToEnum(MenuItemType, menuItemTypeString);
            if (menuItemType == null) {
                std.log.err("{s} did not parse to enum", .{menuItemTypeString});
                return MenuItemTypeError.MenuItemTypeUnknown;
            }

            const ret = try allocator.create(MenuItem);
            switch (menuItemType.?) {
                inline .int, .float, .string => |tag| {
                    const itemType = switch (tag) {
                        .int => IntMenuItem,
                        .float => FloatMenuItem,
                        .string => StringMenuItem
                    };
                    const item = try allocator.create(itemType);
                    ret.* = @unionInit(MenuItem, @tagName(tag), item);
                    item.menuProperties = .{
                        .bounds = bounds,
                        .nameBounds = nameBounds,
                        .statePath = try allocator.dupe(u8, statePath),
                        .elementType = std.meta.stringToEnum(mi.UiElementType, itemDef.elementType),
                        .name = try allocator.dupe(u8, itemDef.name),
                    };
                    if (@hasField(itemType, "range")) {
                        item.range = itemDef.range;
                    }
                    const valueType = switch (tag) {
                        .int => i32,
                        .float => f32,
                        .string => []const u8
                    };
                    if(fieldPtrByPathExpect(valueType, state, statePath)) |valuePtr| {
                        item.valuePtr = valuePtr;
                    } else {
                        std.log.err("State path {s} not found or not parseable to {any}", .{statePath, tag});
                        return RayMenuError.StateFieldNotFound;
                    }
                }
            }
            return ret;
        }

        fn buildMenuItems(
            menuDef: mi.YamlMenuDef,
            state: *T,
            allocator: std.mem.Allocator
        ) ![]*MenuItem {
            var ret = std.array_list.Managed(*MenuItem).init(allocator);
            const drawSettings = menuDef.drawSettings;
            var y: f32 = drawSettings.paddingY;
            var menuError: ?anyerror = undefined;
            const itemDefs = menuDef.itemDefs;
            for (itemDefs) |itemDef| {
                var nameBounds = Rectangle{.height = 0, .width = 0, .x = 0, .y = 0};
                if (!std.mem.eql(u8, itemDef.elementType, "LABEL")) {
                    nameBounds = Rectangle{ .width = drawSettings.width, .height = drawSettings.height, .x = drawSettings.startX, .y = y };
                    y = y + drawSettings.nameHeight + drawSettings.namePadding;
                }
                const elementBounds = Rectangle{
                .width = drawSettings.width,
                .height = drawSettings.height,
                .x = drawSettings.startX,
                .y = y
                };
                if(getMenuItem(
                    itemDef,
                    elementBounds,
                    nameBounds,
                    state,
                    allocator
                )) |menuItem| {
                    try ret.append(menuItem);
                } else |err| {
                    menuError = err;
                }
                y = y + drawSettings.height + drawSettings.paddingY;
            }

            return try ret.toOwnedSlice();
        }

        fn getMenuItemsFromFile(
            filePath: []const u8,
            state: *T,
            allocator: std.mem.Allocator
        ) ![]*MenuItem {
            const yml_location = filePath;
            const yml_path = try std.fs.cwd().realpathAlloc(
                allocator,
                yml_location,
            );
            defer allocator.free(yml_path);

            var ymlz = try Ymlz(mi.YamlMenuDef).init(allocator);
            const result = try ymlz.loadFile(yml_path);
            defer ymlz.deinit(result);

            return buildMenuItems(result, state, allocator);
        }
    };
}


pub fn fieldPtrByPathExpect(comptime Leaf: type, root_ptr: anytype, path: []const u8) ?*Leaf {
    // root_ptr must be a pointer to a struct
    const RootPtrT = @TypeOf(root_ptr);
    comptime {
        const info = @typeInfo(RootPtrT);
        switch (info) {
            .pointer => |pinfo| {
                const ChildT = pinfo.child;
                if (@typeInfo(ChildT) != .@"struct") {
                    @compileError("fieldPtrByPathExpect: root_ptr must point to a struct");
                }
            },
            else => @compileError("fieldPtrByPathExpect: root_ptr must be a pointer"),
        }
    }
    return fieldPtrByPathExpectInner(Leaf, @TypeOf(root_ptr.*), root_ptr, path);
}

fn fieldPtrByPathExpectInner(comptime Leaf: type, comptime S: type, base_ptr: *S, path: []const u8) ?*Leaf {
    // Split path into head and tail on first '.'
    const dot_idx = std.mem.indexOfScalar(u8, path, '.');
    const head = if (dot_idx) |i| path[0..i] else path;
    const tail = if (dot_idx) |i| path[i+1..] else path[path.len..path.len];

    // Find the "head" field in S
    inline for (std.meta.fields(S)) |field| {
        if (std.mem.eql(u8, field.name, head)) {
            // Pointer to that field
            const field_ptr = &@field(base_ptr.*, field.name);
            const FieldT = @TypeOf(field_ptr.*);

            if (tail.len == 0) {
                // Last segment — it must match the expected leaf type
                if (FieldT == Leaf) {
                    return @ptrCast(field_ptr);
                } else {
                    return null; // wrong leaf type
                }
            }

            // More segments — continue traversal
            const ti = @typeInfo(FieldT);
            switch (ti) {
                .@"struct" => {
                    // Field is an inline struct, keep pointer to field
                    return fieldPtrByPathExpectInner(Leaf, FieldT, field_ptr, tail);
                },
                .pointer => |pinfo| {
                    const Child = pinfo.child;
                    // Only proceed if the pointee is a struct
                    if (@typeInfo(Child) != .@"struct") return null;
                    // field_ptr: *FieldT (i.e., **Child). Dereference once to get *Child.
                    return fieldPtrByPathExpectInner(Leaf, Child, field_ptr.*, tail);
                },
                else => return null,
            }
        }
    }

    // Field not found
    return null;
}

test "RayMenu struct is correct" {
    const TestState = struct {
        jumper: struct {
            gravity: f32,
            jumpPower: f32,
        },
    };
    var state = TestState{ .jumper = .{ .gravity = 1, .jumpPower = 2 } };
    var devMenu = RayMenu(TestState).init(&state, 100, 200, std.testing.allocator);
    defer devMenu.deinit();
}

const testing = std.testing;

test "Get IntMenuItem and access field" {
    const intValue: i32 = 1234;
    const TestState = struct {
        player: struct {
            score: i32,
        },
    };
    var state = TestState{ .player = .{ .score = 1234 } };
    _ = intValue;

    var itemDef = ItemDef{
        .menuItemType = @constCast("int"),
        .statePath = @constCast("player.score"),
        .elementType = @constCast("SLIDER"),
        .bounds = Rectangle{ .height = 0, .width = 1, .x = 2, .y = 3 },
        .name = @constCast("Score"),
        .range = .{ .lower = 0, .upper = 100 },
    };

    var menuItem = try RayMenu(TestState).GetMenuItem(
        &itemDef,
        Rectangle{ .height = 0, .width = 1, .x = 2, .y = 3 },
        &state,
        std.testing.allocator,
    );
    defer menuItem.deinit(std.testing.allocator);

    // Using the new helper functions
    try testing.expect(menuItem.isInt());
    try testing.expectEqual(MenuItemType.int, menuItem.getType());

    // 1. Using switch to access the active field and its value (Preferred)
    switch (menuItem.*) {
        .int => |intItem| {
            try testing.expectEqual(@as(i32, 1234), intItem.valuePtr.*);
        },
        .float => return error.WrongType,
        .string => return error.WrongType,
        .none => return error.NoItem,
    }
}
