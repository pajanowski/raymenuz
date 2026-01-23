const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const mu = @import("menu_utils.zig");

pub const MenuItem = union(mu.UiElementType) {
    SLIDER: Slider,
    VALUE_BOX: ValueBox,
    LABEL: Label,
    LINE: Line,
    GROUP_BOX: GroupBox,
    BUTTON: Button,
    LABEL_BUTTON: LabelButton,
    TOGGLE: Toggle,
    TOGGLE_GROUP: ToggleGroup,
    TOGGLE_SLIDER: ToggleSlider,
    CHECK_BOX: CheckBox,
    COMBO_BOX: ComboBox,
    DROPDOWN_BOX: DropdownBox,
    TEXT_BOX: TextBox,
    SPINNER: Spinner,
    SLIDER_BAR: SliderBar,
    PROGRESS_BAR: ProgressBar,
    STATUS_BAR: StatusBar,
    DUMMY_REC: DummyRec,
    GRID: Grid
};

pub const CommonItemProps = struct {
    itemBounds: rl.Rectangle = undefined,
    nameBounds: rl.Rectangle = undefined,
    name: [:0]const u8,
};

pub const Slider = struct {
    props: CommonItemProps,
    range: mu.Range,
    valuePtr: *f32,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        range: mu.Range,
        valuePtr: *f32
    ) MenuItem {
        return MenuItem{
            .SLIDER = Slider{
                .props = CommonItemProps{
                    .name = name
                },
                .range = range,
                .valuePtr = valuePtr
            }
        };
    }
};

pub const ValueBox = struct {
    props: CommonItemProps,
    range: mu.Range,
    valuePtr: *i32,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        range: mu.Range,
        valuePtr: *i32
    ) MenuItem {
        return MenuItem{
            .VALUE_BOX = ValueBox{
                .props = CommonItemProps{
                    .name = name
                },
                .range = range,
                .valuePtr = valuePtr
            }
        };
    }
};

pub const Label = struct {
    props: CommonItemProps,
    valuePtr: *i32,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        valuePtr: *i32
    ) MenuItem {
        return MenuItem{
            .LABEL = Label{
                .props = CommonItemProps{
                    .name = name
                },
                .valuePtr = valuePtr
            }
        };
    }
};

pub const Line = struct {
    props: CommonItemProps,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
    ) MenuItem {
        return MenuItem{
            .LINE = Line{
                .props = CommonItemProps{
                    .name = name
                }
            }
        };
    }
};

const ButtonFn = *const fn() void;

pub const Button = struct {
    props: CommonItemProps,
    buttonFn: ButtonFn,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        buttonFn: ButtonFn
    ) MenuItem {
        return MenuItem{
            .BUTTON = Button{
                .props = CommonItemProps{
                    .name = name
                },
                .buttonFn = buttonFn
            }
        };
    }
};

pub const GroupBox = struct {
    props: CommonItemProps,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
    ) GroupBox {
        return MenuItem{
            .GROUP_BOX = GroupBox{
                .props = CommonItemProps{
                    .name = name
                }
            }
        };
    }
};

pub const LabelButton = struct {
    props: CommonItemProps,
    buttonFn: ButtonFn,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        buttonFn: ButtonFn
    ) MenuItem {
        return MenuItem{
            .LABEL_BUTTON = LabelButton{
                .props = CommonItemProps{
                    .name = name
                },
                .buttonFn = buttonFn
            }
        };
    }
};

pub const Toggle = struct {
    props: CommonItemProps,
    activePtr: *bool,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        activePtr: *bool
    ) MenuItem {
        return MenuItem{
            .TOGGLE = Toggle{
                .props = CommonItemProps{
                    .name = name
                },
                .activePtr = activePtr
            }
        };
    }
};

pub const CheckBox = struct {
    props: CommonItemProps,
    checkedPtr: *bool,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        checkedPtr: *bool
    ) MenuItem {
        return MenuItem{
            .CHECK_BOX = CheckBox{
                .props = CommonItemProps{
                    .name = name
                },
                .checkedPtr = checkedPtr
            }
        };
    }
};

