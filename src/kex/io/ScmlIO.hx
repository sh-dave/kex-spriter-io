package kex.io;

import spriter.Spriter;

class ScmlIO extends GenericIO<Spriter> {
	var blobs: BlobIO;

	public function new( blobs: BlobIO ) {
		super('scml');
		this.blobs = blobs;
	}

	override function onResolve( scope: String, path: String, file: String )
		return blobs.get(scope, path, file).next(blob -> Spriter.parseScml(blob.toString()));
}
