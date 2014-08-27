#!/usr/bin/env python
# snake.py
import pygame, sys, time, random
from pygame.locals import *

pygame.init()
fpsClock = pygame.time.Clock()
playSurface = pygame.display.set_mode((640, 480))
pygame.display.set_caption('Raspberry Snake')
redColour = pygame.Color(255, 0, 0)
blackColour = pygame.Color(0, 0, 0)
whiteColour = pygame.Color(255, 255, 255)
greyColour = pygame.Color(150, 150, 150)
snakeposition = [100, 100]
snakesegments = [[100, 100], [80, 100], [60, 100]]
raspberryposition = [300, 300]
raspberrySpawned = 1
direction = 'right'
changedirection = direction

def gameover():
	gameOverFont = pygame.font.Font('freesansbold.ttf', 72)
	gameOverSurf = gameOverFont.render('Game Over', True, greyColour)
	gameOverRect = gameOverSurf.get_rect()
	gameOverRect.midtop = (320, 10)
	playSurface.blit(gameOverSurf, gameOverRect)
	pygame.display.flip()
	time.sleep(3)

running = True
while running:
	playSurface.fill(blackColour)
	
	for event in pygame.event.get():
		if event.type == pygame.QUIT:
			running = False
		elif event.type == KEYDOWN:
			if event.key == K_RIGHT or event.key == ord('d'):
				changedirection = 'right'
			if event.key == K_LEFT or event.key == ord('a'):
				changedirection = 'left'
			if event.key == K_UP or event.key == ord('w'):
				changedirection = 'up'
			if event.key == K_DOWN or event.key == ord('s'):
				changedirection = 'down'
			if event.key == K_ESCAPE:
				pygame.event.post(pygame.event.Event(QUIT))


	if changedirection == 'up' and not direction == 'down':
		direction = changedirection
	if changedirection == 'down' and not direction == 'up':
		direction = changedirection    
	if changedirection == 'left' and not direction == 'right':
		direction = changedirection
	if changedirection == 'right' and not direction == 'left':
		direction = changedirection

	if direction == 'right':
		snakeposition[0] += 20
	if direction == 'left':
		snakeposition[0] -= 20
	if direction == 'up':
		snakeposition[1] -= 20
	if direction == 'down':
		snakeposition[1] += 20

	snakesegments.insert(0,list(snakeposition))
	if snakeposition[0] == raspberryposition[0] and snakeposition[1] == raspberryposition[1]:
		raspberrySpawned = 0
	else:
		snakesegments.pop()

	if not raspberrySpawned:
		x = random.randrange(1,32)
		y = random.randrange(1,24)
		raspberryposition = [int(x*20),int(y*20)]
		raspberrySpawned = 1

	for position in snakesegments:
		pygame.draw.rect(playSurface,whiteColour,Rect(position[0], position[1], 20, 20))

	pygame.draw.rect(playSurface,redColour,Rect(raspberryposition[0], raspberryposition[1], 20, 20))  

	if snakeposition[0] > 620 or snakeposition[0] < 0:
		gameover()
		running = False
	if snakeposition[1] > 460 or snakeposition[1] < 0:
		gameover()
		running = False   

	for snakeBody in snakesegments[1:]:
		if snakeposition[0] == snakeBody[0] and snakeposition[1] == snakeBody[1]:
			gameover()
			running = False
	 
	pygame.display.flip()
	fpsClock.tick(20)
	
pygame.quit()