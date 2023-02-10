
import Logger from "./Logger";
import {
  scriptLoadingUtility,
} from "./helpers/index";
import {
  isWasmSupported,
} from "./environment/index";

export class WasmApplication {

  private _isInitialized: boolean = false;
  private _isAborted: boolean = false;
  private _logger: Logger;
  private _wasmFunctions: any = {};

  constructor(logger: Logger) {
    this._logger = logger;
  }

  async initialize(): Promise<void> {

    //
    //
    // WebAssembly support

    if (!isWasmSupported()) {
      throw new Error("missing WebAssembly feature (unsupported)");
    }

    this._logger.log("[JS][check] WebAssembly feature => supported");

    //
    //
    // setup

    const wasmFolder = "web-wasm";

    return new Promise((resolve, reject) => {

      //
      //
      // setup the wasm module

      const Module = {
        downloadingDataRegExp: /Downloading data\.\.\. \(([0-9]*)\/([0-9]*)\)/,
        lastProgressLevel: 0,
        locateFile: (url: string) => { return `${wasmFolder}/${url}`; },
        print: (text: string) => { this._logger.log(`[C++][out] ${text}`); },
        printErr: (text: string) => { this._logger.error(`[C++][err] ${text}`); },
        setStatus: (text: string) => {

          if (!text)
            return;

          // is the current message a "Downloading data..." one?
          const capture = Module.downloadingDataRegExp.exec(text);
          if (capture) {

            const current = parseFloat(capture[1]);
            const total = parseFloat(capture[2]);
            const percent = Math.floor((current / total) * 100);

            if (Module.lastProgressLevel !== percent) {
              Module.lastProgressLevel = percent;
              this._logger.log(percent);
            }
          }
          else {
            this._logger.log(`[JS][wasm][status] ${text}`);
          }
        },
        onRuntimeInitialized: () => {

          this._logger.log("[JS][wasm] loaded");
          this._logger.log("[JS][wasm] initializing");

          this._wasmFunctions.runDhLogic = (window as any).Module.cwrap('runDhLogic', undefined, []),
          this._wasmFunctions.runAesLogic = (window as any).Module.cwrap('runAesLogic', undefined, []),
          this._wasmFunctions.makeWasmPrintMessage = (window as any).Module.cwrap('makeWasmPrintMessage', undefined, ['number']),
          this._wasmFunctions.getHeapString = (window as any).Module.cwrap('getHeapString', 'number', []),

          this._isInitialized = true;

          this._logger.log("[JS][wasm] initialized");

          resolve();
        },
        noInitialRun: true,
        noExitRuntime: true,
      };

      // this is needed by the wasm side
      (window as any).Module = Module;

      this._logger.log("[JS][wasm] loading");
      scriptLoadingUtility(`./${wasmFolder}/index.js`).catch(reject);
    });
  }

  runDhLogic() {
    if (!this._isInitialized || this._isAborted || !this._wasmFunctions.runDhLogic)
      return;

    this._wasmFunctions.runDhLogic();
  }

  runAesLogic() {
    if (!this._isInitialized || this._isAborted || !this._wasmFunctions.runAesLogic)
      return;

    this._wasmFunctions.runAesLogic();
  }

  makeWasmPrintMessage(inMessage: string) {
    if (!this._isInitialized || this._isAborted || !this._wasmFunctions.makeWasmPrintMessage)
      return;

    const module = (window as any).Module;

    const size = module.lengthBytesUTF8(inMessage) + 1;
    const ptr = module._malloc(size); // manual allocation
    module.stringToUTF8(inMessage, ptr, size);

    this._wasmFunctions.makeWasmPrintMessage(ptr);

    module._free(ptr); // manual deallocation
  }

  getHeapString() {
    if (!this._isInitialized || this._isAborted || !this._wasmFunctions.getHeapString)
      return;

    const module = (window as any).Module;

    const ptr = this._wasmFunctions.getHeapString(); // manual allocation inside
    const message = module.UTF8ToString(ptr);

    module._free(ptr); // manual deallocation

    return message;
  }

  abort(): void {

    if (!this._isInitialized || this._isAborted)
      return;

    this._isAborted = true;
    const currModule = (window as any).Module;
    if (currModule) {
      currModule.setStatus = (text: string) => {
        if (text)
          this._logger.error(`[JS][wasm][aborted] ${text}`);
      };
    }
  }
};
