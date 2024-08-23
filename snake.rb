require 'gosu'

# Configurações do jogo
WIDTH = 800
HEIGHT = 600
CELL_SIZE = 25
GAME_SPEED = 0.1

# Classe da cobrinha
class Snake
  attr_accessor :direction, :body

  def initialize
    @direction = :right
    @body = [[4, 0], [3, 0], [2, 0], [1, 0]]
  end

  def move
    new_head = next_head
    @body.unshift(new_head)
    @body.pop
  end

  def next_head
    current_head = @body.first.dup
    case @direction
    when :up
      current_head[1] -= 1
    when :down
      current_head[1] += 1
    when :left
      current_head[0] -= 1
    when :right
      current_head[0] += 1
    end
    current_head
  end

  def grow
    @body << []
  end

  def hit_self?
    @body[1..-1][1] != @body.first.dup && @body[1..-2].include?(@body.first)
  end
end

# Classe do jogo
class GameWindow < Gosu::Window
  def initialize
    super(WIDTH, HEIGHT)
    self.caption = 'Jogo da Cobrinha'
    @snake = Snake.new
    @food = [random_x, random_y]
    @score = 0
    @font = Gosu::Font.new(30)
    @game_over = false
    @game_speed = GAME_SPEED
    @time_since_last_move = 0
  end

  def update
    return if @game_over

    @time_since_last_move += 1
    if @time_since_last_move >= (60 * @game_speed)
      @time_since_last_move = 0
      @snake.move
      check_collision
      check_food
    end
  end

  def draw
    draw_grid
    @snake.body.each { |segment| draw_cell(segment, Gosu::Color::GREEN) }
    draw_cell(@food, Gosu::Color::RED)
    draw_score
    draw_game_over if @game_over
  end

  def button_down(id)
    case id
    when Gosu::KbUp, Gosu::KbW
      @snake.direction = :up unless @snake.direction == :down
    when Gosu::KbDown, Gosu::KbS
      @snake.direction = :down unless @snake.direction == :up
    when Gosu::KbLeft, Gosu::KbA
      @snake.direction = :left unless @snake.direction == :right
    when Gosu::KbRight, Gosu::KbD
      @snake.direction = :right unless @snake.direction == :left
    when Gosu::KbR
      restart_game if @game_over
    when Gosu::KbEscape
      close
    end
  end

  private

  def draw_grid
    (0..WIDTH / CELL_SIZE).each do |x|
      draw_line(x * CELL_SIZE, 0, Gosu::Color::GRAY, x * CELL_SIZE, HEIGHT, Gosu::Color::GRAY)
    end
    (0..HEIGHT / CELL_SIZE).each do |y|
      draw_line(0, y * CELL_SIZE, Gosu::Color::GRAY, WIDTH, y * CELL_SIZE, Gosu::Color::GRAY)
    end
  end

  def draw_cell(position, color)
    if position.empty?
      x, y = @food
    else
      x, y = position
    end
    draw_rect(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE, color)
  end

  def draw_score
    @font.draw_text("Score: #{@score}", 10, 10, 0)
  end

  def draw_game_over
    @font.draw_text("Game Over", WIDTH / 2 - 80, HEIGHT / 2 - 15, 0)
    @font.draw_text("Press 'R' to restart", WIDTH / 2 - 130, HEIGHT / 2 + 20, 0)
  end

  def check_collision
    head = @snake.body.first
    if head[0] < 0 || head[0] >= WIDTH / CELL_SIZE || head[1] < 0 || head[1] >= HEIGHT / CELL_SIZE || @snake.hit_self?
      @game_over = true
    end
  end

  def check_food
    head = @snake.body.first
    if head == @food
      @snake.grow
      @score += 1
      @food = [random_x, random_y]
      increase_speed
    end
  end

  def increase_speed
    @game_speed *= 0.95 if @game_speed > 0.03
  end

  def random_x
    rand(WIDTH / CELL_SIZE)
  end

  def random_y
    rand(HEIGHT / CELL_SIZE)
  end

  def restart_game
    @snake = Snake.new
    @food = [random_x, random_y]
    @score = 0
    @game_over = false
    @game_speed = GAME_SPEED
    @time_since_last_move = 0
  end
end

# Iniciar o jogo
GameWindow.new.show
