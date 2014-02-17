function Downloader() {}

if ($ua.iP) {
	Downloader.events = {};

	Downloader.preload = function(url, params, win, fail) {
		this.events[url] = {
			complete: win,
			error: fail
		};
		
		cordova.exec("Downloader.preload", url, params.fileName, params.dirName,
			params.Forced || false);
	};

	Downloader.complete = function(pURL, pPath) {
		var vObj = this.events[pURL];
		if (vObj && vObj.complete)
			vObj.complete(pPath);
	};

	Downloader.error = function(pURL, pPath) {
		var vObj = this.events[pURL];
		if (vObj && vObj.error)
			vObj.error(pPath);
	};

}

if ($ua.droid)
	Downloader.preload = function(fileUrl, params, win, fail) {
		cordova.exec(win, fail, "Downloader", "preload", [fileUrl, params]);
	};


Downloader.prototype.install = function() {
	if (Downloader.preload)
		$log.warn('Plugin Downloader do not loaded corectly');

	if(!window.plugins)
		window.plugins = {};

	window.plugins.downloader = new Downloader();
};

module.exports = new Downloader();