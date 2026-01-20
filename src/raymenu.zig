const std = @import("std");
const mu = @import("menu_utils.zig");
const du = @import("draw_utils.zig");
const rl = @import("raylib");
const rg = @import("raygui");

const MenuItem = du.MenuItem;

pub const Slider = du.Slider;
pub const ValueBox = du.ValueBox;
pub const Label = du.Label;
pub const Line = du.Line;
pub const Button = du.Button;

const GroupBox = du.GroupBox;

const X_INDENT = 5;
pub const RayMenuWindowBuilder = struct {
    const MenuItemListType = std.array_list.Managed(*MenuItem);

    allocator: std.mem.Allocator,
    window: du.Window,
    menuItems: MenuItemListType,
    z0Items: MenuItemListType,
    y: f32 = du.WINDOW_STATUS_BAR_HEIGHT + 4, // running y total
    x: f32 = 0,
    maxWidth: f32 = 0, // running maxWidth
    drawSettings: mu.DrawSettings = mu.DrawSettings{
        .paddingY = 0,
        .startX = 5,
        .width = 75,
        .height = 10,
        .nameHeight = 10,
        .namePadding = 0
    },
    groupBoxStack: MenuItemListType,

    const Self = @This();

    pub fn init(title: []const u8, allocator: std.mem.Allocator) Self {
       return Self{
           .menuItems = MenuItemListType.init(allocator),
           .z0Items = MenuItemListType.init(allocator),
           .allocator = allocator,
           .window = du.Window{
               .title = title,
               .drawContent = RayMenu.drawContentCallback,
               .contentSize = undefined
           },
           .groupBoxStack = MenuItemListType.init(allocator)
       };
    }
    
    pub fn startGroup(self: *Self, name: [:0]const u8) !void {
        // const drawSettings = self.drawSettings;
        const menuItem = try self.allocator.create(MenuItem);
        self.x = self.x + X_INDENT;
        self.y = self.y + 5;
        menuItem.* = @unionInit(MenuItem, @tagName(mu.UiElementType.GROUP_BOX), GroupBox{
            .props = du.CommonItemProps{
                .name = name,
                .itemBounds = rl.Rectangle{
                    .x = self.x,
                    .y = self.y,
                    .width = (self.drawSettings.startX + self.drawSettings.width + self.drawSettings.startX) * 2 - 2 * self.x,
                    .height = -1,
                }
            }
        });
        self.y = self.y + 5;
        try self.groupBoxStack.append(menuItem);
    }

    pub fn endGroup(self: *Self) !void {
        const groupBox = self.groupBoxStack.pop();
        if (groupBox) |unwrapped| {
            unwrapped.GROUP_BOX.props.itemBounds.height = self.y - unwrapped.GROUP_BOX.props.itemBounds.y;
            self.y = self.y + self.drawSettings.height + self.drawSettings.paddingY;
            self.x = self.x - X_INDENT;
            try self.z0Items.append(unwrapped);
        } else {
            @panic("Attempted to end a group when never started");
        }
    }

    pub fn addMenuItem(self: *Self, menuItem: MenuItem) !void {
        const drawSettings = self.drawSettings;
        var needsLabel = true;
        switch (menuItem) {
            .LABEL => needsLabel = false,
            .LINE => needsLabel = false,
            .BUTTON => needsLabel = false,
            else => {}
        }

        const ret = try self.allocator.create(MenuItem);
        ret.* = menuItem;

        switch (ret.*) {
            .BUTTON => |*item| {
                item.props.name = try self.allocator.dupeZ(u8, item.props.name);
                item.props.itemBounds.height = 20;
                item.props.itemBounds.width = drawSettings.width;
                item.props.itemBounds.x = drawSettings.startX + self.x;
                item.props.itemBounds.y = self.y;
            },
            inline else => |*item| {
                if (needsLabel) {
                    item.props.nameBounds = rl.Rectangle{
                        .width = drawSettings.width,
                        .height = drawSettings.nameHeight,
                        .x = drawSettings.startX + self.x,
                        .y = self.y
                    };
                    self.y = self.y + drawSettings.nameHeight + drawSettings.namePadding;
                }

                item.props.name = try self.allocator.dupeZ(u8, item.props.name);
                item.props.itemBounds.height = drawSettings.height;
                item.props.itemBounds.width = drawSettings.width;
                item.props.itemBounds.x = drawSettings.startX + self.x;
                item.props.itemBounds.y = self.y;
                self.y = self.y + drawSettings.height + drawSettings.paddingY;
            },
        }

        // const currentWidth = drawSettings.startX + drawSettings.width;
        // if (currentWidth > self.maxWidth) self.maxWidth = currentWidth;
        self.y = self.y + drawSettings.height + drawSettings.paddingY;
        try self.menuItems.append(ret);
    }

    fn getEndOfConent(self: *Self) f32 {
        var maxYz0Items: f32 = 0;
        switch (self.z0Items.getLast().*) {
            inline else => |*active| {
                maxYz0Items = active.props.itemBounds.y + active.props.itemBounds.height;
            }
        }
        var maxYMenuItem: f32 = 0;
        switch (self.menuItems.getLast().*) {
            inline else => |*active| {
                maxYMenuItem = active.props.itemBounds.y + active.props.itemBounds.height;
            }
        }
        return @as(f32, @max(maxYMenuItem, maxYz0Items));
    }
    pub fn build(self: *Self) !du.Window {
        const contentSize = rl.Vector2{ .x = (self.drawSettings.startX + self.drawSettings.width + self.drawSettings.startX) * 2, .y = self.getEndOfConent() };
        const size = rl.Vector2{ .x = contentSize.x + 16, .y = contentSize.y + du.WINDOW_STATUS_BAR_HEIGHT + 8};

        self.window.contentSize = contentSize;
        self.window.size = size;
        self.window.position = rl.Vector2{.x = 2, .y = 2};
        self.window.scroll = rl.Vector2{.x = 0, .y = 0};
        self.window.menuItems = try self.menuItems.toOwnedSlice();
        self.window.z0Items = try self.z0Items.toOwnedSlice();
        return self.window;
    }
};