pub const ComboBox = struct {
    props: CommonItemProps,
    activePtr: *i32,
    items: [:0]const u8, // semicolon-separated items

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        items: [:0]const u8,
        activePtr: *i32
    ) MenuItem {
        return MenuItem{
            .COMBO_BOX = ComboBox{
                .props = CommonItemProps{
                    .name = name
                },
                .items = items,
                .activePtr = activePtr
            }
        };
    }
};

pub const DropdownBox = struct {
    props: CommonItemProps,
    activePtr: *i32,
    items: [:0]const u8, // semicolon-separated items
    editModePtr: *bool,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        items: [:0]const u8,
        activePtr: *i32,
        editModePtr: *bool
    ) MenuItem {
        return MenuItem{
            .DROPDOWN_BOX = DropdownBox{
                .props = CommonItemProps{
                    .name = name
                },
                .items = items,
                .activePtr = activePtr,
                .editModePtr = editModePtr
            }
        };
    }
};

pub const TextBox = struct {
    props: CommonItemProps,
    textPtr: [:0]u8,
    textSize: i32,
    editModePtr: *bool,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        textPtr: [:0]u8,
        textSize: i32,
        editModePtr: *bool
    ) MenuItem {
        return MenuItem{
            .TEXT_BOX = TextBox{
                .props = CommonItemProps{
                    .name = name
                },
                .textPtr = textPtr,
                .textSize = textSize,
                .editModePtr = editModePtr
            }
        };
    }
};

pub const Spinner = struct {
    props: CommonItemProps,
    valuePtr: *i32,
    range: mu.Range,
    editModePtr: *bool,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        range: mu.Range,
        valuePtr: *i32,
        editModePtr: *bool
    ) MenuItem {
        return MenuItem{
            .SPINNER = Spinner{
                .props = CommonItemProps{
                    .name = name
                },
                .range = range,
                .valuePtr = valuePtr,
                .editModePtr = editModePtr
            }
        };
    }
};

pub const SliderBar = struct {
    props: CommonItemProps,
    range: mu.Range,
    valuePtr: *f32,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        range: mu.Range,
        valuePtr: *f32
    ) MenuItem {
        return MenuItem{
            .SLIDER_BAR = SliderBar{
                .props = CommonItemProps{
                    .name = name
                },
                .range = range,
                .valuePtr = valuePtr
            }
        };
    }
};

pub const ProgressBar = struct {
    props: CommonItemProps,
    valuePtr: *f32,
    range: mu.Range,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        range: mu.Range,
        valuePtr: *f32
    ) MenuItem {
        return MenuItem{
            .PROGRESS_BAR = ProgressBar{
                .props = CommonItemProps{
                    .name = name
                },
                .range = range,
                .valuePtr = valuePtr
            }
        };
    }
};

pub const StatusBar = struct {
    props: CommonItemProps,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
    ) MenuItem {
        return MenuItem{
            .STATUS_BAR = StatusBar{
                .props = CommonItemProps{
                    .name = name
                }
            }
        };
    }
};

pub const ToggleGroup = struct {
    props: CommonItemProps,
    activePtr: *i32,
    items: [:0]const u8, // semicolon-separated items

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        items: [:0]const u8,
        activePtr: *i32
    ) MenuItem {
        return MenuItem{
            .TOGGLE_GROUP = ToggleGroup{
                .props = CommonItemProps{
                    .name = name
                },
                .items = items,
                .activePtr = activePtr
            }
        };
    }
};

pub const ToggleSlider = struct {
    props: CommonItemProps,
    activePtr: *i32,
    items: [:0]const u8, // semicolon-separated items

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        items: [:0]const u8,
        activePtr: *i32
    ) MenuItem {
        return MenuItem{
            .TOGGLE_SLIDER = ToggleSlider{
                .props = CommonItemProps{
                    .name = name
                },
                .items = items,
                .activePtr = activePtr
            }
        };
    }
};

pub const DummyRec = struct {
    props: CommonItemProps,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
    ) MenuItem {
        return MenuItem{
            .DUMMY_REC = DummyRec{
                .props = CommonItemProps{
                    .name = name
                }
            }
        };
    }
};

