class AI {
	int pixelX;
	int pixelY;
	boolean flag;
	int[] corners = {0, 0, tilesX-1, tilesY-1};
	ArrayList<PVector> targets = new ArrayList<PVector>();
	ArrayList<PVector> nearbyHidden = new ArrayList<PVector>();

	boolean hasTarget = false;
	boolean firstMove = true;
	int cursorSpeed = 200;

	PVector pos = new PVector(width/2, height/2);

	//-----------------------------------------------

	void reset() {
		firstMove = true;
		targets.clear();
	}

	//-----------------------------------------------

	void move() {
		if (reset) {
			firstMove = true;
			targets.clear();
			reset = false;
		}

		// get list of targets
		if (targets.size() == 0) {
			// randomTarget();
			smartTarget();
		}

		// assign current target
		if (targets.size() > 0 && !hasTarget) {
			int x = (int)(targets.get(0).x);
			int y = (int)(targets.get(0).y);
			pixelX = x*tileSize+tileSize/2;
			pixelY = y*tileSize+tileSize/2;

			if (targets.get(0).z == 1) {
				flag = true;
			} else {
				flag = false;
			}
			println("\nTARGETS");
			for (int i = 0; i < targets.size(); i++) {
				println(String.format("xy: (%d,%d), flag: %d", 
									(int)(targets.get(i).x)+1, (int)(targets.get(i).y)+1, (int)(targets.get(i).z)));
			}
			hasTarget = true;
		}

		// draw and move cursor, clicking target once arrived
		if (hasTarget) {
			if (dist(pos.x, pos.y, pixelX, pixelY) > 2) {
				PVector vel = new PVector((pixelX) - pos.x, (pixelY) - pos.y);
				vel.limit(cursorSpeed);
				pos.add(vel);
			} else {
				click((int)(targets.get(0).x), (int)(targets.get(0).y), flag);
				targets.remove(0);
			}
		}
		fill(255);
		circle(pos.x, pos.y, 20);
	}

	//-----------------------------------------------

	void click(int x, int y, boolean flag) {
		Tile tile = tiles[x][y];
		if (flag) {
			tileFlagged(x, y);
			tile.flag = false;
		} else {
			tileClicked(x, y);
			tile.remove = false;
		}
		hasTarget = false;
		firstMove = false;
	}

	//-----------------------------------------------

	void randomTarget() {
		// first try all corners
		for (int i = 0; i < 4; i++) {
			int x = min(corners[(int)random(0,3)], tilesX-1);
			int y = min(corners[(int)random(0,3)], tilesY-1);
			if (!tiles[x][y].changed) {
				targets.add(new PVector(x, y, 0));
				return;
			}
		}
		// last resort random choice
		int x = (int)random(tilesX);
		int y = (int)random(tilesY);
		if (!tiles[x][y].changed) {
			targets.add(new PVector(x, y, 0));
		}
	}

	//-----------------------------------------------

	void smartTarget() {
		// top left corner is always first move
		if (firstMove) {
			randomTarget();
		} else {
			println("\nlooking for targets");
			for (int x = 0; x < tilesX; x++) {
				for (int y = 0; y < tilesY; y++) {
					Tile tile = tiles[x][y];
					if (tile.cleared && tile.bombsNearby > 0) {
						tiles[x][y].checking = true;
						checkHidden(x,y);
					}
				}
			}
			// if nothing else, choose a random target
			if (targets.size() == 0) {
				println("targeting random");
				randomTarget();
			}
		}
	}

	//-----------------------------------------------

	void checkHidden(int x, int y) {
		Tile tile = tiles[x][y];

		nearbyHidden.clear();
		for (int[] direction : directions) {
			int cx = x + direction[0];
			int cy = y + direction[1];
			if (validTile(cx,cy) && !tiles[cx][cy].cleared) {
				// tiles[cx][cy].searching = true;
				nearbyHidden.add(new PVector(cx, cy, 1));
			}
		}

		if (nearbyHidden.size() > 0) {
			for (int i = 0; i < nearbyHidden.size(); i++) {
				int flags = 0;
				int cx = (int)(nearbyHidden.get(i).x);
				int cy = (int)(nearbyHidden.get(i).y);
				Tile target = tiles[cx][cy];
				target.unknown = true;

				// all hidden tiles must be bombs
				if (nearbyHidden.size() == tile.bombsNearby && target.stateAI == "null") {
					targets.add(new PVector(cx, cy, 1));
					target.stateAI = "flag";
					target.flag = true;
					println("---TARGET ADDED---");
					return;
				}

				for (int j = 0; j < nearbyHidden.size(); j++) {
					int ci = (int)(nearbyHidden.get(j).x);
					int cj = (int)(nearbyHidden.get(j).y);
					if (tiles[ci][cj].stateAI == "flag" || tiles[ci][cj].flagged) {
						flags++;
					}
				}
				if (tile.bombsNearby == flags && target.stateAI == "null") {
					targets.add(new PVector(cx, cy, 0));
					target.stateAI = "remove";
					target.remove = true;
					println("---TARGET ADDED---");
					return;
				}
				println(String.format("TILE(xy: (%d,%d), flags: %d) ---- TARGET(xy: (%d,%d))",
															x+1, y+1, flags, cx+1, cy+1));
			}
		}
	}

	//-----------------------------------------------

	boolean validTile(int x, int y) {
		if (x >= 0 && x < tilesX && y >= 0 && y < tilesY) return true;
		else return false;
	}
}