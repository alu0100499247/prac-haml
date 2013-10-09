require 'rack/request'
require 'rack/response'


module PiedraPapelTijeras
	class App
		def initialize(app=nil)
			@app = app
			@content_type = :html
			@defeat = {'piedra' => 'tijeras', 'papel' => 'piedra', 'tijeras' => 'papel'}
			@throws = @defeat.keys
			$choose = @throws.map { |x|
				%Q{ <li><a href="/?choice=#{x}"> #{x} </a></li> }
			}.join("\n")
			$choose = "<p>\n<ul>\n#{$choose}\n</ul>"
		end

		def call(env)
			req = Rack::Request.new(env)

			req.env.keys.sort.each { |x| puts "#{x} => #{req.env[x]}" }
			
			computer_throw = @throws.sample
			player_throw = req.GET["choice"]
			answer = if !@throws.include?(player_throw)
				"Elige una de las siguientes opciones:"
			elsif player_throw == computer_throw
				"Has empatado! Elige de nuevo :)"
			elsif computer_throw == @defeat[player_throw]
				"Bien! #{player_throw} gana a #{computer_throw}!! :D"
			else
				"Ohh! :( #{computer_throw} gana a #{player_throw}! Suerte en la próxima! ;)"
			end

			res = Rack::Response.new
			res.write <<-"EOS"
			<html>
				<meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />
				<title> PPT </title>
				<body>
					<h1>
						#{answer}
						#{$choose}
					</h1>
				</body>
			</html>
			EOS
			res.finish
		end
	end
end

if $0 == __FILE__
	require 'rack'
	require 'rack/showexceptions'
	Rack::Server.start(
		:app => Rack::ShowExceptions.new(
					Rack::Lint.new(
						PiedraPapelTijeras::App.new)),
		:Port => 9292,
		:server => 'thin'
	)
end