pub const Grid = struct {
    props: CommonItemProps,
    spacing: f32,
    subdivs: i32,
    mouseCellPtr: *rl.Vector2,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        spacing: f32,
        subdivs: i32,
        mouseCellPtr: *rl.Vector2
    ) MenuItem {
        return MenuItem{
            .GRID = Grid{
                .props = CommonItemProps{
                    .name = name
                },
                .spacing = spacing,
                .subdivs = subdivs,
                .mouseCellPtr = mouseCellPtr
            }
        };
    }
};
pub fn drawFloatElements(menuItem: *mu.MenuItem, valuePtr: anytype, position: rl.Vector2, scroll: rl.Vector2, disable: bool) void {
    const menuProperties = menuItem.getMenuProperties();
    switch(menuProperties.elementType.?) {
        .SLIDER => {
            const range = menuItem.getRange();
            drawSlideBar(menuProperties, range, valuePtr, position, scroll, disable);
        },
        .LABEL => {
            drawNumberLabel(menuProperties, valuePtr, position, scroll);
        },
        else => {}
    }
}

pub fn drawIntElements(menuItem: *mu.MenuItem, valuePtr: *i32, position: rl.Vector2, scroll: rl.Vector2) void {
    const menuProperties = menuItem.getMenuProperties();
    if (menuProperties.elementType) |elementType| {
        switch(elementType) {
            .VALUE_BOX => {
                const range = menuItem.getRange();
                drawValueBox(menuProperties, range, valuePtr, position, scroll);
            },
            .LABEL => {
                drawNumberLabel(menuProperties, valuePtr, position, scroll);
            },
            else => {}
        }
    }
}

pub fn drawStringElements(menuItem: *mu.MenuItem, valuePtr: *[]const u8, position: rl.Vector2, scroll: rl.Vector2) void {
    const menuProperties = menuItem.getMenuProperties();
    if (menuProperties.elementType) |elementType| {
        switch(elementType) {
            .LABEL => {
                drawStringLabel(menuProperties, valuePtr, position, scroll);
            },
            else => {}
        }
    }
}

pub fn formatNumberLabel(buf: []u8, value: anytype) [:0]const u8 {
    return std.fmt.bufPrintZ(buf, "{d:.5}", .{ value }) catch "0";
}

pub fn offsetRect(rect: rl.Rectangle, position: rl.Vector2, scroll: rl.Vector2) rl.Rectangle {
    // Clamp values to prevent float-to-int overflow in raygui
    const max_coord: f32 = 2000000000.0; // Safe value well below i32 max
    const min_coord: f32 = -2000000000.0;

    const x = @min(@max(rect.x + position.x + scroll.x, min_coord), max_coord);
    const y = @min(@max(rect.y + position.y + scroll.y, min_coord), max_coord);

    return rl.Rectangle {
        .x = x,
        .y = y,
        .width = rect.width,
        .height = rect.height
    };
}

pub fn drawSlideBar(menuProperties: mu.MenuProperties, range: mu.Range, valuePtr: anytype, position: rl.Vector2, scroll: rl.Vector2, disable: bool) void {
    const predrawValue: f32 = valuePtr.*;
    var textLabelBuf: [64]u8 = undefined;
    const text = formatNumberLabel(&textLabelBuf, valuePtr.*);
    var nameLabelBuf: [64]u8 = undefined;
    const name = std.fmt.bufPrintZ(&nameLabelBuf, "{s}", .{ menuProperties.name }) catch "";
    _ = rg.label(offsetRect(menuProperties.nameBounds, position, scroll), name);
    _ = rg.sliderBar(offsetRect(menuProperties.bounds, position, scroll), "", text, valuePtr, range.lower, range.upper);
    if (disable) {
        valuePtr.* = predrawValue;
    }
}

pub fn drawValueBox(menuProperties: mu.MenuProperties, range: mu.Range, valuePtr: *i32, position: rl.Vector2, scroll: rl.Vector2) void {
    var label_buf: [64]u8 = undefined;
    const name = std.fmt.bufPrintZ(&label_buf, "{s}", .{ menuProperties.name }) catch "";
    _ = rg.label(offsetRect(menuProperties.nameBounds, position, scroll), name);
    _ = rg.valueBox(offsetRect(menuProperties.bounds, position, scroll), "", valuePtr, @intFromFloat(range.lower), @intFromFloat(range.upper), true);
}

