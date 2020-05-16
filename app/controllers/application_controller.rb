class ApplicationController < ActionController::API

  def authenticate_token
    # puts "AUTHENTICATE JWT"
    render json: { status: 401, message: 'Unauthorized' } unless decode_token(bearer_token)
  end

  def bearer_token
    # puts "BEARER TOKEN"
    header = request.env["HTTP_AUTHORIZATION"]
    pattern = /^Bearer /
    # puts "TOKEN WITHOUT BEARER"
    # puts header.gsub(pattern, "") if header && header.match(pattern)
    #Make it so that bearer_token returns its result, and that we send a puts to test that decode_token receives the JWT
    header.gsub(pattern, "") if header && header.match(pattern)
    
  end

  def decode_token(token_input)
    # puts "DECODE TOKEN, token input: #{token_input}"
    # puts token = JWT.decode(token_input, ENV['JWT_SECRET'], true)
    JWT.decode(token_input, ENV['JWT_SECRET'], true)
    rescue
      render json: {status: 401, message: 'Unauthorized'}
  end

  def get_current_user
    return if !bearer_token
    decoded_jwt = decode_token(bearer_token)
    User.find(decoded_jwt[0]["user"]["id"])
  end
      
end
