/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

declare global {
  // Webpack asset modules.
  // Should match extensions used in webpack config.
  declare module '*.png' {
    const content: string;
    export default content;
  }

  declare module '*.jpg' {
    const content: string;
    export default content;
  }

  declare module '*.svg' {
    const content: string;
    export default content;
  }

  type TguiMessage = {
    type: string;
    payload?: any;
    [key: string]: any;
  };

  type ByondType = {
    /**
     * ID of the Byond window this script is running on.
     * Can be used as a parameter to winget/winset.
     */
    windowId: string;

    /**
     * True if javascript is running in BYOND.
     */
    IS_BYOND: boolean;

    /**
     * Version of Trident engine of Internet Explorer. Null if N/A.
     */
    TRIDENT: number | null;

    /**
     * Version of Blink engine of WebView2. Null if N/A.
     */
    BLINK: number | null;

    /**
     * Makes a BYOND call.
     *
     * If path is empty, this will trigger a Topic call.
     * You can reference a specific object by setting the "src" parameter.
     *
     * See: https://secure.byond.com/docs/ref/skinparams.html
     */
    call(path: string, params: object): void;

    /**
     * Makes an asynchronous BYOND call. Returns a promise.
     */
    callAsync(path: string, params: object): Promise<any>;

    /**
     * Makes a Topic call.
     *
     * You can reference a specific object by setting the "src" parameter.
     */
    topic(params: object): void;

    /**
     * Runs a command or a verb.
     */
    command(command: string): void;

    /**
     * Retrieves all properties of the BYOND skin element.
     *
     * Returns a promise with a key-value object containing all properties.
     */
    winget(id: string | null): Promise<object>;

    /**
     * Retrieves all properties of the BYOND skin element.
     *
     * Returns a promise with a key-value object containing all properties.
     */
    winget(id: string | null, propName: '*'): Promise<object>;

    /**
     * Retrieves an exactly one property of the BYOND skin element,
     * as defined in `propName`.
     *
     * Returns a promise with the value of that property.
     */
    winget(id: string | null, propName: string): Promise<any>;

    /**
     * Retrieves multiple properties of the BYOND skin element,
     * as defined in the `propNames` array.
     *
     * Returns a promise with a key-value object containing listed properties.
     */
    winget(id: string | null, propNames: string[]): Promise<object>;

    /**
     * Assigns properties to BYOND skin elements.
     */
    winset(props: object): void;

    /**
     * Assigns properties to the BYOND skin element.
     */
    winset(id: string | null, props: object): void;

    /**
     * Sets a property on the BYOND skin element to a certain value.
     */
    winset(id: string | null, propName: string, propValue: any): void;

    /**
     * Parses BYOND JSON.
     *
     * Uses a special encoding to preverse Infinity and NaN.
     */
    parseJson(text: string): any;

    /**
     * Sends a message to `/datum/tgui_window` which hosts this window instance.
     */
    sendMessage(type: string, payload?: any): void;
    sendMessage(message: TguiMessage): void;

    /**
     * Subscribe to incoming messages that were sent from `/datum/tgui_window`.
     */
    subscribe(listener: (type: string, payload: any) => void): void;

    /**
     * Subscribe to incoming messages *of some specific type*
     * that were sent from `/datum/tgui_window`.
     */
    subscribeTo(type: string, listener: (payload: any) => void): void;

    /**
     * Loads a stylesheet into the document.
     */
    loadCss(url: string): void;

    /**
     * Loads a script into the document.
     */
    loadJs(url: string): void;
  };

  /**
   * Object that provides access to Byond Skin API and is available in
   * any tgui application.
   */
  const Byond: ByondType;

  interface Window {
    /**
     * ID of the Byond window this script is running on.
     * Should be used as a parameter to winget/winset.
     */
    Byond: ByondType;
    __store__: Store<unknown, AnyAction>;
    __augmentStack__: (store: Store) => StackAugmentor;

    // IE IndexedDB stuff.
    msIndexedDB: IDBFactory;
    msIDBTransaction: IDBTransaction;

    // 516 byondstorage API.
    hubStorage: Storage;
    domainStorage: Storage;
    serverStorage: Storage;
  }
}

export {};