pub fn drawStringLabel(menuProperties: mu.MenuProperties, valuePtr: *[]const u8, position: rl.Vector2, scroll: rl.Vector2) void {
    var label_buf: [64]u8 = undefined;
    const prefix = menuProperties.name;
    const text = std.fmt.bufPrintZ(&label_buf, "{s} {s}", .{ prefix, valuePtr.* }) catch "";
    _ = rg.label(offsetRect(menuProperties.bounds, position, scroll), text);
}

pub fn drawNumberLabel(menuProperties: mu.MenuProperties, valuePtr: anytype, position: rl.Vector2, scroll: rl.Vector2) void {
    var label_buf: [64]u8 = undefined;
    const text = formatNumberLabel(&label_buf, valuePtr.*);
    _ = rg.label(offsetRect(menuProperties.bounds, position, scroll), text);
}

pub fn drawSlider(slider: *const Slider, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.label(offsetRect(slider.props.nameBounds, position, scroll), slider.props.name);
    var buf: [64:0]u8 = undefined;
    const valueText = formatNumberLabel(&buf, slider.valuePtr.*);
    _ = rg.slider(offsetRect(slider.props.itemBounds, position, scroll), "", valueText, slider.valuePtr, slider.range.lower, slider.range.upper);
}

pub fn drawValueBoxElement(valueBox: *const ValueBox, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.label(offsetRect(valueBox.props.nameBounds, position, scroll), valueBox.props.name);
    _ = rg.valueBox(
        offsetRect(valueBox.props.itemBounds, position, scroll),
        "",
        valueBox.valuePtr,
        @intFromFloat(valueBox.range.lower),
        @intFromFloat(valueBox.range.upper),
        true
    );
}

pub fn drawLabelElement(label: *const Label, position: rl.Vector2, scroll: rl.Vector2) void {
    var buf: [64:0]u8 = undefined;
    const valueText = std.fmt.bufPrintZ(&buf, "{s}: {d}", .{label.props.name, label.valuePtr.*}) catch "";
    _ = rg.label(offsetRect(label.props.itemBounds, position, scroll), valueText);
}

pub fn drawLine(line: *const Line, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.line(offsetRect(line.props.itemBounds, position, scroll), line.props.name);
}

pub fn drawButton(button: *const Button, position: rl.Vector2, scroll: rl.Vector2) void {
    if (rg.button(offsetRect(button.props.itemBounds, position, scroll), button.props.name)) {
        button.buttonFn();
    }
}

pub fn drawGroupBox(groupBox: *const GroupBox, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.groupBox(offsetRect(groupBox.props.itemBounds, position, scroll), groupBox.props.name);
}

pub fn drawLabelButton(labelButton: *const LabelButton, position: rl.Vector2, scroll: rl.Vector2) void {
    if (rg.labelButton(offsetRect(labelButton.props.itemBounds, position, scroll), labelButton.props.name)) {
        labelButton.buttonFn();
    }
}

pub fn drawToggle(toggle: *const Toggle, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.label(offsetRect(toggle.props.nameBounds, position, scroll), toggle.props.name);
    _ = rg.toggle(offsetRect(toggle.props.itemBounds, position, scroll), "", toggle.activePtr);
}

pub fn drawCheckBox(checkBox: *const CheckBox, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.checkBox(offsetRect(checkBox.props.itemBounds, position, scroll), checkBox.props.name, checkBox.checkedPtr);
}

pub fn drawComboBox(comboBox: *const ComboBox, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.label(offsetRect(comboBox.props.nameBounds, position, scroll), comboBox.props.name);
    _ = rg.comboBox(offsetRect(comboBox.props.itemBounds, position, scroll), comboBox.items, comboBox.activePtr);
}

pub fn drawDropdownBox(dropdownBox: *const DropdownBox, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.label(offsetRect(dropdownBox.props.nameBounds, position, scroll), dropdownBox.props.name);
    if(rg.dropdownBox(offsetRect(dropdownBox.props.itemBounds, position, scroll), dropdownBox.items, dropdownBox.activePtr, dropdownBox.editModePtr.*) > 0) {
        dropdownBox.editModePtr.* = !dropdownBox.editModePtr.*;
    }
}

pub fn drawTextBox(textBox: *const TextBox, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.label(offsetRect(textBox.props.nameBounds, position, scroll), textBox.props.name);
    _ = rg.textBox(offsetRect(textBox.props.itemBounds, position, scroll), textBox.textPtr, textBox.textSize, textBox.editModePtr.*);
}

