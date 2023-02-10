
import Logger from "./Logger";
import { WasmApplication } from "./WasmApplication";

const findOrFailHtmlElement = <T extends Element>(elementId: string): T => {
  const textAreaElement = document.querySelector<T>(elementId);
  if (!textAreaElement)
    throw new Error(`DOM elements not found, id=${elementId}`);
  return textAreaElement;
}

const onGlobalPageLoad = async () => {

  let isRunning = true;

  const textAreaElement = findOrFailHtmlElement<HTMLTextAreaElement>("#loggerOutput");
  const logger = new Logger(textAreaElement);

  logger.log("[JS] page loaded");

  const onInitialGlobalPageError = (event: ErrorEvent) => {
    isRunning = false;
    logger.error(`[JS] fatal error, event=${event}`);
  };
  window.addEventListener("error", onInitialGlobalPageError);

  //
  //
  //

  const myApplication = new WasmApplication(logger);

  try
  {
    await myApplication.initialize();
  }
  catch (err) {
    logger.error(`[JS] dependencies check failed: message="${err.message}"`);
  }

  logger.log("");
  logger.log(`#`);
  logger.log(`# LOGIC START`);
  logger.log("");
  logger.log(`#`);
  logger.log(`# test: Diffie Hellman key exchange`);
  logger.log("");

  myApplication.runDhLogic();

  logger.log("");
  logger.log(`#`);
  logger.log(`# test: Aes Cipher/Decipher`);
  logger.log("");

  myApplication.runAesLogic();

  logger.log("");
  logger.log(`#`);
  logger.log(`# test: print js string inside wasm logic`);
  logger.log("");

  myApplication.makeWasmPrintMessage("Hello from JavaScript!");

  logger.log("");
  logger.log(`#`);
  logger.log(`# test: get wasm allocated string as js variable`);
  logger.log("");

  const message = myApplication.getHeapString();

  logger.log(`wasm text printed in the JS code: "${message}"`);

  logger.log("");
  logger.log(`# LOGIC END`);
  logger.log(`#`);

};

window.addEventListener("load", onGlobalPageLoad);
