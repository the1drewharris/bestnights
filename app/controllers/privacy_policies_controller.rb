class PrivacyPoliciesController < ApplicationController
  layout "admin_basic"
  before_filter :authenticate_user!
  # GET /privacy_policies
  # GET /privacy_policies.json
  def index
    @privacy_policies = PrivacyPolicy.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @privacy_policies }
    end
  end

  # GET /privacy_policies/1
  # GET /privacy_policies/1.json
  def show
    @privacy_policy = PrivacyPolicy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @privacy_policy }
    end
  end

  # GET /privacy_policies/new
  # GET /privacy_policies/new.json
  def new
    @privacy_policy = PrivacyPolicy.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @privacy_policy }
    end
  end

  # GET /privacy_policies/1/edit
  def edit
    @privacy_policy = PrivacyPolicy.find(params[:id])
  end

  # POST /privacy_policies
  # POST /privacy_policies.json
  def create
    @privacy_policy = PrivacyPolicy.new(params[:privacy_policy])

    respond_to do |format|
      if @privacy_policy.save
        format.html { redirect_to @privacy_policy, notice: 'Privacy policy was successfully created.' }
        format.json { render json: @privacy_policy, status: :created, location: @privacy_policy }
      else
        format.html { render action: "new" }
        format.json { render json: @privacy_policy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /privacy_policies/1
  # PUT /privacy_policies/1.json
  def update
    @privacy_policy = PrivacyPolicy.find(params[:id])

    respond_to do |format|
      if @privacy_policy.update_attributes(params[:privacy_policy])
        format.html { redirect_to @privacy_policy, notice: 'Privacy policy was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @privacy_policy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /privacy_policies/1
  # DELETE /privacy_policies/1.json
  def destroy
    @privacy_policy = PrivacyPolicy.find(params[:id])
    @privacy_policy.destroy

    respond_to do |format|
      format.html { redirect_to privacy_policies_url }
      format.json { head :no_content }
    end
  end
end