pub fn drawSpinner(spinner: *const Spinner, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.label(offsetRect(spinner.props.nameBounds, position, scroll), spinner.props.name);
    _ = rg.spinner(offsetRect(spinner.props.itemBounds, position, scroll), "", spinner.valuePtr, @intFromFloat(spinner.range.lower), @intFromFloat(spinner.range.upper), spinner.editModePtr.*);
}

pub fn drawSliderBarElement(sliderBar: *const SliderBar, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.label(offsetRect(sliderBar.props.nameBounds, position, scroll), sliderBar.props.name);
    var buf: [64:0]u8 = undefined;
    const valueText = formatNumberLabel(&buf, sliderBar.valuePtr.*);
    _ = rg.sliderBar(offsetRect(sliderBar.props.itemBounds, position, scroll), "", valueText, sliderBar.valuePtr, sliderBar.range.lower, sliderBar.range.upper);
}

pub fn drawProgressBar(progressBar: *const ProgressBar, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.label(offsetRect(progressBar.props.nameBounds, position, scroll), progressBar.props.name);
    var buf: [64:0]u8 = undefined;
    const valueText = formatNumberLabel(&buf, progressBar.valuePtr.*);
    _ = rg.progressBar(offsetRect(progressBar.props.itemBounds, position, scroll), "", valueText, progressBar.valuePtr, progressBar.range.lower, progressBar.range.upper);
}

pub fn drawStatusBar(statusBar: *const StatusBar, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.statusBar(offsetRect(statusBar.props.itemBounds, position, scroll), statusBar.props.name);
}

pub fn drawToggleGroup(toggleGroup: *const ToggleGroup, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.label(offsetRect(toggleGroup.props.nameBounds, position, scroll), toggleGroup.props.name);
    _ = rg.toggleGroup(offsetRect(toggleGroup.props.itemBounds, position, scroll), toggleGroup.items, toggleGroup.activePtr);
}

pub fn drawToggleSlider(toggleSlider: *const ToggleSlider, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.label(offsetRect(toggleSlider.props.nameBounds, position, scroll), toggleSlider.props.name);
    _ = rg.toggleSlider(offsetRect(toggleSlider.props.itemBounds, position, scroll), toggleSlider.items, toggleSlider.activePtr);
}

pub fn drawDummyRec(dummyRec: *const DummyRec, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.dummyRec(offsetRect(dummyRec.props.itemBounds, position, scroll), dummyRec.props.name);
}

pub fn drawGrid(grid: *const Grid, position: rl.Vector2, scroll: rl.Vector2) void {
    _ = rg.grid(offsetRect(grid.props.itemBounds, position, scroll), grid.props.name, grid.spacing, grid.subdivs, grid.mouseCellPtr);
}

