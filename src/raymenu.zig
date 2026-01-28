const std = @import("std");
const mu = @import("menu_utils.zig");
const du = @import("draw_utils.zig");
const rl = @import("raylib");
const rg = @import("raygui");

const MenuItem = du.MenuItem;
const GroupBox = du.GroupBox;

pub const menuUtils = mu;
pub const drawUtils = du;
pub const Slider = du.Slider;
pub const ValueBox = du.ValueBox;
pub const Label = du.Label;
pub const Line = du.Line;
pub const Button = du.Button;
pub const LabelButton = du.LabelButton;
pub const Toggle = du.Toggle;
pub const CheckBox = du.CheckBox;
pub const ComboBox = du.ComboBox;
pub const DropdownBox = du.DropdownBox;
pub const TextBox = du.TextBox;
pub const Spinner = du.Spinner;
pub const SliderBar = du.SliderBar;
pub const ProgressBar = du.ProgressBar;
pub const StatusBar = du.StatusBar;
pub const ToggleGroup = du.ToggleGroup;
pub const ToggleSlider = du.ToggleSlider;
pub const DummyRec = du.DummyRec;
pub const Grid = du.Grid;
pub const DrawSettings = mu.DrawSettings;

const X_INDENT = 5;
pub const RayMenuWindowBuilder = struct {
    const MenuItemListType = std.array_list.Managed(*MenuItem);

    allocator: std.mem.Allocator,
    window: du.Window,
    menuItems: MenuItemListType,
    z0Items: MenuItemListType,
    boundsCalc: du.BoundsCalculator,
    x: f32 = 0,
    maxWidth: f32 = 0, // running maxWidth
    drawSettings: mu.DrawSettings = mu.DrawSettings{
        .paddingY = 5,
        .startX = 5,
        .width = 75,
        .height = 10,
        .nameHeight = 10,
        .namePadding = 0
    },
    groupBoxStack: MenuItemListType,

    const Self = @This();

    pub fn init(title: []const u8,
        drawSettings: mu.DrawSettings,
        allocator: std.mem.Allocator) Self {
        return Self{
            .menuItems = MenuItemListType.init(allocator),
            .z0Items = MenuItemListType.init(allocator),
            .allocator = allocator,
            .window = du.Window{
                .title = title,
                .drawContent = RayMenu.drawContentCallback,
                .contentSize = undefined
            },
            .groupBoxStack = MenuItemListType.init(allocator),
            .boundsCalc = du.BoundsCalculator.init(drawSettings),
            .drawSettings = drawSettings,
        };
    }
    
    pub fn startGroup(self: *Self, name: [:0]const u8) !void {
        const menuItem = try self.allocator.create(MenuItem);
        self.x = self.x + X_INDENT;
        self.boundsCalc.padY();
        const currentY = self.boundsCalc.getY();
        menuItem.* = @unionInit(MenuItem, @tagName(mu.UiElementType.GROUP_BOX), GroupBox{
            .props = du.CommonItemProps{
                .name = name,
                .itemBounds = rl.Rectangle{
                    .x = self.x,
                    .y = currentY,
                    .width = (self.drawSettings.startX + self.drawSettings.width + self.drawSettings.startX) * 2 - 2 * self.x,
                    .height = -1,
                }
            }
        });
        self.boundsCalc.padY();
        try self.groupBoxStack.append(menuItem);
    }

    pub fn endGroup(self: *Self) !void {
        const groupBox = self.groupBoxStack.pop();
        self.boundsCalc.padY();
        if (groupBox) |unwrapped| {
            const currentY = self.boundsCalc.getY();
            unwrapped.GROUP_BOX.props.itemBounds.height = currentY - unwrapped.GROUP_BOX.props.itemBounds.y;
            self.boundsCalc.padY();
            self.x = self.x - X_INDENT;
            try self.z0Items.append(unwrapped);
        } else {
            @panic("Attempted to end a group when never started");
        }
    }

    pub fn addMenuItem(self: *Self, menuItem: MenuItem) !void {
        var needsLabel = true;
        switch (menuItem) {
            .LABEL => needsLabel = false,
            .LINE => needsLabel = false,
            .BUTTON => needsLabel = false,
            .LABEL_BUTTON => needsLabel = false,
            .CHECK_BOX => needsLabel = false,
            .STATUS_BAR => needsLabel = false,
            .DUMMY_REC => needsLabel = false,
            .GRID => needsLabel = false,
            else => {}
        }

        const ret = try self.allocator.create(MenuItem);
        ret.* = menuItem;

        switch (ret.*) {
            .BUTTON => |*item| {
                self.boundsCalc.padY();
                item.props.name = try self.allocator.dupeZ(u8, item.props.name);
                item.props.itemBounds = self.boundsCalc.getItemBoundsWithHeight(self.x, self.drawSettings.buttonHeight);
                self.boundsCalc.advanceYBy(self.drawSettings.buttonHeight);
                self.boundsCalc.padY();
            },
            .CHECK_BOX => |*item| {
                self.boundsCalc.padY();
                item.props.name = try self.allocator.dupeZ(u8, item.props.name);
                item.props.itemBounds = self.boundsCalc.getSquareItemBounds(self.x, self.drawSettings.checkboxSize);
                self.boundsCalc.advanceYBy(self.drawSettings.checkboxSize);
                self.boundsCalc.padY();
            },
            .DROPDOWN_BOX => |*item| {
                self.boundsCalc.padY();
                item.props.nameBounds = self.boundsCalc.getNameBounds(self.x, needsLabel);
                item.props.name = try self.allocator.dupeZ(u8, item.props.name);
                item.props.itemBounds = self.boundsCalc.getItemBoundsWithHeight(self.x, self.drawSettings.height);
                self.boundsCalc.advanceYBy(self.drawSettings.height);
                self.boundsCalc.padY();
            },
            .TOGGLE_GROUP => |*item| {
                self.boundsCalc.padY();
                item.props.nameBounds = self.boundsCalc.getNameBounds(self.x, needsLabel);
                item.props.name = try self.allocator.dupeZ(u8, item.props.name);
                item.props.itemBounds = self.boundsCalc.getItemBoundsPro(self.x, self.drawSettings.height, self.drawSettings.toggleGroupButtonWidth);
                self.boundsCalc.advanceYBy(self.drawSettings.height);
                self.boundsCalc.padY();
            },
            inline else => |*item| {
                item.props.nameBounds = self.boundsCalc.getNameBounds(self.x, needsLabel);
                item.props.name = try self.allocator.dupeZ(u8, item.props.name);
                item.props.itemBounds = self.boundsCalc.getItemBounds(self.x);
                self.maxWidth = @max(self.drawSettings.width, self.maxWidth);
                self.boundsCalc.advanceY();
                self.boundsCalc.padY();
            },
        }

        try self.menuItems.append(ret);
    }

    pub fn build(self: *Self) !du.Window {
        const contentSize = rl.Vector2{
            .x = (self.drawSettings.startX + self.drawSettings.width + self.drawSettings.startX) * 2,
            .y = self.boundsCalc.getY() - self.boundsCalc.lastAdvancedAmount
        };
        const size = rl.Vector2{
            .x = @min(contentSize.x + 16, @as(f32, @floatFromInt(rl.getScreenWidth()))),
            .y = @min(contentSize.y + du.WINDOW_STATUS_BAR_HEIGHT + 8, @as(f32, @floatFromInt(rl.getScreenHeight())))
        };

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

    const WindowToCollisionType = std.AutoHashMap(u32, std.array_list.Managed(*rl.Rectangle));

    allocator: std.mem.Allocator,
    windows: std.array_list.Managed(*du.Window),
    // a map to track the rects of a window that might be convering up
    windowToCollisions: WindowToCollisionType,
    nextWindowId: u32 = 1,
    nextWindowStart: rl.Vector2 = rl.Vector2{
        .x = du.WINDOW_STATUS_BAR_HEIGHT,
        .y = du.WINDOW_STATUS_BAR_HEIGHT
    },

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self {
            .allocator = allocator,
            .windows = std.array_list.Managed(*du.Window).init(allocator),
            .windowToCollisions = WindowToCollisionType.init(allocator)
        };
    }

    pub fn build(self: *Self) void {
        self.windows.getLast().enabled = true;
    }

    pub fn addWindow(self: *Self, window: *du.Window) !void {
        window.id = self.nextWindowId;
        window.position = self.nextWindowStart;
        self.nextWindowStart.y += du.WINDOW_STATUS_BAR_HEIGHT;
        self.nextWindowStart.x += du.WINDOW_STATUS_BAR_HEIGHT;
        try self.windowToCollisions.put(window.id, std.array_list.Managed(*rl.Rectangle).init(self.allocator));
        self.nextWindowId += 1;
        try self.windows.append(window);
    }

    fn updateCollisionRecs(self: *Self) !void {
        var i: isize = @as(isize, @intCast(self.windows.items.len - 1));
        while (i >= 0): (i-= 1) {
            const above = self.windows.items[@intCast(i)];

            const aboveRec = sizeAndPosToRect(above.size, above.position);

            var j: isize = i - 1;
            while(j >= 0) : (j -= 1) {
                const below = self.windows.items[@intCast(j)];
                // if (below.dirty) {
                    const belowRec = sizeAndPosToRect(below.size, below.position);
                    var it = self.windowToCollisions.valueIterator();
                    while (it.next()) |recs| {
                        for (recs.items) |rec| {
                            self.allocator.destroy(rec);
                        }
                        recs.clearRetainingCapacity();
                    }
                    if (rl.checkCollisionRecs(aboveRec, belowRec)) {
                        const ret = try self.allocator.create(rl.Rectangle);
                        ret.* = rl.getCollisionRec(aboveRec, belowRec);
                        try self.windowToCollisions.getPtr(below.id).?.append(ret);
                    }
                // }
                // below.dirty = false;
            }
            // above.dirty = false;
        }

    }

    inline fn sizeAndPosToRect(size: rl.Vector2, pos: rl.Vector2) rl.Rectangle {
       return rl.Rectangle{.x = pos.x, .y = pos.y, .height = size.y, .width = size.x};
    }

    pub fn updateFocus(self: *Self) !void {
        const mousePos = rl.getMousePosition();

        var focusedWindowIndex: usize = self.windows.items.len - 1;
        for (self.windows.items, 0..) |window, index| {
            window.enabled = false;
            if (rl.isMouseButtonReleased(rl.MouseButton.left) and rl.checkCollisionPointRec(mousePos, sizeAndPosToRect(window.size, window.position))) {
                const coveredParts = self.windowToCollisions.getPtr(window.id).?;
                var isFocused = true;
                for (coveredParts.items) |covered| {
                    if (rl.checkCollisionPointRec(mousePos, covered.*)) {
                        isFocused = false;
                    }
                }
                if (isFocused) {
                    focusedWindowIndex = index;
                }
            }
        }
        const focused = self.windows.orderedRemove(focusedWindowIndex);
        focused.enabled = true;
        try self.windows.append(focused);
    }

    pub fn draw(self: *Self) void {
        self.updateCollisionRecs() catch |err| {
            std.log.err("Failed to update collision recs {any}", .{err});
            @panic("failed updating collsionRecs");
        };
        self.updateFocus() catch |err| {
            std.log.err("Failed to update focus {any}", .{err});
            @panic("failed updating collsionRecs");
        };
        for (self.windows.items) |window| {
            du.floatingWindow(window);
        }
        // var it = self.windowToCollisions.valueIterator();
        // while(it.next()) |collisionArrays| {
            // for (collisionArrays.items) |collision| {
                // rl.drawRectangleRec(collision.*, rl.Color.red);
            // }
        // }
    }

    fn drawZ1Elements(window: *du.Window) void {
        const position = window.position;
        const scroll = window.scroll;

        for (window.menuItems) |menuItem| {
            switch(menuItem.*) {
                .SLIDER => |active| {
                    du.drawSlider(&active, position, scroll);
                },
                .VALUE_BOX => |active| {
                    du.drawValueBoxElement(&active, position, scroll);
                },
                .LABEL => |active| {
                    du.drawLabelElement(&active, position, scroll);
                },
                .LINE => |active| {
                    du.drawLine(&active, position, scroll);
                },
                .BUTTON => |active| {
                    du.drawButton(&active, position, scroll);
                },
                .LABEL_BUTTON => |active| {
                    du.drawLabelButton(&active, position, scroll);
                },
                .TOGGLE => |active| {
                    du.drawToggle(&active, position, scroll);
                },
                .CHECK_BOX => |active| {
                    du.drawCheckBox(&active, position, scroll);
                },
                .COMBO_BOX => |active| {
                    du.drawComboBox(&active, position, scroll);
                },

                .TEXT_BOX => |active| {
                    du.drawTextBox(&active, position, scroll);
                },
                .SPINNER => |active| {
                    du.drawSpinner(&active, position, scroll);
                },
                .SLIDER_BAR => |active| {
                    du.drawSliderBarElement(&active, position, scroll);
                },
                .PROGRESS_BAR => |active| {
                    du.drawProgressBar(&active, position, scroll);
                },
                .STATUS_BAR => |active| {
                    du.drawStatusBar(&active, position, scroll);
                },
                .TOGGLE_GROUP => |active| {
                    du.drawToggleGroup(&active, position, scroll);
                },
                .TOGGLE_SLIDER => |active| {
                    du.drawToggleSlider(&active, position, scroll);
                },
                .DUMMY_REC => |active| {
                    du.drawDummyRec(&active, position, scroll);
                },
                .GRID => |active| {
                    du.drawGrid(&active, position, scroll);
                },
                else => {}
            }
        }
    }

    fn drawZ100Elements(window: *du.Window) void {
        const position = window.position;
        const scroll = window.scroll;

        for (window.menuItems) |item| {
            switch(item.*) {
                .DROPDOWN_BOX => |active| {
                    du.drawDropdownBox(&active, position, scroll);
                },
                else => {}
            }
        }

    }

    fn drawZ0Elements(window: *du.Window) void {
        const position = window.position;
        const scroll = window.scroll;

        const n = window.z0Items.len;

        for(0..n) |reverse_i| {
            const i = n - 1 - reverse_i;
            const item = window.z0Items[i];
            switch(item.*) {
                .GROUP_BOX => |active| {
                    du.drawGroupBox(&active, position, scroll);
                },
                else => @panic("An unsupported menuItem type made it into z0items")
            }
        }
    }

    fn drawContentCallback(window: *du.Window) void {
        drawZ0Elements(window);
        drawZ1Elements(window);
        drawZ100Elements(window);
    }
};