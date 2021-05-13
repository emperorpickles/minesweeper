int tilesX = 16;
int tilesY = 16;
int numBombs = 32;

int tileSize = 40;

int width = tilesX*tileSize;
int height = tilesY*tileSize;

int winWidth = max(300, width+1);
int winHeight = max(300, height+26);

Tile[][] tiles = new Tile[tilesX][tilesY];

boolean gameover = false;

int bombsLeft = numBombs;

boolean lost = false;
boolean won = false;
PFont tileFont;
PFont titleFont;

//-----------------------------------------------

void settings() {
	size(winWidth, winHeight);
}

void setup() {
	frameRate(300);
	tileFont = loadFont("AgencyFB-Bold-15.vlw");
	titleFont = createFont("Gargi", winWidth/6);

	createBoard();
}

//-----------------------------------------------

void draw() {
	background(120);
	fill(20);
	textFont(tileFont, 15);
	textAlign(CENTER, CENTER);
	text("Bombs Left: " + bombsLeft, winWidth/6, winHeight-12);
	text("Press \"r\" to restart", winWidth-winWidth/6, winHeight-12);

	for (int i = 0; i < tilesX; i++) {
		for (int j = 0; j < tilesY; j++) {
			tiles[i][j].show();
		}
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
		int[][] directions = {{-1,-1}, {-1,0}, {-1,1}, {0,1}, {1,1}, {1,0}, {1,-1}, {0,-1}};
		for (int[] direction : directions) {
			int cx = x + direction[0];
			int cy = y + direction[1];
			if (cx >= 0 && cx < tilesX && cy >= 0 && cy < tilesY) {
				tiles[cx][cy].bombsNearby++;
			}
		}
	}
}

//-----------------------------------------------

void mousePressed() {
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
			gameover = false;
			won = false;
			lost = false;
			createBoard();
	}
}

//-----------------------------------------------

void tileFlagged(int i, int j) {
	if (tiles[i][j].cleared) { return; }
	else {
		tiles[i][j].flagged = !tiles[i][j].flagged;
		if (!tiles[i][j].flagged) {
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
	// ignore flagged tiles
	if (tiles[i][j].flagged) {
		return;
	}

	tiles[i][j].cleared = true;
	tiles[i][j].changed = true;
	// if tile was a bomb then gameover
	if (tiles[i][j].state == "bomb") {
		gameover = true;
		lost = true;
		return;
	}
	// if tile was zero clear all nearby tiles
	if (tiles[i][j].bombsNearby == 0 && tiles[i][j].state == "safe") {
		clearEmpty(i, j);	
	}
}

//-----------------------------------------------

void clearEmpty(int x, int y) {
	int[][] directions = {{-1,-1}, {-1,0}, {-1,1}, {0,1}, {1,1}, {1,0}, {1,-1}, {0,-1}};
	for (int[] direction : directions) {
		int cx = x + direction[0];
		int cy = y + direction[1];
		if (cx >= 0 && cx < tilesX && cy >= 0 && cy < tilesY && tiles[cx][cy].changed == false) {
			tileClicked(cx, cy);
		}
	}
}