pub const BoundsCalculator = struct {
    y: f32,
    lastAdvancedAmount: f32 = 0,
    drawSettings: mu.DrawSettings,

    pub fn init(drawSettings: mu.DrawSettings) BoundsCalculator {
        return .{
            .y = WINDOW_STATUS_BAR_HEIGHT + 4,
            .drawSettings = drawSettings
        };
    }

    pub fn getNameBounds(self: *BoundsCalculator, x_offset: f32, needsLabel: bool) rl.Rectangle {
        if (!needsLabel) {
            return rl.Rectangle{.height = 0, .width = 0, .x = 0, .y = 0};
        }
        const bounds = rl.Rectangle{
            .width = self.drawSettings.width,
            .height = self.drawSettings.nameHeight,
            .x = self.drawSettings.startX + x_offset,
            .y = self.y
        };
        self.y += self.drawSettings.nameHeight + self.drawSettings.namePadding;
        return bounds;
    }

    pub fn getItemBounds(self: *BoundsCalculator, x_offset: f32) rl.Rectangle {
        return rl.Rectangle{
            .width = self.drawSettings.width,
            .height = self.drawSettings.height,
            .x = self.drawSettings.startX + x_offset,
            .y = self.y
        };
    }

    pub fn getItemBoundsWithHeight(self: *BoundsCalculator, x_offset: f32, height: f32) rl.Rectangle {
        return rl.Rectangle{
            .width = self.drawSettings.width,
            .height = height,
            .x = self.drawSettings.startX + x_offset,
            .y = self.y
        };
    }

    pub fn getItemBoundsPro(self: *BoundsCalculator, x_offset: f32, height: f32, width: f32) rl.Rectangle {
        return rl.Rectangle{
            .width = width,
            .height = height,
            .x = self.drawSettings.startX + x_offset,
            .y = self.y
        };
    }

    pub fn getSquareItemBounds(self: *BoundsCalculator, x_offset: f32, side: f32) rl.Rectangle {
        return rl.Rectangle{
            .width = side,
            .height = side,
            .x = self.drawSettings.startX + x_offset,
            .y = self.y
        };
    }

    pub fn advanceY(self: *BoundsCalculator) void {
        self.lastAdvancedAmount = self.drawSettings.height;
        self.y += self.drawSettings.height + self.drawSettings.paddingY;
    }

    pub fn getY(self: *const BoundsCalculator) f32 {
        return self.y;
    }

    pub fn setY(self: *BoundsCalculator, y: f32) void {
        self.y = y;
    }

    pub fn advanceYBy(self: *BoundsCalculator, amount: f32) void {
        self.lastAdvancedAmount = amount;
        self.y += amount;
    }

    pub fn padY(self: *BoundsCalculator) void {
        self.y += self.drawSettings.paddingY;
    }

    pub fn unpadY(self: *BoundsCalculator) void {
        self.y -= self.drawSettings.paddingY;
    }
};


pub const WINDOW_STATUS_BAR_HEIGHT = 24;
const WINDOW_CLOSE_BUTTON_SIZE = 18;
const CLOSE_TITLE_SIZE_DELTA_HALF = (WINDOW_STATUS_BAR_HEIGHT - WINDOW_CLOSE_BUTTON_SIZE) / 2;
const MIN_WINDOW_SIZE = 100;

const DrawContentFn = *const fn(wo: *Window) void;

pub const Window = struct {
    title: []const u8,
    position: rl.Vector2 = undefined,
    size: rl.Vector2 = undefined,
    minimized: bool = false,
    moving: bool = false,
    resizing: bool = false,
    drawContent: DrawContentFn = undefined,
    contentSize: rl.Vector2 = undefined,
    scroll: rl.Vector2 = undefined,
    user_data: ?*anyopaque = null,
    menuItems: []*MenuItem = undefined,
    z0Items: []*MenuItem = undefined,

    const Self = @This();
};

