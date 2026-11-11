extends RefCounted
static func available(config: Dictionary) -> bool:
 var pattern := RegEx.new()
 pattern.compile("^[A-Za-z][A-Za-z0-9_]*(\\.[A-Za-z][A-Za-z0-9_]*)+$")
 return config.get("published") == true and config.get("listing_verified") == true and pattern.search(str(config.get("package_id",""))) != null

static func open_listing(config: Dictionary, opener: Callable, android: bool) -> bool:
 if not available(config): return false
 var id: String = str(config.package_id).uri_encode()
 if android and opener.call("market://details?id="+id) == OK: return true
 return opener.call("https://play.google.com/store/apps/details?id="+id) == OK
