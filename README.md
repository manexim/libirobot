# libirobot

## Building

```
git clone https://github.com/manexim/libirobot.git && cd libirobot
meson build && cd build
meson configure -Dprefix=/usr
ninja
```

## Testing

```
cd build
ninja
./src/cli
```
