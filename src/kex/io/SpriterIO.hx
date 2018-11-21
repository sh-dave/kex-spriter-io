package kex.io;

import kex.io.AssetLog.*;
import kex.io.BlobIO;
import kex.io.CoreIOUtils;
import spriter.Spriter;

using tink.CoreApi;

class SpriterIO {
	var blobs: BlobIO;

	var cachedAssets: Map<String, Spriter> = new Map();
	var loadingAssets: Map<String, Array<FutureTrigger<Outcome<Spriter, Error>>>> = new Map();
	var urlToScope: Map<String, Array<String>> = new Map();

	public function new( blobs: BlobIO )
		this.blobs = blobs;

	public function get( scope: String, path: String, file: String ) : Promise<Spriter> {
		var url = CoreIOUtils.tagAsset(urlToScope, scope, path, file);
		var cached = cachedAssets.get(url);
		var f = Future.trigger();

		asset_info('queue spriter `$url` for scope `$scope`');

		if (cached != null) {
			asset_info('already cached spriter `$url`, adding scope `$scope`');
			f.trigger(Success(cached));
			return f;
		}

		var loading = loadingAssets.get(url);

		if (loading != null) {
			asset_info('already loading spriter `$url`, adding scope `$scope`');
			loading.push(f);
			return f;
		}

		asset_info('loading spriter `$url` for scope `$scope`');
		loadingAssets.set(url, [f]);

		return blobs.get(scope, path, file)
			.next(function( blob ) {
				var spriter = Spriter.parseScml(blob.toString());
				cachedAssets.set(url, spriter);

				for (t in loadingAssets.get(url)) {
					t.trigger(Success(spriter));
				}

				loadingAssets.remove(url);
				return spriter;
			});
	}

	public function unloadScope( scope: String ) {
		for (url in urlToScope.keys()) {
			var scopes = urlToScope.get(url);

			if (scopes.indexOf(scope) != -1) {
				unload(scope, url);
			}
		}
	}

	function unload( scope: String, url: String ) {
		var scopes = urlToScope.get(url);

		asset_info('unscoping spriter `$url` for `$scope`');
		scopes.remove(scope);

		if (scopes.length == 0) {
			asset_info('unloading spriter `$url`');
			cachedAssets.remove(url);
			blobs.unloadBlob(scope, url);
		}
	}
}
