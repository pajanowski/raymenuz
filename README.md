# raymenuz
## A raygui wrapper for quick menus written in zig
- - -
### Main Features:
- Easy API for creating raygui menus fast
- Yaml File defined menus
- Hot reloading

 - - -
### Installation
These directions assume that you already have a working raylib project.

raymenuz requires 2 libraries
- raylib-zig https://github.com/raylib-zig/raylib-zig
- raygui (included in raylib-zig)
- ymlz https://github.com/pwbh/ymlz (only if using YAML defined menus)

Install with 
`zig fetch --save git+https://github.com/pajanowski/raymenuz.git#HEAD`

In your `build.zig`
```zig
    const raylib_dep = b.dependency("raylib-zig", .{
        .target = target,
        .optimize = optimize,
    });
    const raylib_mod = raylib_dep.module("raylib");
    const raygui_mod = raylib_dep.module("raygui");

    const raymenuz = b.dependency("raymenuz", .{});
    const ymlz = b.dependency("ymlz", .{});

    const mod = b.addModule("your_module", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const raymenuz_mod = raymenuz.module("raymenuz");
    raymenuz_mod.addImport("raylib", raylib_mod);
    raymenuz_mod.addImport("raygui", raygui_mod);
    raymenuz_mod.addImport("ymlz", ymlz.module("root"));

    mod.addImport("raymenuz", raymenuz_mod);

    // If using an executable:
    // exe.root_module.addImport("raymenuz", raymenuz_mod);
```
- - - 
### Usage (File defined)

`RayMenuFromFile` allows you to define your menu in a YAML file and hot-reload it during development.
[Example](src/examples/raymenu_from_file_example.zig)
```zig:src/examples/raymenu_from_file_example.zig
```

    var rayMenu = RayMenuFromFile(GameState).init(
        "src/menu.yaml",
        &state,
        allocator
    );

    while (!rl.windowShouldClose()) { 
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.ray_white);
        
        rayMenu.draw();

        if (rl.isKeyPressed(rl.KeyboardKey.r)) {
            rayMenu.reloadMenuItems() catch |err| {
                std.log.err("Failed to reload menu items {any}", .{err});
            };
        }
    }
}
```

[Example YAML](src/examples/menu.yaml)
```yaml
drawSettings:
  paddingY: 5
  startX: 25
  width: 75
  height: 10
itemDefs:
  - elementType: SLIDER
    statePath: player.gravity
    displayValuePrefix: Gravity
    menuItemType: float
    range:
      upper: 0
      lower: -400
  - elementType: VALUE_BOX
    statePath: player.xSpeed
    displayValuePrefix: X Speed
    menuItemType: int
    range:
      upper: 1000
      lower: 0
  - elementType: LABEL
    statePath: player.vel.y
    displayValuePrefix: Vel Y
    menuItemType: float
    range:
      upper: -1
      lower: -1
```

There is also a working example in [src/examples/raymenu_from_file_example.zig](src/examples/raymenu_from_file_example.zig).

### Usage (Manual)

`RayMenu` and `RayMenuWindowBuilder` allow you to create menus programmatically in Zig code.

[Example](src/examples/raymenu_example.zig)
```zig
  var windowBuilder = rm.RayMenuWindowBuilder.init("raygui Elements Demo", drawSettings, allocator);

  // Basic Controls Group
  try windowBuilder.startGroup("Basic Controls");
      // Button
      const testButton = rm.Button.init("Click Me!", buttonTest);
      try windowBuilder.addMenuItem(testButton);

      // LabelButton
      const labelButton = rm.LabelButton.init("Label Button", buttonTest2);
      try windowBuilder.addMenuItem(labelButton);

      const line1 = rm.Line.init("This is a line");
      try windowBuilder.addMenuItem(line1);

      // Toggle
      const toggle = rm.Toggle.init("Enable Player", &player.enabled);
      try windowBuilder.addMenuItem(toggle);

      // CheckBox
      const checkbox = rm.CheckBox.init("God Mode", &player.godMode);
      try windowBuilder.addMenuItem(checkbox);
  try windowBuilder.endGroup();

  // Sliders & Progress Group
  try windowBuilder.startGroup("Sliders & Progress");
      // Slider
      const speedSlider = rm.Slider.init("Speed X", raymenuz.mu.Range{.lower = 0, .upper = 50}, &player.speed.x);
      try windowBuilder.addMenuItem(speedSlider);

      const speedSlider2 = rm.Slider.init("Speed Y", raymenuz.mu.Range{.lower = 0, .upper = 50}, &player.speed.y);
      try windowBuilder.addMenuItem(speedSlider2);

      // SliderBar
      const healthSlider = rm.SliderBar.init("Health", raymenuz.mu.Range{.lower = 0, .upper = 100}, &player.health);
      try windowBuilder.addMenuItem(healthSlider);

      // ProgressBar
      const healthProgress = rm.ProgressBar.init("HP Bar", raymenuz.mu.Range{.lower = 0, .upper = 100}, &player.health);
      try windowBuilder.addMenuItem(healthProgress);
  try windowBuilder.endGroup();

  var window = try windowBuilder.build();
  var rayMenu = rm.RayMenu.init(allocator);
  try rayMenu.addWindow(&window);

  while (!rl.windowShouldClose())
  {
      // Update
     
      // Draw
      rl.beginDrawing();
      defer rl.endDrawing();

      rl.clearBackground(rl.Color.dark_gray);

      // Draw menu
      rayMenu.draw();
  }
