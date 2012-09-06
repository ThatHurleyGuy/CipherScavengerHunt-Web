class TeamsController < ApplicationController

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

    #Quick hack to get rid of foreign characters. Did this seconds before pushing the website, so it's ugly. Oops.
    if params[:message1].chars.count < params[:message1].bytes.count or params[:message2].chars.count < params[:message2].bytes.count
      respond_to do |format|
        format.html {
          flash[:error] = "No strange characters please"
          render :action => "new" and return
        }
      end
    end

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
        format.html 
      else
        format.html { render :action => "new" }
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

  def get_message
    pin = params[:pin]
    team_netid = params[:id]
    team = Team.where("netid = :netid", {:netid => team_netid}).first

    if(team.pin != pin)
      # Error
      render :json => {:error => 401}.to_json
      return
    end

    message = team.message

    render :json => {:url => message.get_qr_code_url}.to_json
  end

  def scoreboard
    @teams = Team.find(:all, :order => "score DESC")

    respond_to do |format|
      format.html # scoreboard.html.erb
      format.json { render :json => @teams }
    end
  end

  def forgotpin
    @team = Team.new
    respond_to do |format|
      format.html # forgotpin.html.erb
    end
  end

  def forgot_pin_action
    @team = Team.find(:first, :conditions => ['netid = ? AND name = ?', params[:team][:netid], params[:team][:name]])

    if @team.nil?
      redirect_to :forgotpin, :flash => {:error => "Unable to find name/netid"} and return
    end

    respond_to do |format|
      format.html # forgot_pin_action.html.erb
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
    if string1.length > string2.length
      temp = string1
      string1 = string2
      string2 = temp
    end

    string2.each_byte.zip(string1.each_byte).each do |c1, c2|
      c1 = 0 if c1.nil?
      c2 = 0 if c2.nil?

      encoded += (c1 ^ c2).chr
    end

    return Base64.encode64(encoded)
  end
end