pub fn floatingWindow(wo: *Window) void {
    var title_buf: [64]u8 = undefined;
    const title_text = std.fmt.bufPrintZ(&title_buf, "{s}", .{ wo.title }) catch "";
    const mouse_position = rl.getMousePosition();

    const is_left_pressed = rl.isMouseButtonPressed(rl.MouseButton.left);
    if(is_left_pressed and !(wo.moving) and !(wo.resizing)) {

        const title_collsion_rect = rl.Rectangle{.x = wo.position.x, .y = wo.position.y, .width = wo.size.x - WINDOW_CLOSE_BUTTON_SIZE - CLOSE_TITLE_SIZE_DELTA_HALF, .height = WINDOW_STATUS_BAR_HEIGHT};
        const resize_collision_rect = rl.Rectangle{.x = wo.position.x + wo.size.x - 20, .y = wo.position.y + wo.size.y - 20, .width = 20, .height = 20};

        if(rl.checkCollisionPointRec(mouse_position, title_collsion_rect)) {
            wo.moving = true;
        } else if(!(wo.minimized) and rl.checkCollisionPointRec(mouse_position, resize_collision_rect)) {
            wo.resizing = true;
        }
    }

    const screen_width = rl.getScreenWidth();
    const screen_width_f32 = @as(f32, @floatFromInt(screen_width));
    const screen_height = rl.getScreenHeight();
    const screen_height_f32 = @as(f32, @floatFromInt(screen_height));
    // window movement and resize update
    if(wo.moving) {
        const mouse_delta = rl.getMouseDelta();
        wo.position.x += mouse_delta.x;
        wo.position.y += mouse_delta.y;

        if(rl.isMouseButtonReleased(rl.MouseButton.left)) {
            wo.moving = false;

            if(wo.position.x < 0) {
                wo.position.x = 0;
            } else if(wo.position.x > screen_width_f32 - wo.size.x) {
                wo.position.x = screen_width_f32 - wo.size.x;
            }
            if(wo.position.y < 0) {
                wo.position.y = 0;
            } else if(wo.position.y > screen_height_f32) {
                wo.position.y = screen_height_f32 - WINDOW_STATUS_BAR_HEIGHT;
            }
        }
    } else if(wo.resizing) {
        if (mouse_position.x > wo.position.x) {
            wo.size.x = mouse_position.x - wo.position.x;
        }
        if (mouse_position.y > wo.position.y) {
            wo.size.y = mouse_position.y - wo.position.y;
        }
        // clamp window size to an arbitrary minimum value and the window size as the maximum
        if(wo.size.x < 100) {
            wo.size.x = 100;
        } else if(wo.size.x > screen_width_f32) {
            wo.size.x = screen_width_f32;
        }
        if(wo.size.y < 100) {
            wo.size.y = 100;
        } else if(wo.size.y > screen_height_f32) {
            wo.size.y = screen_height_f32;
        }

        if (rl.isMouseButtonReleased(rl.MouseButton.left)) {
            wo.resizing = false;
        }
    }
    // window and content drawing with scissor and scroll area
    if(wo.minimized) {
        _ = rg.statusBar(rl.Rectangle{ .x = wo.position.x, .y = wo.position.y, .width = wo.size.x, .height = WINDOW_STATUS_BAR_HEIGHT}, title_text);

        if (rg.button(rl.Rectangle{ .x = wo.position.x + wo.size.x - WINDOW_CLOSE_BUTTON_SIZE - CLOSE_TITLE_SIZE_DELTA_HALF,
            .y = wo.position.y + CLOSE_TITLE_SIZE_DELTA_HALF,
            .width = WINDOW_CLOSE_BUTTON_SIZE,
            .height = WINDOW_CLOSE_BUTTON_SIZE},
            "#120#")) {
            wo.minimized = false;
        }

    } else {
        wo.minimized = rg.windowBox(rl.Rectangle{ .x = wo.position.x, .y = wo.position.y, .width = wo.size.x, .height = wo.size.y}, title_text) > 0;

        // scissor and draw content within a scroll panel
        var scissor: rl.Rectangle = undefined;
        _ = rg.scrollPanel(rl.Rectangle{ .x = wo.position.x, .y = wo.position.y + WINDOW_STATUS_BAR_HEIGHT, .width = wo.size.x, .height = wo.size.y - WINDOW_STATUS_BAR_HEIGHT},
            null,
            rl.Rectangle{ .x = wo.position.x, .y = wo.position.y, .width = wo.contentSize.x, .height = wo.contentSize.y },
            &wo.scroll,
            &scissor);

        const require_scissor = wo.size.x < wo.contentSize.x or wo.size.y < wo.contentSize.y;

        if(require_scissor) {
            rl.beginScissorMode(@intFromFloat(scissor.x), @intFromFloat(scissor.y), @intFromFloat(scissor.width), @intFromFloat(scissor.height));
        }

        wo.drawContent(wo);

        if(require_scissor) {
            rl.endScissorMode();
        }

        // draw the resize button/icon
        _ = rg.drawIcon(71, @intFromFloat(wo.position.x + wo.size.x - 20), @intFromFloat(wo.position.y + wo.size.y - 20), 1, rl.Color.gray);

    }
}

fn drawContent(position: rl.Vector2, window_scroll: rl.Vector2) void {
    _ = rg.button(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 50 + window_scroll.y, .width = 100, .height = 25 }, "Button 1");
    _ = rg.button(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 100 + window_scroll.y, .width = 100, .height = 25 }, "Button 2");
    _ = rg.button(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 150  + window_scroll.y, .width = 100, .height = 25 }, "Button 3");
    _ = rg.label(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 200 + window_scroll.y, .width = 250, .height = 25 }, "A Label");
    _ = rg.label(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 250 + window_scroll.y, .width = 250, .height = 25 }, "Another Label");
    _ = rg.label(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 300 + window_scroll.y, .width = 250, .height = 25 }, "Yet Another Label");
}