import java.awt.geom.Point2D.Float;
import java.awt.Point;
import java.util.Vector;

//-----------------------------------------------
// standard board settings
//-----------------------------------------------
// beginner
// int tilesX = 9;
// int tilesY = 9;
// int numBombs = 10;
//-----------------------------------------------
// intermediate
int tilesX = 16;
int tilesY = 16;
int numBombs = 40;
//-----------------------------------------------
// expert
// int tilesX = 30;
// int tilesY = 16;
// int numBombs = 99;
//-----------------------------------------------
// custom
// int tilesX = 80;
// int tilesY = 48;
// int numBombs = 600;
//-----------------------------------------------

// game settings
int tileSize = 40;
int gameSpeed = 60;

// AI settings
AI ai;
boolean enableAI = false;
boolean enableCursor = false;
int cursorSpeed = 10;
boolean debug = false;

// logging settings
boolean logResults = true;
StringList results = new StringList();
int gameNum = 0;
int maxGames = 100;
int wins = 0;
int losses = 0;

// gamestate
boolean gameover = false;
boolean lost = false;
boolean won = false;
boolean reset = false;

// set variables
int width = tilesX*tileSize;
int height = tilesY*tileSize;
int winWidth = max(300, width+1);
int winHeight = max(300, height+26);

PFont tileFont;
PFont titleFont;

int[][] directions = {{-1,-1}, {-1,0}, {-1,1}, {0,1}, {1,1}, {1,0}, {1,-1}, {0,-1}};
Tile[][] tiles = new Tile[tilesX][tilesY];
int bombsLeft = numBombs;

// buttons
int[] aiButton = {winWidth/2-50, winHeight-24, 100, 21};
int[] cButton = {winWidth/2+55, winHeight-24, 80, 21};

//-----------------------------------------------

void settings() {
	size(winWidth, winHeight);
}

void setup() {
	frameRate(gameSpeed);
	tileFont = loadFont("AgencyFB-Bold-15.vlw");
	titleFont = createFont("Gargi", winWidth/6);

	createBoard();
	ai = new AI();
	results.append("moves, guesses, result");
}

//-----------------------------------------------
// helper functions

void aiMove() {
	ai.move();
}

void gameReset() {
	println("reset");
	reset = true;
	gameover = false;
	won = false;
	lost = false;
	createBoard();
	if (enableAI) thread("aiMove");
}

//-----------------------------------------------

void logMode() {
	if (gameNum < maxGames) {
		if (!enableAI) {
			enableAI = true;
			thread("aiMove");
		}
		if (gameover) {
			int aiMoves = (int)ai.gameMoves().x;
			int aiGuesses = (int)ai.gameMoves().y;
			if (aiMoves == 1) {
				gameReset();
				return;
			}
			gameNum++;
			String moveGuess = String.format("%d, %d, ", aiMoves, aiGuesses);
			if (won) {
				results.append(moveGuess + "won");
				wins++;
			}
			else if (lost) {
				results.append(moveGuess + "lost");
				losses++;
			}
			gameReset();
		}
	}
	else if (gameNum == maxGames) {
		float winPercent = (float)wins/maxGames;
		println("winPercent: "+winPercent*100);
		println("saving results");
		saveStrings("results.txt", results.array());
		gameNum++;
	}
}

//-----------------------------------------------

void draw() {
	background(120);
	toolbar();

	for (int i = 0; i < tilesX; i++) {
		for (int j = 0; j < tilesY; j++) {
			tiles[i][j].show();
		}
	}

	if (logResults) {
		logMode();
	}

	if (!gameover && enableAI) {
		if (enableCursor) {
			Float pos = ai.cursorPos();
			fill(255);
			circle(pos.x, pos.y, 20);
		}
	}

	if (gameover) {
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
		rect(aiButton[0], aiButton[1], aiButton[2], aiButton[3]);	
	} else {
		fill(200);
		rect(aiButton[0], aiButton[1], aiButton[2], aiButton[3]);
	}
	if (enableCursor) {
		fill(230, 30, 75);
		rect(cButton[0], cButton[1], cButton[2], cButton[3]);	
	} else {
		fill(200);
		rect(cButton[0], cButton[1], cButton[2], cButton[3]);
	}

	fill(20);
	textFont(tileFont, 15);
	textAlign(CENTER, CENTER);
	text("Bombs Left: " + bombsLeft, winWidth/6, winHeight-12);
	text("Press \"r\" to restart", winWidth-winWidth/6, winHeight-12);
	text("AI MODE", winWidth/2, winHeight-12);
	text("CURSOR", cButton[0]+cButton[2]/2, winHeight-12);
}

//-----------------------------------------------

void mousePressed() {
	if (buttonClick(aiButton)) {
		enableAI = !enableAI;
		if (enableAI) thread("aiMove");
		return;
	}
	else if (buttonClick(cButton)) {
		println("\nMODE CHANGE");
		enableCursor = !enableCursor;
		ai.reset();
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

boolean buttonClick(int[] coords) {
	int x = coords[0];
	int y = coords[1];
	int width = coords[2];
	int height = coords[3];
	if (mouseX >= x && mouseX <= x+width &&
			mouseY >= y && mouseY <= y+height) {
		return true;
	} else return false;
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
			if (enableAI) thread("aiMove");
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
				println("VICTORY");
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
		println("GAMEOVER");
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
		int mousePosX = floor(mouseX / tileSize);
		int mousePosY = floor(mouseY / tileSize);
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