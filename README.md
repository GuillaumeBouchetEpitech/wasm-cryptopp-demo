# wasm-cryptopp-demo

## Online Demo Link

**`/!\ important /!\`**

http://guillaumebouchetepitech.github.io/wasm-cryptopp-demo/dist/index.html

**`/!\ important /!\`**

# Dependencies

## Dependency: Emscripten 3.1.26 (for web-wasm build)
```bash
git clone https://github.com/emscripten-core/emsdk.git

cd emsdk

./emsdk install 3.1.26
./emsdk activate --embedded 3.1.26

. ./emsdk_env.sh

em++ --clear-cache
```

## Dependency: Crypto++ 8.2.0

Note: later versions could crash unexpectedly (native + wasm)

[Github Link](https://github.com/weidai11/cryptopp)

This dependency will be downloaded and built with the `Build Everything` method below

# How to Build

## Build Everything (will skip web-wasm if emscripten is absent)

```bash
chmod +x ./sh_everything.sh
./sh_everything.sh
# will skip the web-wasm build if emscripten is not detected
```

# How to Run

## Native Build

```
./bin/exec
```

## Web Wasm Build - without multithreading support: webworkers (mobile friendly)

```bash
node dumbFileServer.js # launch the file server
```

then use **firefox/chrome browser (should support desktop and mobile)** to load `http://127.0.0.1:9000/dist/index.html`

## Web Wasm Build - with multithreading support (desktop friendly)

```bash
node dumbFileServer.js # launch the file server
```

then use **firefox/chrome browser (desktop adviseable)** to load `http://127.0.0.1:9001/dist/index.html`


# Thanks for watching!
