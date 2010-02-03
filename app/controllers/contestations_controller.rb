class ContestationsController < ApplicationController
  # GET /contestations
  # GET /contestations.xml
  def index
    @contestations = Contestation.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contestations }
    end
  end

  # GET /contestations/1
  # GET /contestations/1.xml
  def show
    @contestation = Contestation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contestation }
    end
  end

  # GET /contestations/new
  # GET /contestations/new.xml
  def new
    @contestation = Contestation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contestation }
    end
  end

  # GET /contestations/1/edit
  def edit
    @contestation = Contestation.find(params[:id])
  end

  # POST /contestations
  # POST /contestations.xml
  def create
    @contestation = Contestation.new(params[:contestation])

    respond_to do |format|
      if @contestation.save
        flash[:notice] = 'Contestation was successfully created.'
        format.html { redirect_to(@contestation) }
        format.xml  { render :xml => @contestation, :status => :created, :location => @contestation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contestations/1
  # PUT /contestations/1.xml
  def update
    @contestation = Contestation.find(params[:id])

    respond_to do |format|
      if @contestation.update_attributes(params[:contestation])
        flash[:notice] = 'Contestation was successfully updated.'
        format.html { redirect_to(@contestation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contestations/1
  # DELETE /contestations/1.xml
  def destroy
    @contestation = Contestation.find(params[:id])
    @contestation.destroy

    respond_to do |format|
      format.html { redirect_to(contestations_url) }
      format.xml  { head :ok }
    end
  end
end
