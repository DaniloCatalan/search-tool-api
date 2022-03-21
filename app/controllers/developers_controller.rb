class DevelopersController < ApplicationController

  # GET /developers
  # keep the method in future cases and allow to review the existing
  def index
    @developers = Developer.all

    render json: @developers
  end

  # POST /developers
  # register a developer with the information obtained from your account
  def create
    @developer = Developer.new(developer_params)
    set_developer
    if @developer.save
      save_languages
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

  # returns the developers that meet the condition of the requested language
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
    params.require(:developer).permit(:username, :language)
  end

  # set values obtained from the GitHub api
  # if the user does not exist I stop the process
  def set_developer
    @information = show_user
    raise 'Not Found' if @information.nil?

    @developer.name = @information[:name]
    @developer.repositories = @information[:repositories]
    @developer.location = @information[:location]
  end

  # iterate through the existing languages and save
  def save_languages
    @information[:languages].each do |language|
      Language.create(name: language[:name], percent: language[:proefiency], developer_id: @developer.id)
    end
  end
end
