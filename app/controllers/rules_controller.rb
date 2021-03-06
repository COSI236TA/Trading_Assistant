require 'json'

class RulesController < ApplicationController
  include RulesHelper
  include PortfoliosHelper

  before_action :set_rule, only: [:show, :edit, :update, :destroy]
  respond_to :html, :xml, :json
  # GET /rules
  # GET /rules.json
  def index
    @rules = Rule.all
  end

  # GET /rules/1
  # GET /rules/1.json
  def show
  end

  # GET /rules/new
  def new
    @user = User.find(session[:user_id])
    @rule = @user.rules.build
    @properties = get_properties
    @portfolios = get_portfolios.map { |p| [p[0], p[1]] }
    respond_with @rule
  end

  # GET /rules/1/edit
  def edit
    @user = User.find(session[:user_id])
    @properties = get_properties
    @portfolios = get_portfolios.map { |p| [p[0], p[1]] }
  end

  # POST /rules
  # POST /rules.json
  def create
    #Find the user
    # @user = User.find(session[:user_id])

    # #Get clean params
    # rule_clean_params = rule_params

    # #Get property
    # property = rule_clean_params[:property].to_s

    # #Get rel
    # rel = rule_clean_params[:rel]

    # #Get target
    # target = rule_clean_params[:target]

    # #Get portfolio params
    # portfolio_params = params[:portfolio]
    # portfolio = nil


    # #deal with create or select portfolio
    # if portfolio_params[:action] == "select"
    #   #need to create the portfolio
    #   portfolio_id = portfolio_params[:id].to_i
    #   portfolio = @user.portfolios.find(portfolio_id)
    # elsif portfolio_params[:action] == "create"
    #   #get the tickers from params
    #   tickers = portfolio_params[:ticker].values.map { |i| i[:ticker] }
    #   name = portfolio_params[:name]
    #   description = portfolio_params[:description]

    #   portfolio = @user.portfolios.create(name: name, description: description)

    #   tickers.each do |ticker|
    #     DataPool::DataUpdater.update ticker
    #     stock = Stock.find_by(ticker: ticker)
    #     portfolio.stocks << stock

    #     puts portfolio.stocks
    #   end
    # end

    # #create rule

    # #Build params for create rule
    # real_property = Property.find(property)
    # build_params = {
    #   :portfolio => portfolio,
    #   :property => real_property,
    #   :rel => rel,
    #   :target => target,
    #   :name => "#{portfolio.name} #{portfolio.rules.size+1}",
    #   :description => Rule.get_description(portfolio, real_property, rel, target)
    # }

    # prepare_parameters is in RuleHelper
    build_params = prepare_parameters
    @rule = @user.rules.create(build_params)
    response = true
    if !@rule.valid?
      response = false
    end

    #Start the RuleEngine
    RuleEngine::RuleEngine.start

    respond_to do |format|
      format.json { render :json => {response: response } }
    end
  end

  #show content of a rule
  #it can show rule page content with different layout
  def get_rule

    current_rule = Rule.find_by(id: params[:rule_id])

    #rule information
    @rule = current_rule
    # @rule_last_triggered = current_rule.last_triggered
    if @rule != nil
      #portfolio information
      @portfolio = current_rule.portfolio
    end

    if params[:type] == "iframe"
      render :layout=> "iframe_rule"
    else
      render :layout=> "application"
    end


  end
  # PATCH/PUT /rules/1
  # PATCH/PUT /rules/1.json
  def update
    respond_to do |format|
      clean_params = rule_params
      clean_params[:portfolio] = Portfolio.find(clean_params[:portfolio])
      clean_params[:property] = Property.find(clean_params[:property])
      if @rule.update(clean_params)
        format.html { redirect_to dashboard_path, notice: 'Rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rules/1
  # DELETE /rules/1.json
  def destroy
    @rule.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_path }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_rule
    @rule = Rule.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def rule_params
    #Map the number to the real property name
    params.require(:rule).permit(:property, :rel, :target, :portfolio, :activated, :description)
  end

end
