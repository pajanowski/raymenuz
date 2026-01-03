# raymenuz
## A dynamic menu library for raylib and raygui written in Zig
- - -
### Main Features:
- Hot reloading
- Semi-automatic element positioning
- Yaml defined menus
 - - -
### Installation
raymenuz requires 3 libraries
- raylib-zig https://github.com/raylib-zig/raylib-zig
- raygui (included in raylib-zig)
- ymlz https://github.com/pwbh/ymlz

Install with 
`zig fetch --save git+https://github.com/pajanowski/raymenuz.git#HEAD`

In your `build.zig`
```zig
    const raymenuz = b.dependency("raymenuz", .{});
    const ymlz = b.dependency("ymlz", .{});

    const mod = b.addModule("", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const raymenuz_mod = raymenuz.module("raymenuz");
    raymenuz_mod.addImport("raylib", raylib);
    raymenuz_mod.addImport("raygui", raygui);
    raymenuz_mod.addImport("ymlz", ymlz.module("root"));


    mod.addImport("raymenuz", raymenuz_mod);
```
- - - 
### Usage
```zig
const RayMenu = @import("raymenuz").RayMenu;

pub const Player = struct {
    vel: Vector2,

    gravity: f32 = -100,
    jumpPower: f32 = 20,

    bounces: u16 = 0,
    xSpeed: i32 = 5,
};

pub const GameState = struct {
    player: *Player
};

pub fn main() !void {
    var state = GameState.init();
    var rayMenu = RayMenu(GameState).init(
        "src/menu.yml",
        &state,
        allocator
    );

    while (!rl.windowShouldClose()) { 
        // Update your application
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);
        rl.beginMode2D(camera);
            // Draw your game
        rl.endMode2D();
        
        rayMenu.draw();
        if(rl.isKeyPressed(rl.KeyboardKey.r)) {
            if(rayMenu.reloadMenuItems()) |newDevMenu| {
                rayMenu = rayMenu;
            } else |err| {
                std.log.err("Failed to reload menu items {any}", .{err});
            }
        }
    }
}
```

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
There is also a working example in [src/main.zig](src/main.zig).

- - - 
### Menu Definition

#### drawSettings &rarr; DrawSettings defined in [raymenuutils.zig](src/raymenuutils.zig)
| Field    | Description                                                                                                        | Allowed Values |
|:---------|:-------------------------------------------------------------------------------------------------------------------|:---------------|
| paddingY | Vertical space between elements                                                                                    | Any integer    |
| startX   | Horizontal space between left side of screen and elements this does not account for text in the displayValuePrefix | Any integer    | 
| width    | Width of elements                                                                                                  | Any integer    | 
| height   | Height of elements                                                                                                 | Any integer    | 

#### itemDefs, list of YamlItemDef defined in [raymenuutils.zig](src/raymenuutils.zig)
| Field              | Description                                                                                               | Allowed Values                                     |
|:-------------------|:----------------------------------------------------------------------------------------------------------|:---------------------------------------------------|
| elementType        | Element type                                                                                              | SLIDER, VALUE_BOX, LABEL                           |
| statePath          | Path in provided state value                                                                              | Any string that maps to a value in the struct type | 
| displayValuePrefix | The label displayed to the left of the element                                                            | Any String                                         | 
| menuItemType       | Type of value at statePath, currently float(f16-32), int(i8-32), and string([]const u8) are only supporte | float, int, string                                 | 
| range              | Range for number based elements                                                                           | Valid struct definition                            | 

#### range, Range defined in [raymenuutils.zig](src/raymenuutils.zig)
While only used for number-based elements, it is still required for all elements for the sake of parsing and memory alignment.

| Field | Description | Allowed Values               |
|:------|:------------|:-----------------------------|
| lower | Lower bound | Any float less than upper    |
| upper | Upper bound | Any float greater than upper |

### raygui elements

| Element          | Status              | elementType | Supported menuItemType |
|:-----------------|:--------------------|-------------|:-----------------------|
| **Slider**       | Supported           | `SLIDER`    | `float`                |
| **ValueBox**     | Supported           | `VALUE_BOX` | `int`                  |
| **Label**        | Partially Supported | `LABEL`     | `int`                  |
| **Button**       | Planned             |             | -                      |
| **TextBox**      | Planned             |             | -                      |
| **SliderBar**    | Planned             |             | -                      |
| **ProgressBar**  | Planned             |             | -                      |
| **StatusBar**    | Planned             |             | -                      |
| **CheckBox**     | Planned             |             | -                      |
| **LabelButton**  | Planned             |             | -                      |
| **Toggle**       | Needs Consideration |             | -                      |
| **ToggleGroup**  | Needs Consideration |             | -                      |
| **ToggleSlider** | Needs Consideration |             | -                      |
| **ComboBox**     | Needs Consideration |             | -                      |
| **DropdownBox**  | Needs Consideration |             | -                      |
| **Spinner**      | Needs Consideration |             | -                      |
| **DummyRec**     | Needs Consideration |             | -                      |
| **Grid**         | Needs Consideration |             | -                      |
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

This libary is also fairly small and adding new elementTypes for the existing menuItemTypes should be fairly straight forward, and maybe qualify as a good first issue.
1. Add a `draw(rayguiElement)` in RayMenu
2. Add the new element type to the UiElementType enum in `raymenuutils.zig`
3. Add a corresponding branch to `draw(menuItemType)Elements`
- - -
- ### Motivation
I wanted a developer menu, DearImgUi, microui, etc., for every raylib project I started, but I always found it difficult
to get them working when using languages other than C.

It occurred to me the raylib way of doing this was to use raygui. However, I never found using raygui enjoyable.
The cycle of pixel bumping and compiling felt cumbersome. I played around with auto placement for raygui elements
before, but it still required recompiling to add a label to watch a value I needed to see at that moment.

raymenuz is my solution to my problem. I hope that others find it useful.

- - - 

