---@meta

--- Module `lapis.util.encoding`
---
--- [Functions](https://leafo.net/lapis/reference/utilities.html#encoding-methods)
local encoding = {}

--- Base64 encodes a string.
---@param str string
---@return string
function encoding.encode_base64(str) end

--- Base64 decodes a string.
---@param str string
---@return string
function encoding.decode_base64(str) end

--- Calculates the hmac-sha1 digest of `str` using `secret`.
--- Returns a binary string.
---@param secret string
---@param str string
---@return string
function encoding.hmac_sha1(secret, str) end

--- Encodes a Lua object and generates a signature for it.
--- Returns a single string that contains the encoded object and signature.
---
--- `secret` defaults to `config.secret`.
---@param object any
---@param secret? string
---@return string
function encoding.encode_with_secret(object, secret) end

--- Decodes a string created by `encode_with_secret`. The decoded object is only
--- returned if the signature is correct. Otherwise returns `nil` and an error
--- message. The secret must match what was used with `encode_with_secret`.
---
--- `secret` defaults to `config.secret`.
---@param msg_and_sig string
---@param secret? string
---@return any?
---@return string?
function encoding.decode_with_secret(msg_and_sig, secret) end

return encoding
