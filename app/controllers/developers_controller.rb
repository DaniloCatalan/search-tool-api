class DevelopersController < ApplicationController

  # GET /developers
  def index
    @developers = Developer.all

    render json: @developers
  end

  # POST /developers
  def create
    @developer = Developer.new(developer_params)

    if @developer.save
      @information = show_user
      save_languages(params[:username])
      render json: @information, status: 200
    else
      render json: @developer.errors, status: :unprocessable_entity
    end
  end

  def show_user
    if params[:username].present?
      @information = Developer.get_information(params[:username])
    else
      redirect_to developers_path
    end
  end

  def search
    if params[:language].present?
      @developers = Developer.get_developers_by_language(params[:language])
      render json: @developers
    else
      redirect_to developers_path
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def developer_params
      params.require(:developer).permit(:username,:language)
    end

    def save_languages(user_name)
      developer = Developer.find_by(username: user_name)
      @information[:languages].each do |language|
        Language.create(name: language[:name], percent: language[:proefiency], developer_id: developer.id)
      end
  end
end
