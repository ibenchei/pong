push = require 'push'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
PADDLE_SPEED = 200

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    --use the current time, will vary on startup
    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 30)
    scoreFont = love.graphics.newFont('font.ttf', 32)
 
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    player1Score = 0
    player2Score = 0

    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 50

    --velocity and position variables for our ball when play starts
    ballX = VIRTUAL_WIDTH / 2 - 2
    ballY = VIRTUAL_HEIGHT / 2 - 2

    --math.random returns a random value between the left and right number DX/DY delta x and delta y
    ballDX = math.random(2) == 1 and 100 or -100
    ballDY = math.random(-50, 50)

    --game state variable used to transition between different parts of the game
    --used for beginning, menus, main game, high score list, etc)
    --we will use this to determine behavior during render and update
    gameState = 'start' 
end

function love.update(dt)
    if love.keyboard.isDown('w') then
        player1Y = math.max(0, player1Y + -PADDLE_SPEED * dt)
        --add negative paddle speed to current Y scaled by dt
        --now, we clamp our position between the bounds of the screen
        --math.max returns the greater of two values; 0 and player Y
        --will ensure we don't go above it
    elseif love.keyboard.isDown('s') then
        player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED * dt)
        --add positive paddle speed to current Y scaled by dt
        --math.min returns the lesser of two values; bottom of the egde minus paddle
        --and player Y will ensure we don't go below it
    end
    if love.keyboard.isDown('up') then
        --add a negative paddle speed to current Y scaled by dt
        player2Y = math.max(0, player2Y + -PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('down') then
        --add a positive paddle speed to current Y scaled by dt
        player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
    end

    --update our ball based on its DX and DY only if we're in play state;
    --scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then
        ballX = ballX + ballDX * dt
        ballY = ballY + ballDY * dt
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    --if we press enter during the start state of the game, we'll go into play mode
    --during play mode, the ball will move in a random direction
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'

            --start ball's position in the middle of the screen
            ballX = VIRTUAL_WIDTH / 2 - 2
            ballY = VIRTUAL_HEIGHT / 2 - 2

            --given ball's x and y velocity a random starting value
            --the and/or pattern here is Lua's way of accomplishing a ternary
            --in other programming language live C
            ballDX = math.random(2) == 1 and 100 or -100
            --in c : math.random(2) == 1 ? 100 : -100
            ballDY = math.random(-50, 50) * 1.5
        end
    end
end

function love.draw()
    push:apply('start')
    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.printf('Ping Pong!', 0, 4, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf('Play State', 0 , 20, VIRTUAL_WIDTH, 'center')
    end
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    --render first paddle (left side)
    love.graphics.rectangle('fill', 10, player1Y, 5, 20)
    --render second paddle (right side)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)
    --render ball
    love.graphics.rectangle('fill', ballX, ballY, 4, 4)
    push:apply('end')
end

-- function love.load()
-- love.graphics.clear(40, 45, 52, 255) debut love.draw // gris fonctionne pas
--     love.graphics.setDefaultFilter('nearest', 'nearest')
-- love.graphics.printf('press Enter', VIRTUAL_WIDTH - 20, 4, VIRTUAL_HEIGHT, 'center')