```

- - - 
### Menu Definition

#### drawSettings &rarr; DrawSettings defined in [menu_utils.zig](src/menu_utils.zig)
| Field                  | Description                                                                                                        | Allowed Values |
|:-----------------------|:-------------------------------------------------------------------------------------------------------------------|:---------------|
| paddingY               | Vertical space between elements                                                                                    | Any integer    |
| startX                 | Horizontal space between left side of screen and elements this does not account for text in the displayValuePrefix | Any integer    | 
| width                  | Width of elements                                                                                                  | Any integer    | 
| height                 | Height of elements                                                                                                 | Any integer    | 
| buttonHeight           | Height of buttons                                                                                                 | Any integer    |
| checkboxSize           | Size of checkboxes                                                                                                | Any integer    |
| toggleGroupButtonWidth | Width of buttons in a toggle group                                                                                 | Any integer    |

#### itemDefs, list of YamlItemDef defined in [menu_utils.zig](src/menu_utils.zig)
| Field              | Description                                                                                               | Allowed Values                                     |
|:-------------------|:----------------------------------------------------------------------------------------------------------|:---------------------------------------------------|
| elementType        | Element type                                                                                              | SLIDER, VALUE_BOX, LABEL                           |
| statePath          | Path in provided state value                                                                              | Any string that maps to a value in the struct type | 
| displayValuePrefix | The label displayed to the left of the element                                                            | Any String                                         | 
| menuItemType       | Type of value at statePath, currently float, int, and string are only supported | float, int, string                                 | 
| range              | Range for number based elements                                                                           | Valid struct definition                            | 

#### range, Range defined in [menu_utils.zig](src/menu_utils.zig)
While only used for number-based elements, it is still required for all elements for the sake of parsing and memory alignment.

| Field | Description | Allowed Values               |
|:------|:------------|:-----------------------------|
| lower | Lower bound | Any float less than upper    |
| upper | Upper bound | Any float greater than upper |

### raygui elements

| Element          | File Defined Status | Manually Defined Status | File Defined elementType value | File Defined Supported menuItemType |
|:-----------------|:--------------------|-------------------------|--------------------------------|:------------------------------------|
| **Slider**       | Supported           | Supported               | `SLIDER`                       | `float`                             |
| **ValueBox**     | Supported           | Supported               | `VALUE_BOX`                    | `int`                               |
| **Label**        | Supported           | Supported               | `LABEL`                        | `int`, `float`, `string`            |
| **Button**       | Supported           | Supported               |                                | -                                   |
| **LabelButton**  | Supported           | Supported               |                                | -                                   |
| **CheckBox**     | Supported           | Supported               |                                | -                                   |
| **Toggle**       | Supported           | Supported               |                                | -                                   |
| **ToggleGroup**  | Supported           | Supported               |                                | -                                   |
| **ToggleSlider** | Supported           | Supported               |                                | -                                   |
| **ComboBox**     | Supported           | Supported               |                                | -                                   |
| **DropdownBox**  | Supported           | Supported               |                                | -                                   |
| **TextBox**      | Supported           | Supported               |                                | -                                   |
| **Spinner**      | Supported           | Supported               |                                | -                                   |
| **SliderBar**    | Supported           | Supported               |                                | -                                   |
| **ProgressBar**  | Supported           | Supported               |                                | -                                   |
| **StatusBar**    | Supported           | Supported               |                                | -                                   |
| **DummyRec**     | Supported           | Supported               |                                | -                                   |
| **Grid**         | Supported           | Supported               |                                | -                                   |
| **Line**         | Supported           | Supported               |                                | -                                   |
| **GroupBox**     | Supported           | Supported               |                                | -                                   |
| **Window**       | Supported           | Supported               | -                              | -                                   |
 - - -
### Known Errors
Error handling improvements will be made for errors that happen outside of this library, better error handling, more specific log messages, etc.

### Menu Items Not Appearing Errors
* 'error: State path X not found or not parseable to Y(type)'
  * Either the statePath set for the non-appearing menu item is not at the path for the provided state struct,
  or it does exist and the type is mismatched, e.g., the field the statePath is pointing to might be a `[]const u8` but the
  value type is an `int`.

### Black Screen Errors
* 'panic: start index X is larger than end index 0'
  * You probably have a blank line in your yaml file. This has been fixed in ymlz but isn't in a release yet.

* 'panic: attempt to use null value'
  * Your elementType might not be available for the type you've specified.
  * You are probably missing a value in the struct. Remember that all values are required in the menu yaml definition.

- - - 
### Contributing
Please create an issue before putting up a pull request.

This library is also fairly small. Adding new elementTypes for the existing menuItemTypes should be fairly straight forward and maybe qualify as a good first issue.
1. Add a `draw(rayguiElement)` in `draw_utils.zig`
2. Add the new element type to the `UiElementType` enum in `menu_utils.zig`
3. Add a corresponding branch to `draw(menuItemType)Elements` in `draw_utils.zig`
- - -
- ### Motivation
I wanted a developer menu, DearImgUi, microui, etc., for every raylib project I started, but I always found it difficult
to get them working when using languages other than C.

It occurred to me the raylib way of doing this was to use raygui. However, I never found using raygui enjoyable.
The cycle of pixel bumping and compiling felt cumbersome. I played around with auto placement for raygui elements
before, but it still required recompiling to add a label to watch a value I needed to see at that moment.

raymenuz is my solution to my problem. I hope that others find it useful.

- - - 

