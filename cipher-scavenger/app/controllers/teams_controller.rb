class TeamsController < ApplicationController
  # GET /teams
  # GET /teams.json
  def index
    @teams = Team.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @teams }
    end
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    @team = Team.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @team }
    end
  end

  # GET /teams/new
  # GET /teams/new.json
  def new
    @team = Team.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @team }
    end
  end

  # GET /teams/1/edit
  def edit
    @team = Team.find(params[:id])
  end

  # POST /teams
  # POST /teams.json
  def create
    @team = Team.new(params[:team])
    encoded = ""
    parity = ""
    level = rand(3) + 1
    pin = rand(8999) + 1000
    if level == 1
      encoded = TeamsController.encode_level1(params[:message1])
    elsif level == 2
      encoded = TeamsController.encode_level2(params[:message1])
    elsif level == 3 
      encoded = params[:message2]
      parity = TeamsController.encode_level3(params[:message1], params[:message2])
    end
        
    message = Message.create(:level => level, :decoded => params[:message1], :encoded => encoded, :parity => parity) 
    @team.pin = pin
    @team.score = 0
    @team.message = message
    message.team = @team
    message.save
    @team.save

    respond_to do |format|
      if @team.save
        format.html { redirect_to @team, :notice => 'Team was successfully created.' }
        format.json { render :json => @team, :status => :created, :location => @team }
      else
        format.html { render :action => "new" }
        format.json { render :json => @team.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /teams/1
  # PUT /teams/1.json
  def update
    @team = Team.find(params[:id])

    respond_to do |format|
      if @team.update_attributes(params[:team])
        format.html { redirect_to @team, :notice => 'Team was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @team.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    @team = Team.find(params[:id])
    @team.destroy

    respond_to do |format|
      format.html { redirect_to teams_url }
      format.json { head :no_content }
    end
  end

  def login
    @team = Team.new
    @team.netid = params[:netid]
  end

  def process_login
    if team = Team.login(params[:team])
      session[:id] = user.id # Remember the user_s id during this session 
      #redirect_to session[:return_to] || _/_
      redirect_to 'scoreboard'
    else
      flash[:error] = _Invalid login._ 
      redirect_to :action => _login_, :netid => params[:team][:netid]
    end
  end
  
  # def login
  #   if request.post? and params[:team]
  #     netid = params[:netid]
  #     pass = params[:password]
  #     @team = Team.login(netid, pass)

  #     redirect_to :action => @team
  #   end
  # end

  def get_message
    pin = params[:pin]
    team = Team.find(params[:id])

    if(team.pin != pin)
      # Error
      render :json => {:error => 401}.to_json
      return
    end

    message = team.message

    render :json => {:url => message.get_qr_code_url}.to_json
  end

  def scoreboard
    @teams = Team.all

    respond_to do |format|
      format.html # scoreboard.html.erb
      format.json { render :json => @teams }
    end
  end

  private 

  def self.encode_level1(string)
    encoded = ""
    string.split("").each do |char|
      encoded += char + "."
    end

    return encoded
  end

  def self.encode_level2(string)
    return Base64.encode64(string)
  end

  def self.encode_level3(string1, string2)
    encoded = ""
    string1.each_byte.zip(string2.each_byte).each do |c1, c2|
      c1 = 0 if c1.nil?
      c2 = 0 if c2.nil?

      encoded += (c1 ^ c2).chr
    end

    return Base64.encode64(encoded)
  end
end
