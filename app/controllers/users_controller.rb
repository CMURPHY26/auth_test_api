class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :authenticate_token, except: [:login, :create]
  before_action :authorize_user, except: [:login, :create, :index]


  def login
    user = User.find_by(username: params[:user][:username])
    if user && user.authenticate(params[:user][:password])
      token = create_token(user.id, user.username)
      render json: { status: 200, token: token, user: user }
    else
      render json: { status: 401, message: "Unauthorized" }
    end
  end

  def authorize_user
    puts "AUTHORIZE USER"
    puts "user id: #{get_current_user.id}"
    puts "params: #{params[:id]}"
    
    render json: { status: 401, message: "Unauthorized" } unless get_current_user.id == params[:id].to_i  
  end

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: get_current_user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end
  
  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:username, :password_digest)
  end
  
  #Under private, write a method that returns a hash. The hash will contain the payload including the user's id and username to be encrypted
  def payload(id, username)
    {
      exp: (Time.now + 120.minutes).to_i,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      user: {
        id: id,
        username: username
      }
    }
  end
  # method that creates the token with the payload. JWT is how we use use the jwt gem. JWT.encode is a method within the jwt gem. It will encode / generate a JSON Web Token for us
  def create_token(id, username)
    JWT.encode(payload(id, username), ENV['JWT_SECRET'], 'HS256')
  end

end