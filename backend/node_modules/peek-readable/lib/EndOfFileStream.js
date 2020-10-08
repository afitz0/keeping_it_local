"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.defaultMessages = 'End-Of-Stream';
/**
 * Thrown on read operation of the end of file or stream has been reached
 */
class EndOfStreamError extends Error {
    constructor() {
        super(exports.defaultMessages);
    }
}
exports.EndOfStreamError = EndOfStreamError;
//# sourceMappingURL=EndOfFileStream.js.map