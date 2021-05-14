class Tile {
	String state = "safe";
	PVector pos;
	int bombsNearby = 0;
	boolean flagged = false;
	boolean cleared = false;
	boolean changed = false;

	String stateAI = "null";
	boolean flag = false;
	boolean remove = false;
	boolean checking = false;
	boolean unknown = false;

	Tile(float x, float y) {
		pos = new PVector(x, y);
	}

	void show() {
		if (won) {
			// on win show all tiles
			cleared = true;
		}

		// default tile settings
		fill(40);
		stroke(110);
		rect(pos.x, pos.y, tileSize, tileSize);

		if (cleared) {
			unknown = false;
			switch (state) {
				case "safe":
					if (bombsNearby > 0) {
						fill(200);
						rect(pos.x, pos.y, tileSize, tileSize);

						fill(20);
						textFont(tileFont);
						textAlign(CENTER, CENTER);
						text(bombsNearby, pos.x+tileSize/2+1, pos.y+tileSize/2+1);
					} else {
						fill(160);
						rect(pos.x, pos.y, tileSize, tileSize);
					}
					break;
				case "bomb":
					fill(230, 30, 75);
					rect(pos.x, pos.y, tileSize, tileSize);
					break;
			}
		}
		if (flagged) {
			unknown = false;
			fill(60, 80, 180);
			rect(pos.x, pos.y, tileSize, tileSize);

			fill(20);
			textFont(tileFont);
			textAlign(CENTER, CENTER);
			text("F", pos.x+tileSize/2+1, pos.y+tileSize/2+1);

			if (lost && state == "safe") {
				stroke(230, 30, 75);
				line(pos.x, pos.y, pos.x+tileSize, pos.y+tileSize);
				line(pos.x, pos.y+tileSize, pos.x+tileSize, pos.y);
			}
		}
		if (flag) {
			fill(10, 50, 230, 60);
			rect(pos.x, pos.y, tileSize, tileSize);
		}
		else if (remove) {
			fill(230, 30, 75, 40);
			rect(pos.x, pos.y, tileSize, tileSize);
		}
		else if (unknown) {
			fill(10, 230, 100, 40);
			rect(pos.x, pos.y, tileSize, tileSize);
		}
	}
}