pub const RayMenu = struct {

    allocator: std.mem.Allocator,
    windows: std.array_list.Managed(*du.Window),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self {
            .allocator = allocator,
            .windows = std.array_list.Managed(*du.Window).init(allocator)
        };
    }

    pub fn addWindow(self: *Self, window: *du.Window) !void {
       try self.windows.append(window);
    }

    pub fn draw(self: *Self) void {
        for (self.windows.items) |window| {
            du.floatingWindow(window);
        }
    }

    fn drawContentCallback(window: *du.Window) void {
        const position = window.position;
        const scroll = window.scroll;

        const n = window.z0Items.len;
        for(0..n) |reverse_i| {
            const i = n - 1 - reverse_i;
            const item = window.z0Items[i];
            switch(item.*) {
                .GROUP_BOX => |active| {
                    // std.debug.print("groupBox {any}", .{active});
                    _ = rg.groupBox(du.offsetRect(active.props.itemBounds, position, scroll), active.props.name);
                },
                else => @panic("An unsupported menuItem type made it into z0items")
            }
        }


        for (window.menuItems) |menuItem| {
            switch(menuItem.*) {
                .SLIDER => |active| {
                    _ = rg.label(du.offsetRect(active.props.nameBounds, position, scroll), active.props.name);
                    var buf: [64:0]u8 = undefined;
                    const valueText = du.formatNumberLabel(&buf, active.valuePtr.*);
                    _ = rg.slider(du.offsetRect(active.props.itemBounds, position, scroll), "", valueText, active.valuePtr, active.range.lower, active.range.upper);
                },
                .VALUE_BOX => |_| {
                    std.debug.print("draw value\n", .{});
                },
                .LABEL => |_| {
                    std.debug.print("draw label\n", .{});
                },
                .LINE => |active| {
                    _ = rg.line(du.offsetRect(active.props.itemBounds, position, scroll), active.props.name);
                },
                .BUTTON => |active| {
                    if (rg.button(du.offsetRect(active.props.itemBounds, position, scroll), active.props.name)) {
                        active.buttonFn();
                    }
                },
                else => unreachable
            }
        }
    }
};