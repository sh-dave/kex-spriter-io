package kex.io;

import spriter.Spriter;

class ScmlIO extends GenericIO<Spriter> {
	var blobs: BlobIO;

	public function new( blobs: BlobIO ) {
		super('scml');
		this.blobs = blobs;
	}

	override function onResolve( url: String, ?opts )
		return blobs.get(url, opts)
			.next(blob -> Spriter.parseScml(blob.toString()));
}
