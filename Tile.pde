class Tile {
	String state = "safe";
	PVector pos;
	boolean flagged = false;
	boolean cleared = false;
	boolean changed = false;
	int bombsNearby = 0;

	Tile(float x, float y) {
		pos = new PVector(x, y);
	}

	void show() {
		if (gameover) {
			// If game lost show all bombs
			cleared = true;
		}

		// default tile settings
		fill(40);
		stroke(110);
		rect(pos.x, pos.y, tileSize, tileSize);

		if (cleared) {
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
	}
}

