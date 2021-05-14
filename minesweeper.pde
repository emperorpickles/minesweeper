int tilesX = 80;
int tilesY = 50;
int numBombs = 600;

int tileSize = 20;

int width = tilesX*tileSize;
int height = tilesY*tileSize;
int winWidth = max(300, width+1);
int winHeight = max(300, height+26);

int aiButtonX = winWidth/2-50;
int aiButtonY = winHeight-24;
int aiButtonWidth = 100;
int aiButtonHeight = 21;

int[][] directions = {{-1,-1}, {-1,0}, {-1,1}, {0,1}, {1,1}, {1,0}, {1,-1}, {0,-1}};
Tile[][] tiles = new Tile[tilesX][tilesY];

AI ai;
boolean enableAI = false;
boolean debug = true;

int bombsLeft = numBombs;

boolean gameover = false;
boolean lost = false;
boolean won = false;
boolean reset = false;
PFont tileFont;
PFont titleFont;

//-----------------------------------------------

void settings() {
	size(winWidth, winHeight);
}

void setup() {
	frameRate(60);
	tileFont = loadFont("AgencyFB-Bold-15.vlw");
	titleFont = createFont("Gargi", winWidth/6);

	createBoard();
	ai = new AI();
}

//-----------------------------------------------

void draw() {
	background(120);
	toolbar();

	for (int i = 0; i < tilesX; i++) {
		for (int j = 0; j < tilesY; j++) {
			tiles[i][j].show();
			tiles[i][j].checking = false;
		}
	}

	if (!gameover && enableAI) {
		ai.move();
	}

	if (lost) {
		fill(20);
		textFont(titleFont);
		textAlign(CENTER, CENTER);
		text("Gameover!", winWidth/2+8, winHeight/2-26);
	}
	if (won) {
		fill(20);
		textFont(titleFont);
		textAlign(CENTER, CENTER);
		text("Winner!", winWidth/2+8, winHeight/2-26);
	}

	if (debug) {
		debugOverlay();
	}
}

//-----------------------------------------------

void createBoard() {
	// create board
	for (int i = 0; i < tilesX; i++) {
		for (int j = 0; j < tilesY; j++) {
			tiles[i][j] = new Tile(i*tileSize, j*tileSize);
		}
	}

	// populate board with bombs
	for (int i = 0; i < numBombs; i++) {
		int x = floor(random(tilesX));
		int y = floor(random(tilesY));
		// if tile already has a bomb find new tile
		while (tiles[x][y].state == "bomb") {
			x = floor(random(tilesX));
			y = floor(random(tilesY));
		}
		tiles[x][y].state = "bomb";

		// increment bomb count for nearby tiles
		for (int[] direction : directions) {
			int cx = x + direction[0];
			int cy = y + direction[1];
			if (cx >= 0 && cx < tilesX && cy >= 0 && cy < tilesY) {
				tiles[cx][cy].bombsNearby++;
			}
		}
	}
	bombsLeft = numBombs;
}

//-----------------------------------------------

void toolbar() {
	if (enableAI) {
		fill(230, 30, 75);
		rect(aiButtonX, aiButtonY, aiButtonWidth, aiButtonHeight);	
	} else {
		fill(200);
		rect(aiButtonX, aiButtonY, aiButtonWidth, aiButtonHeight);
	}

	fill(20);
	textFont(tileFont, 15);
	textAlign(CENTER, CENTER);
	text("Bombs Left: " + bombsLeft, winWidth/6, winHeight-12);
	text("Press \"r\" to restart", winWidth-winWidth/6, winHeight-12);
	text("AI MODE", winWidth/2, winHeight-12);
}

//-----------------------------------------------

void mousePressed() {
	if (mouseX >= aiButtonX && mouseX <= aiButtonX+aiButtonWidth &&
			mouseY >= aiButtonY && mouseY <= aiButtonY+aiButtonHeight) {
		enableAI = !enableAI;
		return;
	}
	// make sure mouse is inside board
	if (mouseX > width || mouseY > height) {
		return;
	}

	int mousePosX = floor(mouseX / tileSize);
	int mousePosY = floor(mouseY / tileSize);

	if (mouseButton == LEFT) {
		tileClicked(mousePosX, mousePosY);
	}

	if (mouseButton == RIGHT) {
		tileFlagged(mousePosX, mousePosY);
	}
}

void keyPressed() {
	switch (key) {
		case 'r':
			println("reset");
			reset = true;
			gameover = false;
			won = false;
			lost = false;
			createBoard();
	}
}

//-----------------------------------------------

void tileFlagged(int i, int j) {
	Tile tile = tiles[i][j];
	if (tile.cleared) return;
	else {
		tile.flagged = !tile.flagged;
		tile.changed = !tile.changed;
		if (!tile.flagged) {
			bombsLeft++;
		} else {
			bombsLeft--;
		}
		if (bombsLeft == 0) {
			// check that all flags are correct
			int correctFlags = 0;
			for (int ci = 0; ci < tilesX; ci++) {
				for (int cj = 0; cj < tilesY; cj++) {
					if (tiles[ci][cj].flagged && tiles[ci][cj].state == "bomb") {
						correctFlags++;
					}
				}
			}
			if (correctFlags == numBombs) {
				gameover = true;
				won = true;
			}
		}
	}
}

//-----------------------------------------------

void tileClicked(int i, int j) {
	Tile tile = tiles[i][j];
	// ignore flagged tiles
	if (tile.flagged) {
		return;
	}

	tile.cleared = true;
	tile.changed = true;
	// if tile was a bomb then gameover
	if (tile.state == "bomb") {
		gameover = true;
		lost = true;
		return;
	}
	// if tile was zero clear all nearby tiles
	if (tile.bombsNearby == 0 && tile.state == "safe") {
		clearEmpty(i, j);	
	}
}

//-----------------------------------------------

void clearEmpty(int x, int y) {
	for (int[] direction : directions) {
		int cx = x + direction[0];
		int cy = y + direction[1];
		if (cx >= 0 && cx < tilesX && cy >= 0 && cy < tilesY && tiles[cx][cy].changed == false) {
			tileClicked(cx, cy);
		}
	}
}

//-----------------------------------------------

void debugOverlay() {
	boolean overlay = false;
	if (keyPressed) {
		if (key == 'd' || key == SHIFT) {
			overlay = !overlay;
		}
	}
	if (mouseX > width || mouseY > height || mouseX < 0 || mouseY < 0) {
		return;
	}
	else if (overlay == true) {
		int mousePosX = min(floor(mouseX / tileSize), 16);
		int mousePosY = min(floor(mouseY / tileSize), 16);
		Tile tile = tiles[mousePosX][mousePosY];

		fill(200);
		rect(mouseX+14, mouseY, 80, 100);

		fill(20);
		textFont(tileFont, 15);
		textAlign(LEFT, TOP);
		text("cleared: " + tile.cleared, mouseX+18, mouseY+2);
		text("changed: " + tile.changed, mouseX+18, mouseY+16);
		text("stateAI: " + tile.stateAI, mouseX+18, mouseY+30);
		text("checking: " + tile.checking, mouseX+18, mouseY+44);
		text("flag: " + tile.flag, mouseX+18, mouseY+58);
		text("remove: " + tile.remove, mouseX+18, mouseY+72);
		text("unknown: " + tile.unknown, mouseX+18, mouseY+86);
	}
}