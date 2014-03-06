function Downloader() {}

if ($ua.iP()) {
	Downloader.events = {};

	Downloader.prototype.preload = function(url, params, win, fail) {
		Downloader.events[url] = {
			complete: win,
			error: fail
		};

		cordova.exec(win, fail, "Downloader", "preload",
		             [url, params.fileName, params.dirName, params.Forced || false]);
	};

	Downloader.prototype.complete = function(pURL, pPath) {
		var vObj = Downloader.events[pURL];
		if (vObj && vObj.complete)
			vObj.complete(pPath);
	};

	Downloader.prototype.error = function(pURL, pPath) {
		var vObj = Downloader.events[pURL];
		if (vObj && vObj.error)
			vObj.error(pPath);
	};

}

if ($ua.droid())
	Downloader.prototype.preload = function(fileUrl, params, win, fail) {
		cordova.exec(win, fail, "Downloader", "preload", [fileUrl, params]);
	};


Downloader.prototype.install = function() {
	if(!window.plugins)
		window.plugins = {};

	window.plugins.downloader = new Downloader();
};

module.exports = new Downloader();